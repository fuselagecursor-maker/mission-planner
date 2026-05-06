import 'package:flutter/material.dart';

import '../../../core/ui/app_spacing.dart';
import '../../../core/routing/app_router.dart';
import '../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../map/presentation/screens/map_screen.dart';
import '../../mission/presentation/screens/missions_screen.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../tasks/presentation/screens/tasks_screen.dart';
import 'widgets/dashboard_scaffold.dart';
import 'widgets/sidebar_nav.dart';
import 'widgets/top_navbar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _tabKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());

  Future<bool> _onWillPop() async {
    final navigator = _tabKeys[_index].currentState;
    if (navigator == null) return true;
    if (navigator.canPop()) {
      navigator.pop();
      return false;
    }
    return true;
  }

  void _selectTab(int next) {
    if (next < 0 || next > 4) return;
    if (next == _index) {
      _tabKeys[next].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _index = next);
  }

  void _onTap(int next) => _selectTab(next);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useDashboardLayout = width >= 980;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPopApp = await _onWillPop();
        if (!context.mounted) return;
        if (shouldPopApp) {
          Navigator.of(context).maybePop();
        }
      },
      child: useDashboardLayout
          ? DashboardScaffold(
              sidebar: SidebarNav(
                selectedIndex: _index,
                onSelect: _onTap,
                destinations: const [
                  SidebarNavDestination(icon: Icons.dashboard_rounded, label: 'Dashboard'),
                  SidebarNavDestination(icon: Icons.flag_rounded, label: 'Missions'),
                  SidebarNavDestination(icon: Icons.map_rounded, label: 'Map'),
                  SidebarNavDestination(icon: Icons.assignment_rounded, label: 'Tasks'),
                  SidebarNavDestination(icon: Icons.settings_rounded, label: 'Settings'),
                ],
              ),
              topbar: TopNavbar(title: _titleForIndex(_index)),
              body: _DashboardBody(
                index: _index,
                tabKeys: _tabKeys,
                onSelectTab: _selectTab,
              ),
            )
          : Scaffold(
              body: IndexedStack(
                index: _index,
                children: [
                  _TabNavigator(
                    navigatorKey: _tabKeys[0],
                    child: DashboardScreen(onNavigateToTab: _selectTab),
                  ),
                  _TabNavigator(
                    navigatorKey: _tabKeys[1],
                    child: const MissionsScreen(),
                  ),
                  _TabNavigator(
                    navigatorKey: _tabKeys[2],
                    child: const MapScreen(),
                  ),
                  _TabNavigator(
                    navigatorKey: _tabKeys[3],
                    child: const TasksScreen(),
                  ),
                  _TabNavigator(
                    navigatorKey: _tabKeys[4],
                    child: const SettingsScreen(),
                  ),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: _onTap,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.flag_outlined),
                    selectedIcon: Icon(Icons.flag),
                    label: 'Missions',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.map_outlined),
                    selectedIcon: Icon(Icons.map),
                    label: 'Map',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.assignment_outlined),
                    selectedIcon: Icon(Icons.assignment),
                    label: 'Tasks',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
              floatingActionButton: _index == 1
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.missionWizard);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Mission'),
                    )
                  : null,
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            ),
    );
  }
}

String _titleForIndex(int i) {
  switch (i) {
    case 0:
      return 'Dashboard';
    case 1:
      return 'Missions';
    case 2:
      return 'Map / Navigation';
    case 3:
      return 'Tasks';
    case 4:
      return 'Settings';
    default:
      return 'Fuselage';
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.index,
    required this.tabKeys,
    required this.onSelectTab,
  });

  final int index;
  final List<GlobalKey<NavigatorState>> tabKeys;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    // Keep per-tab navigation state, but animate switching for a more premium feel.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.01, 0), end: Offset.zero).animate(anim),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(index),
        child: IndexedStack(
          index: index,
          children: [
            _TabNavigator(
              navigatorKey: tabKeys[0],
              child: DashboardScreen(onNavigateToTab: onSelectTab),
            ),
            _TabNavigator(
              navigatorKey: tabKeys[1],
              child: const MissionsScreen(),
            ),
            _TabNavigator(
              navigatorKey: tabKeys[2],
              child: const MapScreen(),
            ),
            _TabNavigator(
              navigatorKey: tabKeys[3],
              child: const TasksScreen(),
            ),
            _TabNavigator(
              navigatorKey: tabKeys[4],
              child: const SettingsScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabNavigator extends StatelessWidget {
  const _TabNavigator({
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        // Each tab has its own Navigator (scales to complex flows per tab),
        // but still supports global named routes (e.g. Mission Details, Manual Control).
        if (settings.name == Navigator.defaultRouteName) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: child,
            ),
          );
        }
        // Delegate named routes to the app router.
        return AppRouter.onGenerateRoute(settings);
      },
    );
  }
}

