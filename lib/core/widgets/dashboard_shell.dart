/// Dashboard Shell
/// 
/// Main layout wrapper with sidebar navigation + content area.
/// All feature screens are wrapped with this shell.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/farm_provider.dart';
import '../../providers/auth_provider.dart';

/// Current navigation index for highlighting
final sidebarIndexProvider = StateProvider<int>((ref) => 0);

class DashboardShell extends ConsumerWidget {
  final Widget child;
  final int selectedIndex;
  
  const DashboardShell({
    super.key,
    required this.child,
    this.selectedIndex = 0,
  });

  static const double sidebarWidth = 260;
  static const double collapsedWidth = 72;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(currentFarmProvider);
    final user = ref.watch(authStateProvider).value;
    final isLargeScreen = MediaQuery.of(context).size.width > 900;
    
    // Update sidebar index
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sidebarIndexProvider.notifier).state = selectedIndex;
    });

    if (farm == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar (only on large screens)
          if (isLargeScreen)
            _Sidebar(
              farmName: farm.name,
              userName: user?.email?.split('@').first ?? 'User',
              selectedIndex: selectedIndex,
            ),
          
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar (optional on mobile)
                if (!isLargeScreen)
                  _MobileAppBar(farmName: farm.name),
                
                // Content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      // Drawer for mobile
      drawer: isLargeScreen ? null : Drawer(
        child: _Sidebar(
          farmName: farm.name,
          userName: user?.email?.split('@').first ?? 'User',
          selectedIndex: selectedIndex,
          isDrawer: true,
        ),
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  final String farmName;
  final String userName;
  final int selectedIndex;
  final bool isDrawer;

  const _Sidebar({
    required this.farmName,
    required this.userName,
    required this.selectedIndex,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: DashboardShell.sidebarWidth,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: colorScheme.outlineVariant.withAlpha(50))),
      ),
      child: Column(
        children: [
          // Logo & Brand
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primary.withAlpha(180)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.pets, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Text('DSFarm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
              ],
            ),
          ),
          
          // User Profile & Farm
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(80),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primary.withAlpha(30),
                  child: Text(userName[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.primary)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                      Text(farmName, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Icon(Icons.unfold_more, size: 18, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _NavItem(icon: Icons.dashboard_rounded, label: 'Overview', index: 0, selectedIndex: selectedIndex, isDrawer: isDrawer),
                _NavItem(icon: Icons.pets_rounded, label: 'Ternak', index: 1, selectedIndex: selectedIndex, isDrawer: isDrawer),
                _NavItem(icon: Icons.child_care_rounded, label: 'Anakan', index: 2, selectedIndex: selectedIndex, isDrawer: isDrawer),
                _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Keuangan', index: 3, selectedIndex: selectedIndex, isDrawer: isDrawer),
                _NavItem(icon: Icons.inventory_2_rounded, label: 'Inventaris', index: 4, selectedIndex: selectedIndex, isDrawer: isDrawer),
                _NavItem(icon: Icons.home_work_rounded, label: 'Kandang', index: 5, selectedIndex: selectedIndex, isDrawer: isDrawer),
                
                const SizedBox(height: 8),
                Divider(color: colorScheme.outlineVariant.withAlpha(60)),
                const SizedBox(height: 8),
                
                _NavItem(icon: Icons.local_hospital_rounded, label: 'Kesehatan', index: 6, selectedIndex: selectedIndex, isDrawer: isDrawer),
                _NavItem(icon: Icons.notifications_rounded, label: 'Pengingat', index: 7, selectedIndex: selectedIndex, isDrawer: isDrawer),
                _NavItem(icon: Icons.assessment_rounded, label: 'Laporan', index: 8, selectedIndex: selectedIndex, isDrawer: isDrawer),
              ],
            ),
          ),
          
          // Bottom section
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Divider(color: colorScheme.outlineVariant.withAlpha(60)),
                const SizedBox(height: 8),
                _NavItem(icon: Icons.settings_rounded, label: 'Pengaturan', index: 9, selectedIndex: selectedIndex, isDrawer: isDrawer),
                _NavItem(icon: Icons.logout_rounded, label: 'Keluar', index: -1, selectedIndex: selectedIndex, isLogout: true, isDrawer: isDrawer),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final bool isLogout;
  final bool isDrawer;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    this.isLogout = false,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = index == selectedIndex && !isLogout;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? colorScheme.primary.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _handleNavigation(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? colorScheme.primary : (isLogout ? Colors.red : colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? colorScheme.primary : (isLogout ? Colors.red : colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, WidgetRef ref) {
    if (isDrawer) Navigator.pop(context);
    
    final farm = ref.read(currentFarmProvider);
    if (farm == null) return;
    
    final farmId = farm.id;

    switch (index) {
      case 0: context.go('/dashboard/$farmId'); break;
      case 1: context.go('/dashboard/$farmId/livestock'); break;
      case 2: context.go('/dashboard/$farmId/offspring'); break;
      case 3: context.go('/dashboard/$farmId/finance'); break;
      case 4: context.go('/dashboard/$farmId/inventory'); break;
      case 5: context.go('/dashboard/$farmId/housing'); break;
      case 6: context.go('/dashboard/$farmId/health'); break;
      case 7: context.go('/dashboard/$farmId/reminders'); break;
      case 8: context.go('/dashboard/$farmId/reports'); break;
      case 9: context.go('/dashboard/$farmId/settings'); break;
      case -1: // Logout
        ref.read(authNotifierProvider.notifier).signOut();
        context.go('/login');
        break;
    }
  }
}

class _MobileAppBar extends StatelessWidget {
  final String farmName;

  const _MobileAppBar({required this.farmName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withAlpha(50))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text('DSFarm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
          const Spacer(),
          Text(farmName, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
