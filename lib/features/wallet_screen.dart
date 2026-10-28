import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../core/wallet_helpers.dart';
import '../data/finance_store.dart';
import '../domain/models.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, required this.store});
  final FinanceStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Kelola Dompet'),
          actions: [
            IconButton(
              tooltip: 'Tambah Dompet',
              icon: const Icon(Icons.add_rounded),
              onPressed: () => showAddOrEditWalletSheet(context, store: store),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showAddOrEditWalletSheet(context, store: store),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah Dompet'),
        ),
        body: store.wallets.isEmpty
            ? _buildEmptyState(context)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: store.wallets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final wallet = store.wallets[index];
                  return _WalletCard(
                    wallet: wallet,
                    store: store,
                    onTap: () => _showWalletDetail(context, wallet),
                    onEdit: () => showAddOrEditWalletSheet(
                      context,
                      store: store,
                      walletToEdit: wallet,
                    ),
                    onDelete: () => _confirmDeleteWallet(context, wallet),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada dompet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan dompet seperti Tunai, Rekening Bank, atau E-Wallet untuk mulai mencatat keuanganmu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => showAddOrEditWalletSheet(context, store: store),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Dompet Pertama'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletDetail(BuildContext context, Wallet wallet) {
    final balance = store.balanceFor(wallet.id);
    final walletTxs = store.transactionsForWallet(wallet.id);
    final option = WalletHelper.getOption(wallet.type);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.82,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: option.gradient),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(option.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        option.label,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo Saat Ini',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          formatRupiah(balance),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      width: 1, height: 38, color: AppColors.cardBorder),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo Awal',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          formatRupiah(wallet.initialBalance),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Riwayat Transaksi (${walletTxs.length})',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: walletTxs.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada transaksi di dompet ini.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      itemCount: walletTxs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final tx = walletTxs[i];
                        final isIncome = tx.type == TransactionType.income ||
                            (tx.type == TransactionType.transfer &&
                                tx.destinationWalletId == wallet.id);
                        final cat = store.getCategory(tx.categoryId);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: isIncome
                                ? AppColors.incomeContainer
                                : AppColors.expenseContainer,
                            child: Icon(
                              isIncome
                                  ? Icons.south_west_rounded
                                  : Icons.north_east_rounded,
                              color: isIncome
                                  ? AppColors.income
                                  : AppColors.expense,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            cat?.name ??
                                (tx.type == TransactionType.transfer
                                    ? 'Transfer'
                                    : (tx.note.isNotEmpty
                                        ? tx.note
                                        : 'Transaksi')),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${formatDate(tx.date)}${tx.note.isNotEmpty ? ' • ${tx.note}' : ''}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            '${isIncome ? '+' : '-'}${formatRupiah(tx.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isIncome
                                  ? AppColors.income
                                  : AppColors.expense,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteWallet(BuildContext context, Wallet wallet) {
    final hasTx = store.transactions.any((tx) =>
        tx.walletId == wallet.id || tx.destinationWalletId == wallet.id);
    if (store.wallets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat menghapus satu-satunya dompet aktif.'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }
    if (hasTx) {
      showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Tidak Dapat Menghapus Dompet'),
          content: Text(
            'Dompet "${wallet.name}" memiliki riwayat transaksi aktif. Hapus atau pindahkan transaksi terkait sebelum menghapus dompet ini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Dompet?'),
        content: Text(
            'Apakah kamu yakin ingin menghapus dompet "${wallet.name}"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await store.deleteWallet(wallet.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Dompet "${wallet.name}" berhasil dihapus.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.expense,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.wallet,
    required this.store,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Wallet wallet;
  final FinanceStore store;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final balance = store.balanceFor(wallet.id);
    final option = WalletHelper.getOption(wallet.type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: option.gradient),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(option.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wallet.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${option.label} • Saldo Awal ${formatRupiah(wallet.initialBalance)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded,
                        color: AppColors.textSecondary),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                      if (value == 'detail') onTap();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 18),
                            SizedBox(width: 10),
                            Text('Lihat Transaksi'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 18),
                            SizedBox(width: 10),
                            Text('Ubah Dompet'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 18, color: AppColors.expense),
                            SizedBox(width: 10),
                            Text('Hapus',
                                style: TextStyle(color: AppColors.expense)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFCFA),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saldo Tersedia',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    formatRupiah(balance),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: balance >= 0
                          ? AppColors.primary
                          : AppColors.expense,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAddOrEditWalletSheet(
  BuildContext context, {
  required FinanceStore store,
  Wallet? walletToEdit,
}) async {
  final isEdit = walletToEdit != null;
  final formKey = GlobalKey<FormState>();
  final nameController =
      TextEditingController(text: isEdit ? walletToEdit.name : '');
  final balanceController = TextEditingController(
      text: isEdit ? formatNumber(walletToEdit.initialBalance) : '0');
  String selectedType = isEdit ? walletToEdit.type : 'cash';
  bool saving = false;
  String? inlineError;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEdit
                          ? Icons.edit_rounded
                          : Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Ubah Dompet' : 'Tambah Dompet Baru',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Tipe Dompet',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WalletHelper.availableTypes.map((typeOption) {
                  final isSelected = selectedType == typeOption.key;
                  return ChoiceChip(
                    avatar: Icon(
                      typeOption.icon,
                      size: 18,
                      color: isSelected ? Colors.white : typeOption.primaryColor,
                    ),
                    label: Text(typeOption.label),
                    selected: isSelected,
                    selectedColor: typeOption.primaryColor,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? typeOption.primaryColor
                          : AppColors.cardBorder,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setSheetState(() => selectedType = typeOption.key);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                autofocus: !isEdit,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Dompet',
                  hintText: 'Contoh: Tunai, BCA, GoPay, Tabungan',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  final trimmed = (value ?? '').trim();
                  if (trimmed.isEmpty) return 'Nama dompet wajib diisi.';
                  final isDuplicate = store.wallets.any((w) =>
                      w.id != walletToEdit?.id &&
                      w.name.toLowerCase() == trimmed.toLowerCase());
                  if (isDuplicate) return 'Nama dompet ini sudah digunakan.';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Saldo Awal',
                  prefixText: 'Rp ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                onChanged: (val) {
                  final num = parseNumber(val);
                  if (val.isNotEmpty) {
                    final formatted = formatNumber(num);
                    if (formatted != val) {
                      balanceController.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  }
                },
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Saldo awal wajib diisi (minimal 0).';
                  }
                  final num = parseNumber(value!);
                  if (num < 0) return 'Saldo awal tidak boleh negatif.';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Quick balance chips
              Wrap(
                spacing: 6,
                children: [0, 50000, 100000, 500000, 1000000].map((amount) {
                  return ActionChip(
                    padding: EdgeInsets.zero,
                    label: Text(
                      amount == 0 ? 'Rp 0' : formatRupiah(amount),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                    onPressed: () {
                      setSheetState(() {
                        balanceController.text = formatNumber(amount);
                      });
                    },
                  );
                }).toList(),
              ),
              if (inlineError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.expenseContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.expense, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          inlineError!,
                          style: const TextStyle(
                              color: AppColors.expense, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setSheetState(() {
                          saving = true;
                          inlineError = null;
                        });
                        try {
                          final parsedAmount = parseNumber(balanceController.text);
                          if (isEdit) {
                            await store.updateWallet(
                              walletToEdit.id,
                              name: nameController.text,
                              initialBalance: parsedAmount,
                              type: selectedType,
                            );
                          } else {
                            await store.addWallet(
                              nameController.text,
                              parsedAmount,
                              type: selectedType,
                            );
                          }
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEdit
                                    ? 'Dompet berhasil diperbarui.'
                                    : 'Dompet baru berhasil ditambahkan!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        } catch (err) {
                          setSheetState(() {
                            saving = false;
                            if (err is ArgumentError) {
                              inlineError = err.message?.toString() ??
                                  'Data input tidak valid.';
                            } else if (err is StateError) {
                              inlineError = err.message;
                            } else {
                              inlineError =
                                  'Gagal menyimpan dompet. Silakan coba lagi.';
                            }
                          });
                        }
                      },
                icon: saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(saving
                    ? 'Menyimpan...'
                    : (isEdit ? 'Simpan Perubahan' : 'Tambah Dompet')),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  nameController.dispose();
  balanceController.dispose();
}
