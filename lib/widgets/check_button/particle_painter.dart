import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    this.opacity = 1.0,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class ParticleGenerator {
  static List<Particle> generateExplosion(Offset center, {int count = 8}) {
    final particles = <Particle>[];
    final random = math.Random();

    for (int i = 0; i < count; i++) {
      final angle = (2 * math.pi / count) * i + random.nextDouble() * 0.5;
      final speed = 80 + random.nextDouble() * 40;

      particles.add(Particle(
        position: center,
        velocity: Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        ),
        size: 3 + random.nextDouble() * 3,
        color: _randomColor(random),
        opacity: 1.0,
      ));
    }

    return particles;
  }

  static Color _randomColor(math.Random random) {
    final colors = [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.accent,
      AppColors.success,
    ];
    return colors[random.nextInt(colors.length)];
  }

  static void updateParticles(List<Particle> particles, double deltaTime) {
    for (final particle in particles) {
      // Update position
      particle.position = Offset(
        particle.position.dx + particle.velocity.dx * deltaTime,
        particle.position.dy + particle.velocity.dy * deltaTime,
      );

      // Apply gravity
      particle.velocity = Offset(
        particle.velocity.dx,
        particle.velocity.dy + 200 * deltaTime, // Gravity
      );

      // Fade out
      particle.opacity = (particle.opacity - deltaTime * 1.5).clamp(0.0, 1.0);

      // Shrink
      particle.size = (particle.size - deltaTime * 5).clamp(0.0, double.infinity);
    }
  }
}
