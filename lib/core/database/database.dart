import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../features/tasks/domain/task_model.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD Operations
  Future<List<Task>> getAllTasks() => select(tasks).get();
  
  Future<List<Task>> getTasksByFilter({bool? completed}) {
    if (completed == null) return getAllTasks();
    return (select(tasks)..where((t) => t.isCompleted.equals(completed))).get();
  }

  Future<Task?> getTaskById(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertTask(TasksCompanion task) => into(tasks).insert(task);

  Future<bool> updateTask(int id, TasksCompanion task) =>
      (update(tasks)..where((t) => t.id.equals(id))).write(task).then((rows) => rows > 0);

  Future<bool> deleteTask(int id) =>
      (delete(tasks)..where((t) => t.id.equals(id))).go().then((rows) => rows > 0);

  Future<bool> toggleTaskCompleted(int id) async {
    final task = await getTaskById(id);
    if (task == null) return false;
    
    return updateTask(
      id,
      TasksCompanion(
        isCompleted: Value(!task.isCompleted),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'simpletask.db'));
    return NativeDatabase.createInBackground(file);
  });
}