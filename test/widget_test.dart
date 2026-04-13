import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gamified_js_learning/app.dart';

void main() {
  testWidgets('Bloom app smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope (required by Riverpod)
    await tester.pumpWidget(
      const ProviderScope(child: BloomApp()),
    );

    // Verify the app renders without crashing
    expect(find.byType(BloomApp), findsOneWidget);
  });
}