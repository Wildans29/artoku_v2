import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../core/wallet_helpers.dart';
import '../data/finance_store.dart';
import '../domain/models.dart';
import 'add_transaction_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, required this.store});
  final FinanceStore store;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTxs = widget.store.transactions;

    // Filter by type
    var filtered = _selectedFilter == null
        ? allTxs
        : allTxs.where((item) => item.type == _selectedFilter).toList();

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((item) {
        final cat = widget.store.getCategory(item.categoryId);
        final wallet = widget.store.getWallet(item.walletId);
        final destWallet = item.destinationWalletId != null
            ? widget.store.getWallet(item.destinationWalletId!)
            : null;
        return (cat?.name.toLowerCase().contains(q) ?? false) ||
            item.note.toLowerCase().contains(q) ||
            (wallet?.name.toLowerCase().contains(q) ?? false) ||
            (destWallet?.name.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return Scaffold(
      body: Column(
        children: [
          // Header Filter & Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari catatan, kategori, dompet...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    fillColor: const Color(0xFFF1F5F9),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 10),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', null),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pengeluaran', TransactionType.expense),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pemasukan', TransactionType.income),
                      const SizedBox(width: 8),
                      _buildFilterChip('Transfer', TransactionType.transfer),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),

          // Transaction List or Empty State
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isFirstOrNewDate = index == 0 ||
                          !_isSameDay(filtered[index - 1].date, item.date);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isFirstOrNewDate) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 8),
                              child: Text(
                                formatRelativeDate(item.date),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                          _buildDismissibleTile(item),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionType? type) {
    final isSelected = _selectedFilter == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = type),
      selectedColor: AppColors.primaryContainer,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.cardBorder,
      ),
    );
  }

  Widget _buildDismissibleTile(FinanceTransaction item) {
    final isIncome = item.type == TransactionType.income;
    final isTransfer = item.type == TransactionType.transfer;
    final category = widget.store.getCategory(item.categoryId);
    final wallet = widget.store.getWallet(item.walletId);
    final destWallet = item.destinationWalletId != null
        ? widget.store.getWallet(item.destinationWalletId!)
        : null;

    final title = isTransfer
        ? 'Transfer Dompet'
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.expense,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Hapus',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              SizedBox(width: 8),
              Icon(Icons.delete_outline_rounded, color: Colors.white),
            ],
          ),
        ),
        onDismissed: (_) {
          widget.store.deleteTransaction(item.id);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transaksi berhasil dihapus'),
              action: SnackBarAction(
                label: 'Batalkan',
                textColor: Colors.amberAccent,
                onPressed: () => widget.store.restoreTransaction(item),
              ),
            ),
          );
        },
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(categoryIcon, color: categoryColor, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          subtitle: Text(
            subtitle.toString(),
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          trailing: Text(
            '${isIncome ? '+' : (isTransfer ? '' : '-')}${formatRupiah(item.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: isIncome
                  ? AppColors.income
                  : (isTransfer ? AppColors.transfer : AppColors.expense),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada transaksi',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Belum ada transaksi yang sesuai dengan filter atau pencarianmu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddTransactionSheet(store: widget.store),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Catat Transaksi'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
