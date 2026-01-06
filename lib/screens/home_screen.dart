import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/check_button/long_press_check_button.dart';
import '../services/sound_service.dart';
import '../services/haptic_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load habits when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
    });
  }

  Future<void> _addSampleHabit() async {
    final provider = context.read<HabitProvider>();

    final habit = Habit(
      name: '매일 아침 7시 기상',
      goal: '알람 울리면 바로 일어나서 침대 정리하기',
      startDate: DateTime.now().subtract(const Duration(days: 3)),
    );

    await provider.addHabit(habit);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ 샘플 습관이 추가되었습니다!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _onCheckComplete(int habitId) async {
    final provider = context.read<HabitProvider>();

    try {
      final milestone = await provider.checkHabitToday(habitId);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(milestone != null
                ? '🎉 축하합니다! $milestone일 연속 달성!'
                : '✨ 습관 체크 완료!'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Play milestone sound if applicable
        if (milestone != null) {
          SoundService().playMilestone();
          HapticService().milestone();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<HabitProvider>().loadHabits(),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final habitsWithData = provider.getAllHabitsWithData();

          if (habitsWithData.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadHabits(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: habitsWithData.length,
              itemBuilder: (context, index) {
                final habitData = habitsWithData[index];
                return _buildHabitCard(habitData);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleHabit,
        tooltip: '샘플 습관 추가',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 24),
          Text(
            '아직 습관이 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '+ 버튼을 눌러 첫 습관을 추가해보세요!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(HabitWithData habitData) {
    final habit = habitData.habit;
    final chainData = habitData.chainData;
    final isCheckedToday = habitData.isCheckedToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit name and goal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        habit.goal,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showHabitOptions(habit),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chain visualization
            _buildChainView(chainData),
            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Text(
                  '연속 ${chainData.currentStreak}일',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(chainData.completionRate * 100).toInt()}% 달성',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${chainData.totalChecks}/66일',
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
                isChecked: isCheckedToday,
                onCheckComplete: () => _onCheckComplete(habit.id!),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            if (!isCheckedToday)
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
    );
  }

  Widget _buildChainView(ChainData chainData) {
    // Show first 14 days of chain
    final displayChain = chainData.chain66.take(14).toList();

    return Row(
      children: [
        for (int i = 0; i < displayChain.length; i++) ...[
          _buildChainDot(displayChain[i], i == chainData.daysElapsed - 1),
          if (i < displayChain.length - 1) const SizedBox(width: 6),
        ],
        const SizedBox(width: 6),
        const Text(
          '...',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChainDot(bool isChecked, bool isToday) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isChecked ? AppColors.chainChecked : AppColors.chainUnchecked,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(
                color: AppColors.chainToday,
                width: 2,
              )
            : null,
      ),
    );
  }

  void _showHabitOptions(Habit habit) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('습관 삭제'),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await _confirmDelete(habit.name);
                  if (confirm == true && mounted) {
                    await context.read<HabitProvider>().deleteHabit(habit.id!);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('습관이 삭제되었습니다')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(String habitName) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('습관 삭제'),
          content: Text('정말로 "$habitName" 습관을 삭제하시겠습니까?\n모든 기록이 함께 삭제됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
