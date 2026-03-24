import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../config/routes.dart';
import '../../services/firestore_service.dart';
import '../../widgets/cards/contribution_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../core/utils/formatters.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final theme = Theme.of(context);
    final s = context.watch<LocaleProvider>().strings;

    return FutureBuilder(
      future: service.getGroup(groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingIndicator());
        }
        final group = snapshot.data;
        if (group == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(s.groupNotFound)),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(group.name)),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                color: theme.colorScheme.primaryContainer,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      Formatters.currency(group.totalSavings),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(s.totalSavings),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _statChip(Icons.group, '${group.memberCount} members'),
                        const SizedBox(width: 16),
                        _statChip(Icons.repeat, group.contributionFrequency),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: service.getGroupContributions(groupId),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const LoadingIndicator();
                    }
                    final contributions = snap.data ?? [];
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: contributions.length,
                      itemBuilder: (_, i) =>
                          ContributionCard(contribution: contributions[i]),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push(AppRoutes.addContribution),
            icon: const Icon(Icons.add),
            label: Text(s.addContribution),
          ),
        );
      },
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
