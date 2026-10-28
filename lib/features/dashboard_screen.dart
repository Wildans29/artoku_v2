import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../core/wallet_helpers.dart';
import '../data/finance_store.dart';
import '../domain/models.dart';
import 'add_transaction_sheet.dart';
import 'wallet_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.store,
    this.onNavigateToTransactions,
    this.onNavigateToBudget,
  });

  final FinanceStore store;
  final VoidCallback? onNavigateToTransactions;
  final VoidCallback? onNavigateToBudget;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hideBalance = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final income = widget.store.totalForMonth(TransactionType.income, now);
    final expense = widget.store.totalForMonth(TransactionType.expense, now);
    final totalBalance = widget.store.totalBalance;
    final wallets = widget.store.wallets;
    final recentTransactions = widget.store.transactions.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // 1. Hero Wealth Card
        _buildHeroCard(totalBalance, income, expense),
        const SizedBox(height: 12),

        // 2. Quick Actions
        _buildQuickActions(context),
        const SizedBox(height: 14),

        // 3. Wallets Header & Carousel
        _buildWalletsHeader(context),
        const SizedBox(height: 8),
        _buildWalletsCarousel(context, wallets),
        const SizedBox(height: 14),

        // 4. Recent Activities Header & Content
        _buildRecentActivitiesHeader(context, recentTransactions),
        const SizedBox(height: 8),
        _buildRecentActivitiesContent(context, recentTransactions),
      ],
    );
  }

  Widget _buildHeroCard(int totalBalance, int income, int expense) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF094328), Color(0xFF137547), Color(0xFF1B995E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D5C3A).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              color: Colors.white70, size: 13),
                          SizedBox(width: 5),
                          Text(
                            'Total kekayaan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: _hideBalance ? 'Tampilkan saldo' : 'Sembunyikan saldo',
                      icon: Icon(
                        _hideBalance
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _hideBalance = !_hideBalance),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _hideBalance ? '••••••••' : formatRupiah(totalBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildFlowBadge(
                        label: 'Pemasukan',
                        amount: income,
                        icon: Icons.arrow_downward_rounded,
                        isIncome: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFlowBadge(
                        label: 'Pengeluaran',
                        amount: expense,
                        icon: Icons.arrow_upward_rounded,
                        isIncome: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowBadge({
    required String label,
    required int amount,
    required IconData icon,
    required bool isIncome,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isIncome
                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                  : const Color(0xFFEF4444).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Text(
                  _hideBalance ? '••••••' : formatRupiah(amount),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            context,
            icon: Icons.add_circle_outline_rounded,
            label: 'Catat',
            color: AppColors.primary,
            onTap: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddTransactionSheet(store: widget.store),
            ),
          ),
          _buildActionButton(
            context,
            icon: Icons.account_balance_wallet_outlined,
            label: '+ Dompet',
            color: const Color(0xFF2563EB),
            onTap: () =>
                showAddOrEditWalletSheet(context, store: widget.store),
          ),
          _buildActionButton(
            context,
            icon: Icons.swap_horiz_rounded,
            label: 'Transfer',
            color: AppColors.transfer,
            onTap: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddTransactionSheet(
                store: widget.store,
                initialType: TransactionType.transfer,
              ),
            ),
          ),
          _buildActionButton(
            context,
            icon: Icons.pie_chart_outline_rounded,
            label: 'Anggaran',
            color: const Color(0xFFD97706),
            onTap: () {
              if (widget.onNavigateToBudget != null) {
                widget.onNavigateToBudget!();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Dompet saya',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WalletScreen(store: widget.store),
            ),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 15),
          label: const Text('Kelola'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletsCarousel(BuildContext context, List<Wallet> wallets) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: wallets.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == wallets.length) {
            return _buildAddWalletCard(context);
          }
          final wallet = wallets[index];
          return _buildWalletMiniCard(context, wallet);
        },
      ),
    );
  }

  Widget _buildWalletMiniCard(BuildContext context, Wallet wallet) {
    final balance = widget.store.balanceFor(wallet.id);
    final option = WalletHelper.getOption(wallet.type);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WalletScreen(store: widget.store),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: option.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: option.primaryColor.withValues(alpha: 0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  option.label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(option.icon, color: Colors.white, size: 16),
              ],
            ),
            const Spacer(),
            Text(
              wallet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            Text(
              _hideBalance ? '••••••' : formatRupiah(balance),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddWalletCard(BuildContext context) {
    return InkWell(
      onTap: () => showAddOrEditWalletSheet(context, store: widget.store),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tambah\nDompet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesHeader(
    BuildContext context,
    List<FinanceTransaction> transactions,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Aktivitas terbaru',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        if (transactions.isNotEmpty)
          TextButton(
            onPressed: () {
              if (widget.onNavigateToTransactions != null) {
                widget.onNavigateToTransactions!();
              }
            },
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Semua'),
          ),
      ],
    );
  }

  Widget _buildRecentActivitiesContent(
    BuildContext context,
    List<FinanceTransaction> transactions,
  ) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 10),
            const Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Catat pengeluaran atau pemasukan pertamamu hari ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddTransactionSheet(store: widget.store),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Catat Sekarang'),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
        itemBuilder: (context, index) {
          final item = transactions[index];
          return _DashboardTransactionTile(
            item: item,
            store: widget.store,
          );
        },
      ),
    );
  }
}

class _DashboardTransactionTile extends StatelessWidget {
  const _DashboardTransactionTile({required this.item, required this.store});
  final FinanceTransaction item;
  final FinanceStore store;

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == TransactionType.income;
    final isTransfer = item.type == TransactionType.transfer;
    final category = store.getCategory(item.categoryId);
    final wallet = store.getWallet(item.walletId);
    final destWallet = item.destinationWalletId != null
        ? store.getWallet(item.destinationWalletId!)
        : null;

    final title = isTransfer
        ? 'Transfer'
        : (category?.name ??
            (item.note.isNotEmpty ? item.note : 'Tanpa Kategori'));

    final subtitle = StringBuffer();
    if (wallet != null) {
      if (isTransfer && destWallet != null) {
        subtitle.write('${wallet.name} → ${destWallet.name}');
      } else {
        subtitle.write(wallet.name);
      }
    }
    subtitle.write(' • ${formatDate(item.date)}');
    if (item.note.isNotEmpty && item.note != title) {
      subtitle.write(' • ${item.note}');
    }

    final categoryColor =
        WalletHelper.getCategoryColor(item.categoryId, item.type);
    final categoryIcon =
        WalletHelper.getCategoryIcon(item.categoryId, item.type);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(categoryIcon, color: categoryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      subtitle: Text(
        subtitle.toString(),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: Text(
        '${isIncome ? '+' : (isTransfer ? '' : '-')}${formatRupiah(item.amount)}',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: isIncome
              ? AppColors.income
              : (isTransfer ? AppColors.transfer : AppColors.expense),
        ),
      ),
    );
  }
}
