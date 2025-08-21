import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/database_provider.dart';

// Provider para obtener todas las tareas
final tasksProvider = StreamProvider<List<Task>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.select(database.tasks).watch();
});

// Provider para filtrar tareas
final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

// Enum para filtros
enum TaskFilter { all, pending, completed }

// Provider para tareas filtradas
final filteredTasksProvider = StreamProvider<List<Task>>((ref) {
  final database = ref.watch(databaseProvider);
  final filter = ref.watch(taskFilterProvider);
  
  switch (filter) {
    case TaskFilter.all:
      return database.select(database.tasks).watch();
    case TaskFilter.pending:
      return (database.select(database.tasks)
        ..where((t) => t.isCompleted.equals(false))).watch();
    case TaskFilter.completed:
      return (database.select(database.tasks)
        ..where((t) => t.isCompleted.equals(true))).watch();
  }
});

// Provider para manejar acciones de tareas
final taskActionsProvider = Provider<TaskActions>((ref) {
  final database = ref.watch(databaseProvider);
  return TaskActions(database);
});

class TaskActions {
  final AppDatabase _database;
  
  TaskActions(this._database);

  Future<void> addTask({
    required String title,
    String? description,
  }) async {
    await _database.insertTask(
      TasksCompanion(
        title: Value(title),
        description: Value(description),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateTask({
    required int id,
    required String title,
    String? description,
  }) async {
    await _database.updateTask(
      id,
      TasksCompanion(
        title: Value(title),
        description: Value(description),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> toggleTaskCompleted(int id) async {
    await _database.toggleTaskCompleted(id);
  }

  Future<void> deleteTask(int id) async {
    await _database.deleteTask(id);
  }

  Future<Task?> getTaskById(int id) async {
    return await _database.getTaskById(id);
  }
}