import 'package:artoku_v2/data/finance_store.dart';
import 'package:artoku_v2/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FinanceStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = FinanceStore();
    await store.load();
  });

  test('seeds default wallet and categories', () {
    expect(store.wallets, hasLength(1));
    expect(store.wallets.single.name, 'Tunai');
    expect(store.categories, isNotEmpty);
  });

  test('income and expense update wallet balance with integer rupiah',
      () async {
    await store.addTransaction(
        type: TransactionType.income, amount: 1500000, walletId: 'cash');
    await store.addTransaction(
        type: TransactionType.expense, amount: 350000, walletId: 'cash');

    expect(store.balanceFor('cash'), 1150000);
  });

  test('transfer moves balance without changing total wealth', () async {
    await store.addWallet('Bank', 0);
    await store.addTransaction(
        type: TransactionType.income, amount: 500000, walletId: 'cash');
    final beforeTransfer = store.totalBalance;

    await store.addTransaction(
      type: TransactionType.transfer,
      amount: 200000,
      walletId: 'cash',
      destinationWalletId: store.wallets.last.id,
    );

    expect(store.balanceFor('cash'), 300000);
    expect(store.balanceFor(store.wallets.last.id), 200000);
    expect(store.totalBalance, beforeTransfer);
  });

  test('rejects transfer greater than available wallet balance', () async {
    await expectLater(
      store.addTransaction(
        type: TransactionType.transfer,
        amount: 100,
        walletId: 'cash',
        destinationWalletId: 'other',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('can update and delete wallet safely', () async {
    await store.addWallet('Bank BCA', 100000, type: 'bank');
    final bca = store.wallets.firstWhere((w) => w.name == 'Bank BCA');
    expect(bca.initialBalance, 100000);

    await store.updateWallet(bca.id, name: 'BCA Utama', initialBalance: 150000, type: 'bank');
    expect(store.wallets.firstWhere((w) => w.id == bca.id).name, 'BCA Utama');
    expect(store.balanceFor(bca.id), 150000);

    // Can delete wallet without transactions
    await store.deleteWallet(bca.id);
    expect(store.wallets.any((w) => w.id == bca.id), isFalse);

    // Cannot delete the only remaining wallet
    await expectLater(store.deleteWallet('cash'), throwsA(isA<StateError>()));
  });
}
