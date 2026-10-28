import 'package:artoku_v2/app.dart';
import 'package:artoku_v2/data/finance_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ARTOKU V2 opens dashboard successfully', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('id_ID');
    final store = FinanceStore();
    await store.load();

    await tester.pumpWidget(ArtokuApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('Total kekayaan'), findsOneWidget);
    expect(find.text('Dompet saya'), findsOneWidget);
    expect(find.text('Aktivitas terbaru'), findsOneWidget);
    expect(find.text('ARTOKU V2'), findsNothing);
  });
}
