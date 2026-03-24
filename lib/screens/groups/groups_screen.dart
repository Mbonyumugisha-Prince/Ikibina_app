import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/locale_provider.dart';
import '../../config/routes.dart';
import '../../widgets/cards/group_card.dart';
import '../../widgets/common/loading_indicator.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final s = context.watch<LocaleProvider>().strings;

    return Scaffold(
      appBar: AppBar(title: Text(s.myGroupsTitle)),
      body: groupProvider.loading
          ? const LoadingIndicator()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupProvider.groups.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GroupCard(
                  group: groupProvider.groups[i],
                  onTap: () =>
                      context.push('/groups/${groupProvider.groups[i].id}'),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createGroup),
        child: const Icon(Icons.add),
      ),
    );
  }
}
