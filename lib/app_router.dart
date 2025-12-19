/// App Router Configuration
/// 
/// Defines all routes using GoRouter with authentication guards.
/// Protected routes redirect to login if user is not authenticated.

library;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/farm_selector/screens/farm_list_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

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
      GoRoute(
        path: '/dashboard/:farmId',
        name: 'dashboard',
        builder: (context, state) {
          final farmId = state.pathParameters['farmId']!;
          return DashboardScreen(farmId: farmId);
        },
      ),

      // TODO: Add more routes as we build features
      // - /livestock/:farmId
      // - /offspring/:farmId
      // - /breeding/:farmId
      // - /finance/:farmId
      // - /settings
    ],
  );
});
