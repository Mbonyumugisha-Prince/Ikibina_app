import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikibina/widgets/common/custom_text_field.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('CustomTextField', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        const CustomTextField(label: 'Email'),
      ));
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders hint text when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const CustomTextField(label: 'Email', hint: 'Enter your email'),
      ));
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('renders prefix icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const CustomTextField(label: 'Email', prefixIcon: Icons.email),
      ));
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('no prefix icon when not provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const CustomTextField(label: 'Name'),
      ));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('accepts user input via controller', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_wrap(
        CustomTextField(label: 'Name', controller: controller),
      ));
      await tester.enterText(find.byType(TextFormField), 'Jean');
      expect(controller.text, 'Jean');
    });

    testWidgets('shows validation error message on validate', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: CustomTextField(
              label: 'Name',
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Name is required' : null,
            ),
          ),
        ),
      ));
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(_wrap(
        const CustomTextField(label: 'Password', obscureText: true),
      ));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
    });

    testWidgets('uses numeric keyboard when keyboardType is number',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const CustomTextField(
          label: 'Amount',
          keyboardType: TextInputType.number,
        ),
      ));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.number);
    });
  });
}
