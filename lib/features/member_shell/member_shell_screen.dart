import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../deposits/add_deposit_screen.dart';
import '../members/member_detail_screen.dart';
import 'member_dashboard_screen.dart';
import 'member_due_screen.dart';
import 'member_settings_screen.dart';

enum MemberShellTab { dashboard, due, collect, profile, settings }

class MemberShellScreen extends ConsumerStatefulWidget {
  final MemberShellTab initialTab;
  const MemberShellScreen({
    super.key,
    this.initialTab = MemberShellTab.dashboard,
  });

  @override
  ConsumerState<MemberShellScreen> createState() => _MemberShellScreenState();
}

class _MemberShellScreenState extends ConsumerState<MemberShellScreen> {
  late int index;

  @override
  void initState() {
    super.initState();
    index = 0;
  }

  int _tabIndex(MemberShellTab tab, bool canCollect) {
    switch (tab) {
      case MemberShellTab.dashboard:
        return 0;
      case MemberShellTab.due:
        return 1;
      case MemberShellTab.collect:
        return canCollect ? 2 : 0;
      case MemberShellTab.profile:
        return canCollect ? 3 : 2;
      case MemberShellTab.settings:
        return canCollect ? 4 : 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberUuid = ref.watch(currentMemberUuidProvider);
    final canCollectAsync = ref.watch(canCollectDepositsProvider);
    final l10n = AppLocalizations.of(context)!;

    if (memberUuid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final canCollect = canCollectAsync.value ?? false;

    if (index == 0 && widget.initialTab != MemberShellTab.dashboard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => index = _tabIndex(widget.initialTab, canCollect));
        }
      });
    }

    final pages = <Widget>[
      MemberDashboardScreen(memberUuid: memberUuid),
      MemberDueScreen(memberUuid: memberUuid),
      if (canCollect)
        const AddDepositScreen(memberCollectorMode: true),
      MemberDetailScreen(memberUuid: memberUuid, readOnly: true),
      const MemberSettingsScreen(),
    ];

    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: l10n.dashboard,
      ),
      NavigationDestination(
        icon: const Icon(Icons.warning_amber_outlined),
        selectedIcon: const Icon(Icons.warning_amber),
        label: l10n.due,
      ),
      if (canCollect)
        NavigationDestination(
          icon: const Icon(Icons.payments_outlined),
          selectedIcon: const Icon(Icons.payments),
          label: l10n.collectDeposit,
        ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: l10n.myProfile,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l10n.settings,
      ),
    ];

    final safeIndex = index.clamp(0, pages.length - 1);

    return Scaffold(
      body: pages[safeIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: destinations,
      ),
    );
  }
}
