import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import 'wallet_screen.dart';
import '../onboarding/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.user != null) {
      await userProvider.loadCurrentUser(authProvider.user!.id);
    }
  }

  Future<void> _signOut() async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
    );

    if (!confirm) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings screen
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, UserProvider>(
        builder: (context, authProvider, userProvider, _) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return RefreshIndicator(
            onRefresh: _loadUserData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: user.photoUrl != null
                              ? CachedNetworkImageProvider(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  Helpers.getInitials(
                                      user.displayName ?? user.email),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                )
                              : null,
                        )
                            .animate()
                            .scale(duration: 400.ms, curve: Curves.elasticOut),

                        const SizedBox(height: 16),

                        // Name
                        Text(
                          user.displayName ?? 'Anonymous',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(delay: 100.ms),

                        const SizedBox(height: 4),

                        // Email
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 16),

                        // Reputation badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${user.reputation} Reputation',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms).scale(),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Stats grid
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildStatCard(
                        icon: Icons.location_on,
                        label: 'Spots',
                        value: user.totalSpots.toString(),
                        color: Colors.blue,
                      ).animate().fadeIn(delay: 100.ms).scale(),
                      _buildStatCard(
                        icon: Icons.rate_review,
                        label: 'Reviews',
                        value: user.totalReviews.toString(),
                        color: Colors.orange,
                      ).animate().fadeIn(delay: 200.ms).scale(),
                      _buildStatCard(
                        icon: Icons.check_circle,
                        label: 'Check-ins',
                        value: user.totalCheckIns.toString(),
                        color: Colors.green,
                      ).animate().fadeIn(delay: 300.ms).scale(),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Token balance card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WalletScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.toll,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SBT Balance',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  userProvider.formattedTokenBalance,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Badges section
                  if (user.badges.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Badges',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.badges
                          .map((badge) => Chip(
                                label: Text(badge),
                                avatar: const Icon(Icons.emoji_events, size: 18),
                                backgroundColor:
                                    AppTheme.accentColor.withOpacity(0.1),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Menu items
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Wallet',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WalletScreen()),
                      );
                    },
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2, end: 0),

                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Activity History',
                    onTap: () {
                      // Activity history
                    },
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2, end: 0),

                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      // Help screen
                    },
                  ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2, end: 0),

                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {
                      // About screen
                    },
                  ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 24),

                  // Sign out button
                  CustomButton(
                    text: 'Sign Out',
                    onPressed: _signOut,
                    type: ButtonType.outlined,
                    icon: Icons.logout,
                  ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}