import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/authentication/data/auth_repository.dart';
import '../features/authentication/presentation/login_screen.dart';
import '../features/dashboard/presentation/admin_dashboard.dart';
import '../features/dashboard/presentation/staff_dashboard.dart';
import '../features/dashboard/presentation/create_task_screen.dart';
import '../features/dashboard/presentation/analytics_screen.dart';
import '../features/tasks/presentation/task_detail_screen.dart';
import '../features/tasks/presentation/qr_scan_screen.dart';
import '../features/authentication/domain/user.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthStateListenable(authState),
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';

      if (isLoggedIn && isLoggingIn) {
        final user = authState.value!;
        if (user.role == UserRole.admin) {
          return '/admin';
        } else {
          return '/staff';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/staff',
        builder: (context, state) => const StaffDashboard(),
      ),
      GoRoute(
        path: '/task/:taskId',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          return TaskDetailScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const QRScanScreen(),
      ),
      GoRoute(
        path: '/create-task',
        builder: (context, state) => const CreateTaskScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
  );
});

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(this._authState);
  final AsyncValue<User?> _authState;
}
