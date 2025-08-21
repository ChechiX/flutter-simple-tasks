import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final int? taskId;
  
  const AddTaskScreen({super.key, this.taskId});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadTaskData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskData() async {
    if (widget.taskId != null) {
      final taskActions = ref.read(taskActionsProvider);
      final task = await taskActions.getTaskById(widget.taskId!);
      if (task != null && mounted) {
        _titleController.text = task.title;
        _descriptionController.text = task.description ?? '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarea' : 'Nueva Tarea'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveTask,
              child: const Text('GUARDAR'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título de la tarea',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: !_isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es requerido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final taskActions = ref.read(taskActionsProvider);
      
      if (widget.taskId != null) {
        // Editar tarea existente
        await taskActions.updateTask(
          id: widget.taskId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarea actualizada')),
          );
        }
      } else {
        // Crear nueva tarea
        await taskActions.addTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarea creada')),
          );
        }
      }
      
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}