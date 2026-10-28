import 'package:flutter/material.dart';
import '../domain/models.dart';
import 'theme.dart';

class WalletTypeOption {
  final String key;
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final Color primaryColor;

  const WalletTypeOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.primaryColor,
  });
}

class WalletHelper {
  static const List<WalletTypeOption> availableTypes = [
    WalletTypeOption(
      key: 'cash',
      label: 'Tunai',
      icon: Icons.payments_rounded,
      gradient: [Color(0xFF0D5C3A), Color(0xFF1B8A5A)],
      primaryColor: Color(0xFF0D5C3A),
    ),
    WalletTypeOption(
      key: 'bank',
      label: 'Bank',
      icon: Icons.account_balance_rounded,
      gradient: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
      primaryColor: Color(0xFF2563EB),
    ),
    WalletTypeOption(
      key: 'ewallet',
      label: 'E-Wallet',
      icon: Icons.account_balance_wallet_rounded,
      gradient: [Color(0xFF581C87), Color(0xFF9333EA)],
      primaryColor: Color(0xFF7E22CE),
    ),
    WalletTypeOption(
      key: 'savings',
      label: 'Tabungan',
      icon: Icons.savings_rounded,
      gradient: [Color(0xFF854D0E), Color(0xFFEAB308)],
      primaryColor: Color(0xFFCA8A04),
    ),
  ];

  static WalletTypeOption getOption(String type) {
    return availableTypes.firstWhere(
      (item) => item.key == type,
      orElse: () => availableTypes.first,
    );
  }

  static IconData getIcon(String type) => getOption(type).icon;

  static List<Color> getGradient(String type) => getOption(type).gradient;

  static Color getColor(String type) => getOption(type).primaryColor;

  static String getLabel(String type) => getOption(type).label;

  static IconData getCategoryIcon(String? categoryId, TransactionType type) {
    if (type == TransactionType.transfer) return Icons.swap_horiz_rounded;
    switch (categoryId) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'entertainment':
        return Icons.movie_filter_rounded;
      case 'salary':
        return Icons.payments_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'other_income':
        return Icons.account_balance_wallet_rounded;
      default:
        return type == TransactionType.income
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded;
    }
  }

  static Color getCategoryColor(String? categoryId, TransactionType type) {
    if (type == TransactionType.transfer) return AppColors.transfer;
    if (type == TransactionType.income) return AppColors.income;
    switch (categoryId) {
      case 'food':
        return const Color(0xFFF97316); // Orange
      case 'transport':
        return const Color(0xFF0284C7); // Sky
      case 'shopping':
        return const Color(0xFFEC4899); // Pink
      case 'bills':
        return const Color(0xFFEAB308); // Amber
      case 'entertainment':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return AppColors.expense;
    }
  }
}
