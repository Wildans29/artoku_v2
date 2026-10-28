import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/finance_store.dart';
import 'add_transaction_sheet.dart';
import 'budget_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'transactions_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.store});

  final FinanceStore store;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = [
    'Beranda',
    'Riwayat Transaksi',
    'Target Anggaran',
    'Statistik Keuangan'
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final screens = [
          DashboardScreen(
            store: widget.store,
            onNavigateToTransactions: () => setState(() => _index = 1),
            onNavigateToBudget: () => setState(() => _index = 2),
          ),
          TransactionsScreen(store: widget.store),
          BudgetScreen(store: widget.store),
          StatisticsScreen(store: widget.store),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _titles[_index],
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Pengaturan',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SettingsScreen(store: widget.store),
                )),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(Icons.tune_rounded, size: 20),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: IndexedStack(index: _index, children: screens),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddTransactionSheet(store: widget.store),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Catat',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Transaksi',
              ),
              NavigationDestination(
                icon: Icon(Icons.pie_chart_outline_rounded),
                selectedIcon: Icon(Icons.pie_chart_rounded),
                label: 'Anggaran',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart_rounded),
                label: 'Statistik',
              ),
            ],
          ),
        );
      },
    );
  }
}
