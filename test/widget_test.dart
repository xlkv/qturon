import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turon_suv/app.dart';

void main() {
  testWidgets('App boots and renders Splash logo', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TuronSuvApp()));
    await tester.pump();
    expect(find.text('Turon Suv'), findsOneWidget);
    expect(find.text('TS'), findsOneWidget);
  });
}
