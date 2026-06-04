import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turon_suv/app.dart';

void main() {
  testWidgets('App boots to Splash placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TuronSuvApp()));
    await tester.pumpAndSettle();
    expect(find.text('Splash — qurilmoqda'), findsOneWidget);
  });
}
