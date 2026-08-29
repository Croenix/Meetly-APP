import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetly/app/app.dart';

void main() {
  testWidgets('Meetly App Splash Screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MeetlyApp(),
      ),
    );

    // Verify that the splash screen displays the Meetly brand name and slogan
    expect(find.text('Meetly'), findsOneWidget);
    expect(find.text('Connect. Collaborate. Grow.'), findsOneWidget);

    // Advance the mock clock to let the splash redirection timer (2500ms) fire
    // and clean up pending timers before test tear-down.
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();
  });
}
