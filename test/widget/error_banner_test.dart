import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikibina/widgets/common/error_banner.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('ErrorBanner', () {
    testWidgets('renders the provided message', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(message: 'Something went wrong'),
      ));
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('renders an error icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(message: 'Error'),
      ));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders a Container as its root widget', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(message: 'Error'),
      ));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders a Text widget inside a Row', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(message: 'Network error'),
      ));
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('displays a long message without overflow', (tester) async {
      const longMessage =
          'An unexpected error occurred while processing your request. '
          'Please check your internet connection and try again later.';
      await tester.pumpWidget(_wrap(
        const ErrorBanner(message: longMessage),
      ));
      expect(find.text(longMessage), findsOneWidget);
      // No overflow exceptions — pumpWidget would throw if the widget overflowed
    });

    testWidgets('displays different messages independently', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(message: 'Incorrect code'),
      ));
      expect(find.text('Incorrect code'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });

    testWidgets('uses red-toned color scheme (icon is red)', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(message: 'Error'),
      ));
      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, const Color(0xFFC62828));
    });

    testWidgets('is a StatelessWidget', (tester) async {
      await tester.pumpWidget(_wrap(
        const ErrorBanner(message: 'Error'),
      ));
      expect(find.byType(ErrorBanner), findsOneWidget);
      final widget = tester.widget(find.byType(ErrorBanner));
      expect(widget, isA<StatelessWidget>());
    });
  });
}
