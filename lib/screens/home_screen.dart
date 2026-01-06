import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../widgets/check_button/long_press_check_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isChecked = false;

  void _onCheckComplete() {
    setState(() {
      _isChecked = true;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ 습관 체크 완료!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetCheck() {
    setState(() {
      _isChecked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '66일 습관 만들기',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Habit Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Habit name and goal
                      const Text(
                        '매일 아침 7시 기상',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '알람 울리면 바로 일어나서 침대 정리하기',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Chain visualization (simple version)
                      Row(
                        children: [
                          _buildChainDot(true),
                          const SizedBox(width: 8),
                          _buildChainDot(true),
                          const SizedBox(width: 8),
                          _buildChainDot(true),
                          const SizedBox(width: 8),
                          _buildChainDot(_isChecked),
                          const SizedBox(width: 8),
                          _buildChainDot(false),
                          const SizedBox(width: 8),
                          _buildChainDot(false),
                          const SizedBox(width: 8),
                          const Text(
                            '...',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stats
                      Row(
                        children: [
                          Text(
                            '연속 ${_isChecked ? 4 : 3}일',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${_isChecked ? 6 : 5}% 달성',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Check button
                      Center(
                        child: LongPressCheckButton(
                          isChecked: _isChecked,
                          onCheckComplete: _onCheckComplete,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Instructions
                      if (!_isChecked)
                        const Center(
                          child: Text(
                            '버튼을 1.5초간 꾹 눌러주세요',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Reset button (for testing)
              if (_isChecked)
                OutlinedButton(
                  onPressed: _resetCheck,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('테스트용: 체크 초기화'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChainDot(bool isChecked) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isChecked ? AppColors.chainChecked : AppColors.chainUnchecked,
        shape: BoxShape.circle,
        border: Border.all(
          color: isChecked ? AppColors.chainChecked : AppColors.chainUnchecked,
          width: 2,
        ),
      ),
    );
  }
}
