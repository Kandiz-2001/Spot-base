import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _sortBy = 'reputation';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.loadLeaderboard(sortBy: _sortBy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
              _loadLeaderboard();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reputation',
                child: Text('Reputation'),
              ),
              const PopupMenuItem(
                value: 'total_spots',
                child: Text('Total Spots'),
              ),
              const PopupMenuItem(
                value: 'total_reviews',
                child: Text('Total Reviews'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLeaderboard,
        child: Consumer2<UserProvider, AuthProvider>(
          builder: (context, userProvider, authProvider, _) {
            if (userProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userProvider.leaderboard.isEmpty) {
              return const Center(child: Text('No data available'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userProvider.leaderboard.length,
              itemBuilder: (context, index) {
                final user = userProvider.leaderboard[index];
                final rank = index + 1;
                final isCurrentUser = user.id == authProvider.user?.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isCurrentUser
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : null,
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: _getRankColor(rank).withOpacity(0.1),
                          backgroundImage: user.photoUrl != null
                              ? CachedNetworkImageProvider(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  Helpers.getInitials(
                                      user.displayName ?? user.email),
                                  style: TextStyle(
                                    color: _getRankColor(rank),
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        if (rank <= 3)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _getRankColor(rank),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                rank == 1
                                    ? Icons.looks_one
                                    : rank == 2
                                        ? Icons.looks_two
                                        : Icons.looks_3,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Text(
                          '$rank. ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getRankColor(rank),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            user.displayName ?? 'Anonymous',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isTrustedReviewer)
                          const Icon(
                            Icons.verified_user,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text('${user.reputation} pts'),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text('${user.totalSpots}'),
                        const SizedBox(width: 12),
                        const Icon(Icons.rate_review, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text('${user.totalReviews}'),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (index * 50).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            );
          },
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.textSecondary;
    }
  }
}