import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ikibina/models/group_model.dart';
import 'package:ikibina/providers/locale_provider.dart';
import 'package:ikibina/widgets/cards/group_card.dart';

GroupModel _sampleGroup({
  String name = 'Savings A',
  List<String> members = const ['user1', 'user2'],
  double totalSavings = 10000,
  String frequency = 'Monthly',
}) =>
    GroupModel(
      id: 'g1',
      name: name,
      description: 'Test group',
      createdBy: 'user1',
      contributionAmount: 5000,
      contributionFrequency: frequency,
      createdAt: DateTime(2024, 1, 1),
      members: members,
      totalSavings: totalSavings,
    );

Widget _wrap(GroupModel group, {VoidCallback? onTap}) {
  return MaterialApp(
    home: Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: GroupCard(group: group, onTap: onTap),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GroupCard', () {
    testWidgets('displays group name', (tester) async {
      await tester.pumpWidget(_wrap(_sampleGroup()));
      await tester.pump();
      expect(find.text('Savings A'), findsOneWidget);
    });

    testWidgets('displays member count in subtitle', (tester) async {
      await tester.pumpWidget(_wrap(_sampleGroup()));
      await tester.pump();
      expect(find.textContaining('2 members'), findsOneWidget);
    });

    testWidgets('displays contribution frequency in subtitle', (tester) async {
      await tester.pumpWidget(_wrap(_sampleGroup(frequency: 'Weekly')));
      await tester.pump();
      expect(find.textContaining('Weekly'), findsOneWidget);
    });

    testWidgets('displays formatted total savings amount', (tester) async {
      await tester.pumpWidget(_wrap(_sampleGroup(totalSavings: 10000)));
      await tester.pump();
      expect(find.textContaining('10,000'), findsOneWidget);
    });

    testWidgets('shows first letter of group name as avatar fallback',
        (tester) async {
      await tester.pumpWidget(_wrap(_sampleGroup(name: 'Bright Future')));
      await tester.pump();
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        _sampleGroup(),
        onTap: () => tapped = true,
      ));
      await tester.pump();
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('renders a Card widget', (tester) async {
      await tester.pumpWidget(_wrap(_sampleGroup()));
      await tester.pump();
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
