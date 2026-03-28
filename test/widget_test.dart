// App-level widget smoke tests.
// These verify that core reusable widgets render without errors.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikibina/widgets/common/custom_button.dart';
import 'package:ikibina/widgets/common/custom_text_field.dart';
import 'package:ikibina/widgets/common/loading_indicator.dart';

void main() {
  // ──────────────────────────────────────────
  // CustomButton smoke tests
  // ──────────────────────────────────────────
  group('CustomButton smoke tests', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CustomButton(label: 'Test')),
      ));
      expect(find.byType(CustomButton), findsOneWidget);
    });

    testWidgets('label is visible', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CustomButton(label: 'Submit')),
      ));
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('loading state hides label and shows spinner', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CustomButton(label: 'Submit', loading: true)),
      ));
      expect(find.text('Submit'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────
  // CustomTextField smoke tests
  // ──────────────────────────────────────────
  group('CustomTextField smoke tests', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CustomTextField(label: 'Name')),
      ));
      expect(find.byType(CustomTextField), findsOneWidget);
    });

    testWidgets('label is visible', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CustomTextField(label: 'Full Name')),
      ));
      expect(find.text('Full Name'), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────
  // LoadingIndicator smoke tests
  // ──────────────────────────────────────────
  group('LoadingIndicator smoke tests', () {
    testWidgets('renders spinner without message', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: LoadingIndicator()),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders spinner with optional message', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: LoadingIndicator(message: 'Please wait...')),
      ));
      expect(find.text('Please wait...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
