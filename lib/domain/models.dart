enum TransactionType { income, expense, transfer }

class Wallet {
  const Wallet({
    required this.id,
    required this.name,
    required this.initialBalance,
    this.type = 'cash',
  });

  final String id;
  final String name;
  final int initialBalance;
  final String type;

  Wallet copyWith({
    String? id,
    String? name,
    int? initialBalance,
    String? type,
  }) =>
      Wallet(
        id: id ?? this.id,
        name: name ?? this.name,
        initialBalance: initialBalance ?? this.initialBalance,
        type: type ?? this.type,
      );

  Map<String, Object> toJson() => {
        'id': id,
        'name': name,
        'initialBalance': initialBalance,
        'type': type,
      };

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json['id'] as String,
        name: json['name'] as String,
        initialBalance: json['initialBalance'] as int? ?? 0,
        type: json['type'] as String? ?? 'cash',
      );
}

class Category {
  const Category({required this.id, required this.name, required this.type});

  final String id;
  final String name;
  final TransactionType type;

  Map<String, Object> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        type: TransactionType.values.byName(json['type'] as String),
      );
}

class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.walletId,
    required this.date,
    this.categoryId,
    this.destinationWalletId,
    this.note = '',
  });

  final String id;
  final TransactionType type;
  final int amount;
  final String walletId;
  final String? destinationWalletId;
  final String? categoryId;
  final DateTime date;
  final String note;

  Map<String, Object?> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'walletId': walletId,
        'destinationWalletId': destinationWalletId,
        'categoryId': categoryId,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) =>
      FinanceTransaction(
        id: json['id'] as String,
        type: TransactionType.values.byName(json['type'] as String),
        amount: json['amount'] as int,
        walletId: json['walletId'] as String,
        destinationWalletId: json['destinationWalletId'] as String?,
        categoryId: json['categoryId'] as String?,
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String? ?? '',
      );
}

class BudgetLimit {
  const BudgetLimit({
    required this.id,
    required this.month,
    required this.limitAmount,
    this.categoryId,
  });

  final String id;
  final DateTime month;
  final int limitAmount;
  final String? categoryId;

  Map<String, Object?> toJson() => {
        'id': id,
        'month': DateTime(month.year, month.month).toIso8601String(),
        'limitAmount': limitAmount,
        'categoryId': categoryId,
      };

  factory BudgetLimit.fromJson(Map<String, dynamic> json) => BudgetLimit(
        id: json['id'] as String,
        month: DateTime.parse(json['month'] as String),
        limitAmount: json['limitAmount'] as int,
        categoryId: json['categoryId'] as String?,
      );
}
