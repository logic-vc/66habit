import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/durations.dart';
import '../../services/haptic_service.dart';
import '../../services/sound_service.dart';
import 'circular_gauge_painter.dart';
import 'particle_painter.dart';

class LongPressCheckButton extends StatefulWidget {
  final bool isChecked;
  final VoidCallback onCheckComplete;
  final Duration pressDuration;

  const LongPressCheckButton({
    super.key,
    required this.isChecked,
    required this.onCheckComplete,
    this.pressDuration = AnimationDurations.longPressNormal,
  });

  @override
  State<LongPressCheckButton> createState() => _LongPressCheckButtonState();
}

class _LongPressCheckButtonState extends State<LongPressCheckButton>
    with TickerProviderStateMixin {
  late AnimationController _gaugeController;
  late AnimationController _particleController;
  late AnimationController _scaleController;

  final HapticService _hapticService = HapticService();
  final SoundService _soundService = SoundService();

  List<Particle> _particles = [];
  bool _isPressed = false;
  double _lastHapticProgress = 0;

  @override
  void initState() {
    super.initState();

    // Gauge animation controller
    _gaugeController = AnimationController(
      duration: widget.pressDuration,
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: AnimationDurations.particleExplosion,
      vsync: this,
    );

    // Scale animation controller (for button press effect)
    _scaleController = AnimationController(
      duration: AnimationDurations.buttonPress,
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );

    _gaugeController.addListener(_onGaugeProgress);
    _particleController.addListener(_onParticleAnimation);
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    _particleController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onGaugeProgress() {
    final progress = _gaugeController.value;

    // Trigger haptic feedback at 25%, 50%, 75%
    if ((progress >= 0.24 && progress < 0.26 && _lastHapticProgress < 0.24) ||
        (progress >= 0.49 && progress < 0.51 && _lastHapticProgress < 0.49) ||
        (progress >= 0.74 && progress < 0.76 && _lastHapticProgress < 0.74)) {
      _hapticService.progress(progress);
      _lastHapticProgress = progress;
    }

    // Check completion
    if (progress >= 1.0 && _isPressed) {
      _onCheckCompleted();
    }

    setState(() {});
  }

  void _onParticleAnimation() {
    if (_particles.isNotEmpty) {
      ParticleGenerator.updateParticles(_particles, 1 / 60); // Assume 60fps
      setState(() {});

      // Remove dead particles
      _particles.removeWhere((p) => p.opacity <= 0 || p.size <= 0);
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (widget.isChecked) return;

    setState(() {
      _isPressed = true;
      _lastHapticProgress = 0;
    });

    _scaleController.reverse();
    _gaugeController.forward(from: 0);
    _hapticService.pressStart();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (widget.isChecked) return;

    setState(() {
      _isPressed = false;
    });

    _scaleController.forward();

    // If not completed, reset
    if (_gaugeController.value < 0.7) {
      _gaugeController.reverse();
    } else if (_gaugeController.value < 1.0) {
      // Auto-complete if >= 70%
      _gaugeController.forward();
    }
  }

  void _onCheckCompleted() {
    setState(() {
      _isPressed = false;
    });

    // Trigger feedback
    _hapticService.complete();
    _soundService.playShutter();

    // Generate particles
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final center = Offset(size.width / 2, size.height / 2);
      _particles = ParticleGenerator.generateExplosion(center);
      _particleController.forward(from: 0);
    }

    // Scale animation
    _scaleController.forward();

    // Notify completion
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onCheckComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isChecked) {
      return _buildCheckedButton();
    }

    return ScaleTransition(
      scale: _scaleController,
      child: GestureDetector(
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Particle layer
            if (_particles.isNotEmpty)
              CustomPaint(
                painter: ParticlePainter(_particles),
                size: const Size(200, 200),
              ),

            // Button
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Gauge
                  CustomPaint(
                    painter: CircularGaugePainter(
                      progress: _gaugeController.value,
                    ),
                    size: const Size(100, 100),
                  ),

                  // Icon and text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _gaugeController.value >= 1.0
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 32,
                        color: _gaugeController.value >= 1.0
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _gaugeController.value > 0 && _gaugeController.value < 1.0
                            ? '${(_gaugeController.value * 100).toInt()}%'
                            : '꾹 눌러서\n체크하기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: _isPressed ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckedButton() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 40,
            color: Colors.white,
          ),
          SizedBox(height: 4),
          Text(
            '오늘 완료 ✓',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
