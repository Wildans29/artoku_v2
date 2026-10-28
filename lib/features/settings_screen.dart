import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/finance_store.dart';
import 'wallet_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});
  final FinanceStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Pengaturan')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Wallet Management Card
            _buildSettingCard(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: AppColors.primary,
              title: 'Kelola Dompet',
              subtitle: '${store.wallets.length} dompet aktif',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => WalletScreen(store: store)),
              ),
            ),
            const SizedBox(height: 12),

            // Storage info
            _buildSettingCard(
              icon: Icons.storage_rounded,
              iconColor: const Color(0xFF2563EB),
              title: 'Penyimpanan Lokal',
              subtitle:
                  '${store.transactions.length} transaksi tersimpan di perangkat ini',
            ),
            const SizedBox(height: 12),

            // App info
            _buildSettingCard(
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF7C3AED),
              title: 'ARTOKU V2',
              subtitle: 'Versi 2.1.0 • Offline-First Personal Finance',
            ),
            const SizedBox(height: 24),

            // Danger Zone / Reset
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.expense.withValues(alpha: 0.3)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.expenseContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_forever_rounded,
                      color: AppColors.expense, size: 22),
                ),
                title: const Text(
                  'Reset Semua Data',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.expense,
                  ),
                ),
                subtitle: const Text(
                  'Hapus semua dompet dan transaksi',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () => _confirmReset(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        trailing: trailing,
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reset Semua Data?'),
        content: const Text(
          'Tindakan ini akan menghapus semua dompet, transaksi, dan anggaran yang telah dicatat. Data yang terhapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await store.resetAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua data berhasil direset.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }
}
