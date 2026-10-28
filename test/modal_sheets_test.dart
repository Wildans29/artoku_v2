import 'package:artoku_v2/app.dart';
import 'package:artoku_v2/data/finance_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('id_ID');
  });

  testWidgets('Test add wallet sheet lifecycle and submission', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = FinanceStore();
    await store.load();

    await tester.pumpWidget(ArtokuApp(store: store));
    await tester.pumpAndSettle();

    // Tap + Dompet action
    final addWalletButton = find.text('+ Dompet');
    await tester.tap(addWalletButton);
    await tester.pumpAndSettle();

    // Enter name
    final nameField = find.byType(TextFormField).first;
    await tester.enterText(nameField, 'BCA Baru');
    await tester.pumpAndSettle();

    // Tap Tambah Dompet in the sheet
    final submitButton = find.text('Tambah Dompet').last;
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(store.wallets.any((w) => w.name == 'BCA Baru'), isTrue);
  });

  testWidgets('Test add transaction sheet lifecycle and submission', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = FinanceStore();
    await store.load();

    await tester.pumpWidget(ArtokuApp(store: store));
    await tester.pumpAndSettle();

    // Tap floating action button (+) to open transaction sheet
    final fab = find.byType(FloatingActionButton);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Enter amount
    final amountField = find.byType(TextFormField).first;
    await tester.enterText(amountField, '50000');
    await tester.pumpAndSettle();

    // Submit transaction
    final saveButton = find.text('Simpan Transaksi');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(store.transactions.any((tx) => tx.amount == 50000), isTrue);
  });

  testWidgets('Test budget form sheet lifecycle and submission', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = FinanceStore();
    await store.load();

    await tester.pumpWidget(ArtokuApp(store: store));
    await tester.pumpAndSettle();

    // Navigate to Budget tab (index 2: Anggaran)
    final budgetTab = find.byType(NavigationDestination).at(2);
    await tester.tap(budgetTab);
    await tester.pumpAndSettle();

    // Tap Atur button in BudgetScreen
    final addBudgetButton = find.text('Atur');
    await tester.tap(addBudgetButton);
    await tester.pumpAndSettle();

    // Enter budget amount
    final amountField = find.byType(TextFormField).first;
    await tester.enterText(amountField, '1000000');
    await tester.pumpAndSettle();

    // Tap Simpan Anggaran
    final saveButton = find.text('Simpan Anggaran');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(store.budgets.any((b) => b.limitAmount == 1000000), isTrue);
  });
}
