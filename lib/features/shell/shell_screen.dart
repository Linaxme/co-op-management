import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_screen.dart';
import '../members/members_screen.dart';
import '../due/due_report_screen.dart';
import '../reports/reports_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int index = 0;

  final pages = const [
    DashboardScreen(),
    MembersScreen(),
    DueReportScreen(),
    ReportsScreen(),
  ];

  bool get _showAddDepositFab => index == 0 || index == 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      floatingActionButton: _showAddDepositFab
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/add-deposit'),
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.addDeposit),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard),
              label: AppLocalizations.of(context)!.dashboard),
          NavigationDestination(
              icon: const Icon(Icons.people_alt_outlined),
              selectedIcon: const Icon(Icons.people_alt),
              label: AppLocalizations.of(context)!.members),
          NavigationDestination(
              icon: const Icon(Icons.warning_amber_outlined),
              selectedIcon: const Icon(Icons.warning_amber),
              label: AppLocalizations.of(context)!.due),
          NavigationDestination(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              selectedIcon: const Icon(Icons.picture_as_pdf),
              label: AppLocalizations.of(context)!.reports),
        ],
      ),
    );
  }
}
