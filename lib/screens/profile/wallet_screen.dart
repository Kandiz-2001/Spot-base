import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/wallet_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _walletService = WalletService.instance;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.user?.walletAddress != null) {
      await userProvider.loadTokenBalance(authProvider.user!.walletAddress);
    }
  }

  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    Helpers.showSnackBar(context, 'Address copied to clipboard');
  }

  Future<void> _reconnectWallet() async {
    try {
      Helpers.showLoadingDialog(context, message: 'Connecting wallet...');
      await _walletService.connect();
      Helpers.hideLoadingDialog(context);

      if (!mounted) return;
      Helpers.showSnackBar(context, 'Wallet connected successfully');
      await _loadWalletData();
    } catch (e) {
      if (!mounted) return;
      Helpers.hideLoadingDialog(context);
      Helpers.showSnackBar(
        context,
        'Failed to connect wallet: ${e.toString()}',
        isError: true,
      );
    }
  }

  Future<void> _disconnectWallet() async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Disconnect Wallet',
      message: 'Are you sure you want to disconnect your wallet?',
      confirmText: 'Disconnect',
    );

    if (!confirm) return;

    await _walletService.disconnect();
    Helpers.showSnackBar(context, 'Wallet disconnected');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        elevation: 0,
      ),
      body: Consumer2<AuthProvider, UserProvider>(
        builder: (context, authProvider, userProvider, _) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Balance card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SBT Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userProvider.formattedTokenBalance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SpotBase Tokens',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(curve: Curves.elasticOut),

                const SizedBox(height: 24),

                // Wallet address card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Wallet Address',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_walletService.isConnected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Connected',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _walletService.formatAddress(
                                    user.walletAddress),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () => _copyAddress(user.walletAddress),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // Network info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Network',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Network', 'Base Sepolia'),
                      _buildInfoRow('Chain ID', '84532'),
                      _buildInfoRow('Token', 'SBT (SpotBase Token)'),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // Contract addresses
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Smart Contracts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildContractRow(
                        'Token',
                        '0x8eF0...3Ef1',
                        '0x8eF00a5F252C9F23Cf981C7f7993a66C9e9C3Ef1',
                      ),
                      _buildContractRow(
                        'Registry',
                        '0xC67c...f7CC',
                        '0xC67cF666608e3A22F6925e1603C06179Bc1ff7CC',
                      ),
                      _buildContractRow(
                        'Review NFT',
                        '0x815E...b7E0',
                        '0x815E17f76a27ff3709dF1c71847fcA6CAe21b7E0',
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // Wallet actions
                if (_walletService.isConnected) ...[
                  CustomButton(
                    text: 'Disconnect Wallet',
                    onPressed: _disconnectWallet,
                    type: ButtonType.outlined,
                    icon: Icons.power_settings_new,
                  )
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                ] else ...[
                  GradientButton(
                    text: 'Reconnect Wallet',
                    onPressed: _reconnectWallet,
                    icon: Icons.account_balance_wallet,
                    width: double.infinity,
                    height: 56,
                  )
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                ],

                const SizedBox(height: 16),

                // Info text
                const Text(
                  'Your wallet is secured by WalletConnect. You maintain full custody of your assets.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 600.ms),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractRow(String label, String shortAddress, String fullAddress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Row(
            children: [
              Text(
                shortAddress,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () => _copyAddress(fullAddress),
                padding: const EdgeInsets.only(left: 8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}