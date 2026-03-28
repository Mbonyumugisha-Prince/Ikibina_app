import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikibina/widgets/common/custom_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('CustomButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        const CustomButton(label: 'Save'),
      ));
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('renders ElevatedButton by default', (tester) async {
      await tester.pumpWidget(_wrap(
        const CustomButton(label: 'Save'),
      ));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders OutlinedButton when outlined is true', (tester) async {
      await tester.pumpWidget(_wrap(
        const CustomButton(label: 'Cancel', outlined: true),
      ));
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(_wrap(
        const CustomButton(label: 'Save', loading: true),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // label is hidden while loading
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(_wrap(
        CustomButton(label: 'Go', onPressed: () => pressed = true),
      ));
      await tester.tap(find.text('Go'));
      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(_wrap(
        CustomButton(
          label: 'Go',
          loading: true,
          onPressed: () => pressed = true,
        ),
      ));
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      expect(pressed, isFalse);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const CustomButton(label: 'Add', icon: Icons.add),
      ));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('no icon when icon is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const CustomButton(label: 'Save'),
      ));
      expect(find.byType(Icon), findsNothing);
    });
  });
}
