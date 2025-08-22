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
  int get schemaVersion => 2;
  
  // 3. AGREGAR ESTRATEGIA DE MIGRACIÓN
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) {
      // Se ejecuta cuando se crea la BD por primera vez
      return m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Se ejecuta cuando actualizas de una versión anterior
      if (from == 1 && to == 2) {
        // Migración de versión 1 a 2: agregar columna priority
        await m.addColumn(tasks, tasks.priority);
      }
      
      // Para futuras migraciones:
      // if (from == 2 && to == 3) {
      //   await m.addColumn(tasks, tasks.nuevaColumna);
      // }
    },
  );

  // CRUD Operations
  Future<List<Task>> getAllTasks() => select(tasks).get();
  
  Future<List<Task>> getTasksByFilter({bool? completed}) {
    if (completed == null) return getAllTasks();
    return (select(tasks)..where((t) => t.isCompleted.equals(completed))).get();
  }

  // Nueva función: obtener tareas por prioridad
  // Future<List<Task>> getTasksByPriority() => 
  //   (select(tasks)..orderBy([(t) => OrderingTerm.desc(t.priority)])).get();

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

  // Future<bool> updateTaskPriority(int id, int priority) async {
  //   return updateTask(
  //     id,
  //     TasksCompanion(
  //       priority: Value(priority),
  //       updatedAt: Value(DateTime.now()),
  //     ),
  //   );
  // }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'simpletask.db'));
    return NativeDatabase.createInBackground(file);
  });
}