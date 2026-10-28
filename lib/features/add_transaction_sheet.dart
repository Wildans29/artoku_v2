import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../core/wallet_helpers.dart';
import '../data/finance_store.dart';
import '../domain/models.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({
    super.key,
    required this.store,
    this.initialType = TransactionType.expense,
  });

  final FinanceStore store;
  final TransactionType initialType;

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late TransactionType _type;
  String? _walletId;
  String? _destinationId;
  String? _categoryId;
  late DateTime _selectedDate;
  bool _saving = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallets = widget.store.wallets;
    final categories =
        widget.store.categories.where((item) => item.type == _type).toList();

    _walletId ??= wallets.firstOrNull?.id;
    final destinations =
        wallets.where((wallet) => wallet.id != _walletId).toList();
    if (!destinations.any((wallet) => wallet.id == _destinationId)) {
      _destinationId = destinations.firstOrNull?.id;
    }
    _categoryId ??= categories.firstOrNull?.id;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
              const SizedBox(height: 16),
              const Text(
                'Catat Transaksi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),

              // Segmented Button
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Pengeluaran'),
                    icon: Icon(Icons.north_east_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Pemasukan'),
                    icon: Icon(Icons.south_west_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.transfer,
                    label: Text('Transfer'),
                    icon: Icon(Icons.swap_horiz_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selected) => setState(() {
                  _type = selected.first;
                  _categoryId = null;
                  _inlineError = null;
                }),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      if (_type == TransactionType.income) {
                        return AppColors.incomeContainer;
                      }
                      if (_type == TransactionType.transfer) {
                        return AppColors.transferContainer;
                      }
                      return AppColors.expenseContainer;
                    }
                    return Colors.white;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      if (_type == TransactionType.income) {
                        return AppColors.income;
                      }
                      if (_type == TransactionType.transfer) {
                        return AppColors.transfer;
                      }
                      return AppColors.expense;
                    }
                    return AppColors.textSecondary;
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Amount Input
              TextFormField(
                controller: _amount,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Nominal',
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                  suffixIcon: _amount.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => setState(() => _amount.clear()),
                        )
                      : null,
                ),
                onChanged: (val) {
                  final num = parseNumber(val);
                  if (val.isNotEmpty) {
                    final formatted = formatNumber(num);
                    if (formatted != val) {
                      _amount.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  }
                  setState(() {});
                },
                validator: (value) {
                  final parsed = parseNumber(value ?? '');
                  if (parsed <= 0) return 'Masukkan nominal yang valid.';
                  if (_type == TransactionType.transfer && _walletId != null) {
                    final currentBal = widget.store.balanceFor(_walletId!);
                    if (currentBal < parsed) {
                      return 'Saldo dompet tidak mencukupi (Tersedia: ${formatRupiah(currentBal)})';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Quick Nominal Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [10000, 20000, 50000, 100000, 200000, 500000]
                      .map((val) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text(
                                formatRupiah(val),
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: BorderSide.none,
                              onPressed: () {
                                setState(() {
                                  _amount.text = formatNumber(val);
                                });
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Wallet Picker
              DropdownButtonFormField<String>(
                value: _walletId,
                decoration: InputDecoration(
                  labelText: _type == TransactionType.transfer
                      ? 'Dari Dompet'
                      : 'Sumber Dompet',
                  prefixIcon:
                      const Icon(Icons.account_balance_wallet_outlined),
                ),
                items: wallets.map((wallet) {
                  final bal = widget.store.balanceFor(wallet.id);
                  final opt = WalletHelper.getOption(wallet.type);
                  return DropdownMenuItem(
                    value: wallet.id,
                    child: Row(
                      children: [
                        Icon(opt.icon, size: 18, color: opt.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          '${wallet.name} (${formatRupiah(bal)})',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _walletId = value;
                  if (_destinationId == value) _destinationId = null;
                }),
              ),

              // Transfer Destination or Category
              if (_type == TransactionType.transfer) ...[
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  key: ValueKey('dest-$_walletId-$_destinationId'),
                  value: _destinationId,
                  decoration: const InputDecoration(
                    labelText: 'Ke Dompet Tujuan',
                    prefixIcon: Icon(Icons.move_to_inbox_outlined),
                  ),
                  items: destinations.map((wallet) {
                    final opt = WalletHelper.getOption(wallet.type);
                    return DropdownMenuItem(
                      value: wallet.id,
                      child: Row(
                        children: [
                          Icon(opt.icon, size: 18, color: opt.primaryColor),
                          const SizedBox(width: 8),
                          Text(wallet.name,
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _destinationId = value),
                ),
                if (destinations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      'Perlu minimal 2 dompet untuk melakukan transfer.',
                      style: TextStyle(
                          color: AppColors.expense,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ] else ...[
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: categories.map((cat) {
                    final catColor =
                        WalletHelper.getCategoryColor(cat.id, cat.type);
                    final catIcon =
                        WalletHelper.getCategoryIcon(cat.id, cat.type);
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Row(
                        children: [
                          Icon(catIcon, size: 18, color: catColor),
                          const SizedBox(width: 8),
                          Text(cat.name, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
              ],
              const SizedBox(height: 14),

              // Date Picker Field
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Transaksi',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 11),
                            ),
                            Text(
                              formatDate(_selectedDate),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Note Input
              TextFormField(
                controller: _note,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Contoh: Makan siang, Gaji bulanan, dsb.',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),

              if (_inlineError != null) ...[
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
                          _inlineError!,
                          style: const TextStyle(
                              color: AppColors.expense, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),

              FilledButton.icon(
                onPressed: _saving ||
                        wallets.isEmpty ||
                        (_type == TransactionType.transfer &&
                            destinations.isEmpty)
                    ? null
                    : _submit,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_saving ? 'Menyimpan...' : 'Simpan Transaksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          DateTime.now().hour,
          DateTime.now().minute,
        );
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = parseNumber(_amount.text);
    setState(() {
      _saving = true;
      _inlineError = null;
    });

    try {
      await widget.store.addTransaction(
        type: _type,
        amount: amount,
        walletId: _walletId!,
        destinationWalletId:
            _type == TransactionType.transfer ? _destinationId : null,
        categoryId: _type == TransactionType.transfer ? null : _categoryId,
        note: _note.text,
        date: _selectedDate,
      );
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dicatat.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (error) {
      setState(() {
        _saving = false;
        if (error is ArgumentError) {
          _inlineError = error.message?.toString() ?? 'Data tidak valid.';
        } else if (error is StateError) {
          _inlineError = error.message;
        } else {
          _inlineError = 'Gagal menyimpan transaksi. Silakan coba lagi.';
        }
      });
    }
  }
}
