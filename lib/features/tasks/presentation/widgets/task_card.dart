import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/database.dart';
import '../providers/task_provider.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskActions = ref.read(taskActionsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => taskActions.toggleTaskCompleted(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: task.description != null && task.description!.isNotEmpty
            ? Text(
                task.description!,
                style: TextStyle(
                  color: task.isCompleted ? Colors.grey : null,
                ),
              )
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                context.go('/edit-task/${task.id}');
                break;
              case 'delete':
                final confirmed = await _showDeleteDialog(context);
                if (confirmed) {
                  await taskActions.deleteTask(task.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tarea eliminada')),
                    );
                  }
                }
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar tarea'),
            content: const Text('¿Estás seguro de que quieres eliminar esta tarea?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }
}