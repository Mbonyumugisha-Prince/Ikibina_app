import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/locale_provider.dart';
import '../../config/routes.dart';
import '../../widgets/cards/group_card.dart';
import '../../widgets/common/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<GroupProvider>().loadUserGroups(auth.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final groupProvider = context.watch<GroupProvider>();
    final s = context.watch<LocaleProvider>().strings;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.ikibina),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home tab
          RefreshIndicator(
            onRefresh: () async {
              if (auth.user != null) {
                context.read<GroupProvider>().loadUserGroups(auth.user!.id);
              }
            },
            child: groupProvider.loading
                ? LoadingIndicator(message: s.loadingGroup)
                : groupProvider.groups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.group_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(s.noGroupsYet,
                                style: theme.textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(s.createOrJoinGroup,
                                style: theme.textTheme.bodySmall),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.push(AppRoutes.createGroup),
                              icon: const Icon(Icons.add),
                              label: Text(s.createGroup),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: groupProvider.groups.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GroupCard(
                            group: groupProvider.groups[i],
                            onTap: () => context.push(
                                '/groups/${groupProvider.groups[i].id}'),
                          ),
                        ),
                      ),
          ),
          // Groups tab
          Center(child: Text(s.groups)),
          // Transactions tab
          Center(child: Text(s.transactions)),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.createGroup),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.group_outlined), label: 'Groups'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), label: 'Transactions'),
        ],
      ),
    );
  }
}
