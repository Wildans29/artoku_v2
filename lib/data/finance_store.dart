import 'dart:convert';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

class FinanceStore extends ChangeNotifier {
  static const _walletsKey = 'wallets_v1';
  static const _categoriesKey = 'categories_v1';
  static const _transactionsKey = 'transactions_v1';
  static const _budgetsKey = 'budgets_v1';

  final List<Wallet> _wallets = [];
  final List<Category> _categories = [];
  final List<FinanceTransaction> _transactions = [];
  final List<BudgetLimit> _budgets = [];
  bool isReady = false;

  List<Wallet> get wallets => List.unmodifiable(_wallets);
  List<Category> get categories => List.unmodifiable(_categories);
  List<FinanceTransaction> get transactions {
    final result = [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(result);
  }
  List<BudgetLimit> get budgets => List.unmodifiable(_budgets);

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _wallets
      ..clear()
      ..addAll(
          _decodeList(preferences.getString(_walletsKey), Wallet.fromJson));
    _categories
      ..clear()
      ..addAll(_decodeList(
          preferences.getString(_categoriesKey), Category.fromJson));
    _transactions
      ..clear()
      ..addAll(_decodeList(preferences.getString(_transactionsKey),
          FinanceTransaction.fromJson));
    _budgets
      ..clear()
      ..addAll(_decodeList(
          preferences.getString(_budgetsKey), BudgetLimit.fromJson));

    if (_wallets.isEmpty) {
      _wallets.add(const Wallet(
        id: 'cash',
        name: 'Tunai',
        initialBalance: 0,
        type: 'cash',
      ));
    }
    if (_categories.isEmpty) {
      _categories.addAll(const [
        Category(
            id: 'food',
            name: 'Makanan & Minuman',
            type: TransactionType.expense),
        Category(
            id: 'transport',
            name: 'Transportasi',
            type: TransactionType.expense),
        Category(
            id: 'shopping', name: 'Belanja', type: TransactionType.expense),
        Category(
            id: 'bills', name: 'Tagihan & Utilitas', type: TransactionType.expense),
        Category(
            id: 'entertainment', name: 'Hiburan', type: TransactionType.expense),
        Category(id: 'salary', name: 'Gaji', type: TransactionType.income),
        Category(
            id: 'investment', name: 'Investasi', type: TransactionType.income),
        Category(
            id: 'other_income',
            name: 'Pemasukan Lain',
            type: TransactionType.income),
      ]);
    }
    await _save();
    isReady = true;
    notifyListeners();
  }

  Wallet? getWallet(String id) =>
      _wallets.where((item) => item.id == id).firstOrNull;

  Category? getCategory(String? id) =>
      _categories.where((item) => item.id == id).firstOrNull;

