import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../core/wallet_helpers.dart';
import '../data/finance_store.dart';
import '../domain/models.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key, required this.store});
  final FinanceStore store;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final budgets = store.budgets
        .where((item) =>
            item.month.year == now.year && item.month.month == now.month)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        // 1. Header Banner
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F5132), Color(0xFF147A4E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bulan ${formatMonthYear(now)}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Kontrol Pengeluaran',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Atur batas belanja agar cash flow tetap sehat.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: () => _showBudgetForm(context, now),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  minimumSize: Size.zero,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_rounded, size: 18),
                    SizedBox(width: 4),
                    Text('Atur',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. Budget List or Empty State
        if (budgets.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada batas anggaran',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Buat anggaran bulanan untuk semua pengeluaran atau kategori tertentu (misal: Makanan, Belanja).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _showBudgetForm(context, now),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Buat Anggaran Sekarang'),
                ),
              ],
            ),
          )
        else
          ...budgets.map((budget) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BudgetCard(store: store, budget: budget),
              )),
      ],
    );
  }

  Future<void> _showBudgetForm(BuildContext context, DateTime month) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BudgetFormSheet(
        store: store,
        month: month,
      ),
    );
  }
}

class _BudgetFormSheet extends StatefulWidget {
  const _BudgetFormSheet({
    required this.store,
    required this.month,
  });

  final FinanceStore store;
  final DateTime month;

  @override
  State<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<_BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.store.setBudget(
      month: widget.month,
      limitAmount: parseNumber(_amountController.text),
      categoryId: _categoryId,
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Anggaran berhasil disimpan.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.store.categories
        .where((item) => item.type == TransactionType.expense)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                const Text(
                  'Atur Batas Anggaran',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Untuk periode ${formatMonthYear(widget.month)}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Cakupan Kategori',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Semua Pengeluaran'),
                    ),
                    ...categories.map((item) => DropdownMenuItem<String?>(
                          value: item.id,
                          child: Text(item.name),
                        )),
                  ],
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Batas Nominal Per Bulan',
                    prefixText: 'Rp ',
                    prefixIcon: Icon(Icons.savings_outlined),
                  ),
                  onChanged: (val) {
                    final num = parseNumber(val);
                    if (val.isNotEmpty) {
                      final formatted = formatNumber(num);
                      if (formatted != val) {
                        _amountController.value = TextEditingValue(
                          text: formatted,
                          selection:
                              TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    }
                  },
                  validator: (value) {
                    final parsed = parseNumber(value ?? '');
                    return parsed <= 0
                        ? 'Masukkan batas anggaran yang valid.'
                        : null;
                  },
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: [500000, 1000000, 2000000, 5000000].map((val) {
                    return ActionChip(
                      label: Text(
                        formatRupiah(val),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      backgroundColor: const Color(0xFFF1F5F9),
                      side: BorderSide.none,
                      onPressed: () {
                        setState(() {
                          _amountController.text = formatNumber(val);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Simpan Anggaran'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.store, required this.budget});
  final FinanceStore store;
  final BudgetLimit budget;

  @override
  Widget build(BuildContext context) {
    final used = store.expenseForBudget(budget);
    final ratio = budget.limitAmount > 0 ? (used / budget.limitAmount) : 0.0;
    final category = store.getCategory(budget.categoryId);
    final isOver = ratio > 1.0;
    final isWarning = ratio >= 0.8 && !isOver;

    Color statusColor;
    if (isOver) {
      statusColor = AppColors.expense;
    } else if (isWarning) {
      statusColor = const Color(0xFFEAB308); // Amber
    } else {
      statusColor = AppColors.primary;
    }

    final categoryIcon = WalletHelper.getCategoryIcon(
        budget.categoryId, TransactionType.expense);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOver ? AppColors.expense.withValues(alpha: 0.4) : AppColors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.name ?? 'Semua Pengeluaran',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatRupiah(used)} dari ${formatRupiah(budget.limitAmount)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(ratio * 100).toInt()}%',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Hapus Anggaran',
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.textMuted, size: 20),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              color: statusColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOver
                    ? 'Melebihi batas ${formatRupiah(used - budget.limitAmount)}'
                    : 'Sisa kuota ${formatRupiah(budget.limitAmount - used)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: isOver ? AppColors.expense : AppColors.textSecondary,
                ),
              ),
              if (isOver)
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppColors.expense, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Overbudget',
                      style: TextStyle(
                        color: AppColors.expense,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Anggaran?'),
        content: const Text(
            'Apakah kamu yakin ingin menghapus batas anggaran ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () {
              Navigator.pop(ctx);
              store.deleteBudget(budget.id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
