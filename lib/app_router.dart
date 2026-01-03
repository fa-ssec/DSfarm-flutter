/// App Router Configuration
/// 
/// Defines all routes using GoRouter with authentication guards.
/// Protected routes redirect to login if user is not authenticated.

library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/farm_selector/screens/farm_list_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/lineage/screens/lineage_screen.dart';
import 'features/livestock/screens/livestock_list_screen.dart';
import 'features/public/public_housing_view.dart';

import 'features/offspring/screens/offspring_list_screen.dart';
import 'features/finance/screens/finance_screen.dart';
import 'features/inventory/screens/inventory_screen.dart';
import 'features/housing/screens/housing_list_screen.dart';
import 'features/health/screens/health_screen.dart';
import 'features/reminder/screens/reminder_screen.dart';
import 'features/reports/screens/reports_screen.dart';
import 'features/settings/screens/settings_screen.dart';

/// Router provider for dependency injection
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    
    // Redirect logic based on auth state
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register';
      
      // Allow public routes without auth
      final isPublicRoute = state.matchedLocation.startsWith('/kandang/');

      // If accessing public route, allow without auth
      if (isPublicRoute) {
        return null;
      }

      // If not logged in and not on login/register page, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // If logged in and on login/register page, redirect to farm selector
      if (isLoggedIn && isLoggingIn) {
        return '/farms';
      }

      return null; // No redirect
    },

    routes: [
      // ═══════════════════════════════════════════════════════════
      // PUBLIC ROUTES (No Auth Required)
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: '/kandang/:housingId',
        name: 'publicHousing',
        builder: (context, state) {
          final housingId = state.pathParameters['housingId']!;
          return PublicHousingViewPage(housingId: housingId);
        },
      ),
      
      // ═══════════════════════════════════════════════════════════
      // AUTH ROUTES (Public)
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ═══════════════════════════════════════════════════════════
      // FARM ROUTES (Protected)
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: '/farms',
        name: 'farms',
        builder: (context, state) => const FarmListScreen(),
      ),
      
      // ═══════════════════════════════════════════════════════════
      // DASHBOARD ROUTES (Protected with sub-routes)
      // No transition for sub-routes to feel like instant switching
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: '/dashboard/:farmId',
        name: 'dashboard',
        pageBuilder: (context, state) {
          final farmId = state.pathParameters['farmId']!;
          return NoTransitionPage(child: DashboardScreen(farmId: farmId));
        },
        routes: [
          GoRoute(
            path: 'livestock',
            name: 'livestock',
            pageBuilder: (context, state) => const NoTransitionPage(child: LivestockListScreen()),
          ),
          GoRoute(
            path: 'offspring',
            name: 'offspring',
            pageBuilder: (context, state) => const NoTransitionPage(child: OffspringListScreen()),
          ),
          GoRoute(
            path: 'finance',
            name: 'finance',
            pageBuilder: (context, state) => const NoTransitionPage(child: FinanceScreen()),
          ),
          GoRoute(
            path: 'inventory',
            name: 'inventory',
            pageBuilder: (context, state) => const NoTransitionPage(child: InventoryScreen()),
          ),
          GoRoute(
            path: 'housing',
            name: 'housing',
            pageBuilder: (context, state) => const NoTransitionPage(child: HousingListScreen()),
          ),
          GoRoute(
            path: 'health',
            name: 'health',
            pageBuilder: (context, state) => const NoTransitionPage(child: HealthScreen()),
          ),
          GoRoute(
            path: 'reminders',
            name: 'reminders',
            pageBuilder: (context, state) => const NoTransitionPage(child: ReminderScreen()),
          ),
          GoRoute(
            path: 'reports',
            name: 'reports',
            pageBuilder: (context, state) => const NoTransitionPage(child: ReportsScreen()),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),

      // ═══════════════════════════════════════════════════════════
      // LINEAGE ROUTE
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: '/lineage',
        name: 'lineage',
        builder: (context, state) {
          final offspringId = state.uri.queryParameters['offspringId'];
          final livestockId = state.uri.queryParameters['livestockId'];
          return LineageScreen(
            offspringId: offspringId,
            livestockId: livestockId,
          );
        },
      ),
    ],
  );
});