  int balanceFor(String walletId) {
    final wallet = _wallets.where((item) => item.id == walletId).firstOrNull;
    if (wallet == null) return 0;

    var balance = wallet.initialBalance;
    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.income &&
          transaction.walletId == walletId) {
        balance += transaction.amount;
      } else if (transaction.type == TransactionType.expense &&
          transaction.walletId == walletId) {
        balance -= transaction.amount;
      } else if (transaction.type == TransactionType.transfer) {
        if (transaction.walletId == walletId) {
          balance -= transaction.amount;
        }
        if (transaction.destinationWalletId == walletId) {
          balance += transaction.amount;
        }
      }
    }
    return balance;
  }

  int get totalBalance =>
      _wallets.fold(0, (total, wallet) => total + balanceFor(wallet.id));

  int totalForMonth(TransactionType type, DateTime month) => _transactions
      .where((item) =>
          item.type == type &&
          item.date.year == month.year &&
          item.date.month == month.month)
      .fold(0, (total, item) => total + item.amount);

  int expenseForBudget(BudgetLimit budget) => _transactions
      .where((item) =>
          item.type == TransactionType.expense &&
          item.date.year == budget.month.year &&
          item.date.month == budget.month.month &&
          (budget.categoryId == null || item.categoryId == budget.categoryId))
      .fold(0, (total, item) => total + item.amount);

  Map<String, int> expensesByCategory(DateTime month) {
    final map = <String, int>{};
    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.expense &&
          transaction.date.year == month.year &&
          transaction.date.month == month.month) {
        final key = transaction.categoryId ?? 'uncategorized';
        map[key] = (map[key] ?? 0) + transaction.amount;
      }
    }
    return map;
  }

  List<FinanceTransaction> transactionsForWallet(String walletId) =>
      transactions.where((tx) =>
          tx.walletId == walletId || tx.destinationWalletId == walletId).toList();

  Future<void> setBudget({
    required DateTime month,
    required int limitAmount,
    String? categoryId,
  }) async {
    if (limitAmount <= 0) {
      throw ArgumentError('Batas anggaran harus lebih dari nol.');
    }
    if (categoryId != null &&
        !_categories.any((item) =>
            item.id == categoryId && item.type == TransactionType.expense)) {
      throw ArgumentError('Kategori anggaran tidak valid.');
    }
    final normalizedMonth = DateTime(month.year, month.month);
    _budgets.removeWhere((item) =>
        item.month.year == normalizedMonth.year &&
        item.month.month == normalizedMonth.month &&
        item.categoryId == categoryId);
    _budgets.add(BudgetLimit(
      id: '${normalizedMonth.year}-${normalizedMonth.month}-${categoryId ?? 'all'}',
      month: normalizedMonth,
      limitAmount: limitAmount,
      categoryId: categoryId,
    ));
    await _save();
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((item) => item.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> addTransaction({
    required TransactionType type,
    required int amount,
    required String walletId,
    String? destinationWalletId,
    String? categoryId,
    String note = '',
    DateTime? date,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Nominal harus lebih dari nol.');
    }
    if (!_wallets.any((item) => item.id == walletId)) {
      throw ArgumentError('Dompet tidak valid.');
    }
    if (type == TransactionType.transfer) {
      if (balanceFor(walletId) < amount) {
        throw StateError('Saldo dompet tidak mencukupi.');
      }
      if (destinationWalletId == null ||
          destinationWalletId == walletId ||
          !_wallets.any((item) => item.id == destinationWalletId)) {
        throw ArgumentError('Dompet tujuan transfer tidak valid.');
      }
      categoryId = null;
    } else {
      if (categoryId != null &&
          !_categories.any((item) => item.id == categoryId && item.type == type)) {
        throw ArgumentError('Kategori transaksi tidak valid.');
      }
      destinationWalletId = null;
    }
    final transaction = FinanceTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      amount: amount,
      walletId: walletId,
      destinationWalletId: destinationWalletId,
      categoryId: categoryId,
      date: date ?? DateTime.now(),
      note: note.trim(),
    );
    _transactions.add(transaction);
    try {
      await _save();
    } catch (_) {
      _transactions.removeWhere((item) => item.id == transaction.id);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> addWallet(
    String name,
    int initialBalance, {
    String type = 'cash',
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) throw ArgumentError('Nama dompet wajib diisi.');
    if (initialBalance < 0) {
      throw ArgumentError('Saldo awal tidak boleh negatif.');
    }
    if (_wallets.any(
        (item) => item.name.toLowerCase() == trimmedName.toLowerCase())) {
      throw ArgumentError('Nama dompet sudah digunakan.');
    }
    final wallet = Wallet(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: trimmedName,
      initialBalance: initialBalance,
      type: type,
    );
    _wallets.add(wallet);
    try {
      await _save();
    } catch (_) {
      _wallets.removeWhere((item) => item.id == wallet.id);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> updateWallet(
    String id, {
    required String name,
    required int initialBalance,
    String? type,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) throw ArgumentError('Nama dompet wajib diisi.');
    if (initialBalance < 0) {
      throw ArgumentError('Saldo awal tidak boleh negatif.');
    }
    final index = _wallets.indexWhere((item) => item.id == id);
    if (index < 0) throw ArgumentError('Dompet tidak ditemukan.');

    if (_wallets.any((item) =>
        item.id != id && item.name.toLowerCase() == trimmedName.toLowerCase())) {
      throw ArgumentError('Nama dompet sudah digunakan.');
    }

    final oldWallet = _wallets[index];
    final updated = oldWallet.copyWith(
      name: trimmedName,
      initialBalance: initialBalance,
      type: type ?? oldWallet.type,
    );
    _wallets[index] = updated;
    try {
      await _save();
    } catch (_) {
      _wallets[index] = oldWallet;
      rethrow;
    }
    notifyListeners();
  }

  Future<void> deleteWallet(String id) async {
    if (_wallets.length <= 1) {
      throw StateError('Anda harus memiliki minimal satu dompet aktif.');
    }
    final index = _wallets.indexWhere((item) => item.id == id);
    if (index < 0) return;

    final hasTransactions = _transactions.any(
        (tx) => tx.walletId == id || tx.destinationWalletId == id);
    if (hasTransactions) {
      throw StateError(
          'Dompet memiliki riwayat transaksi dan tidak dapat dihapus.');
    }

    final removed = _wallets.removeAt(index);
    try {
      await _save();
    } catch (_) {
      _wallets.insert(index, removed);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final removed = _transactions.removeAt(index);
    try {
      await _save();
    } catch (_) {
      _transactions.insert(index, removed);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> restoreTransaction(FinanceTransaction tx) async {
    _transactions.add(tx);
    await _save();
    notifyListeners();
  }

  Future<void> resetAllData() async {
    _wallets.clear();
    _categories.clear();
    _transactions.clear();
    _budgets.clear();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_walletsKey);
    await preferences.remove(_categoriesKey);
    await preferences.remove(_transactionsKey);
    await preferences.remove(_budgetsKey);
    await load();
  }

  Future<void> _save() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_walletsKey,
        jsonEncode(_wallets.map((item) => item.toJson()).toList()));
    await preferences.setString(_categoriesKey,
        jsonEncode(_categories.map((item) => item.toJson()).toList()));
    await preferences.setString(
      _transactionsKey,
      jsonEncode(_transactions.map((item) => item.toJson()).toList()),
    );
    await preferences.setString(
      _budgetsKey,
      jsonEncode(_budgets.map((item) => item.toJson()).toList()),
    );
  }

  List<T> _decodeList<T>(
      String? source, T Function(Map<String, dynamic>) decoder) {
    if (source == null) return [];
    try {
      return (jsonDecode(source) as List<dynamic>)
          .map((item) => decoder(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
