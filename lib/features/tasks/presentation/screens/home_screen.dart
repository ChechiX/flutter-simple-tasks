import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(filteredTasksProvider);
    final currentFilter = ref.watch(taskFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SimpleTask'),
        actions: [
          PopupMenuButton<TaskFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) => ref.read(taskFilterProvider.notifier).state = filter,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TaskFilter.all,
                child: Row(
                  children: [
                    Icon(
                      currentFilter == TaskFilter.all ? Icons.check : Icons.list,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Todas'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskFilter.pending,
                child: Row(
                  children: [
                    Icon(
                      currentFilter == TaskFilter.pending ? Icons.check : Icons.pending,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Pendientes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskFilter.completed,
                child: Row(
                  children: [
                    Icon(
                      currentFilter == TaskFilter.completed ? Icons.check : Icons.done,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Completadas'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay tareas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Agrega tu primera tarea',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return TaskCard(task: tasks[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-task'),
        child: const Icon(Icons.add),
      ),
    );
  }
}