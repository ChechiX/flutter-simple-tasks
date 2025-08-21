import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/tasks/presentation/screens/home_screen.dart';
import '../../features/tasks/presentation/screens/add_task_screen.dart';
import '../../features/tasks/presentation/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add-task',
        name: 'add-task',
        builder: (context, state) => const AddTaskScreen(),
      ),
      GoRoute(
        path: '/edit-task/:id',
        name: 'edit-task',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AddTaskScreen(taskId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});