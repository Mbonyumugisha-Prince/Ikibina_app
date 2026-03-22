import 'package:flutter/material.dart';
import '../../models/contribution_model.dart';
import '../../core/utils/formatters.dart';

class ContributionCard extends StatelessWidget {
  final ContributionModel contribution;

  const ContributionCard({super.key, required this.contribution});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            contribution.userName[0].toUpperCase(),
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
        title: Text(contribution.userName),
        subtitle: Text(Formatters.date(contribution.date)),
        trailing: Text(
          Formatters.currency(contribution.amount),
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
