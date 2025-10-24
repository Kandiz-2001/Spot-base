import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/user_provider.dart';
import '../../models/geoquest_model.dart';
import '../../utils/helpers.dart';

class GeoQuestScreen extends StatefulWidget {
  const GeoQuestScreen({super.key});

  @override
  State<GeoQuestScreen> createState() => _GeoQuestScreenState();
}

class _GeoQuestScreenState extends State<GeoQuestScreen> {
  @override
  void initState() {
    super.initState();
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.loadActiveQuests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoQuests'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadQuests,
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            if (userProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userProvider.activeQuests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 80,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Active Quests',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check back soon for new challenges',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userProvider.activeQuests.length,
              itemBuilder: (context, index) {
                final quest = userProvider.activeQuests[index];
                final userQuest = userProvider.userQuests.firstWhere(
                  (uq) => uq.questId == quest.id,
                  orElse: () => UserQuestModel(
                    id: '',
                    userId: '',
                    questId: quest.id,
                  ),
                );

                return _buildQuestCard(quest, userQuest)
                    .animate()
                    .fadeIn(delay: (index * 100).ms)
                    .slideY(begin: 0.1, end: 0);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestCard(GeoQuestModel quest, UserQuestModel userQuest) {
    final progress = userQuest.getProgressPercentage(quest.targetCount);
    final isCompleted = userQuest.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? AppTheme.accentGradient
                        : AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted ? Icons.emoji_events : Icons.flag,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${quest.daysRemaining} days remaining',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              quest.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted
                                ? AppTheme.successColor
                                : AppTheme.primaryColor,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${userQuest.progress}/${quest.targetCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.toll,
                        size: 16,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        quest.rewardAmount,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}