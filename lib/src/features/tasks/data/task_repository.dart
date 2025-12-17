import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/task.dart';

List<Task> _mockTasks = [
  Task(
    id: 'task_1',
    title: 'Daily Generator Inspection',
    description: 'Check fuel levels and battery voltage.',
    assetId: 'asset_1',
    assignedUserId: 'staff_1',
    scheduledTime: DateTime.now().add(const Duration(hours: 2)),
    status: 'pending',
    checklist: const [
      TaskChecklistItem(id: 'c1', label: 'Fuel &gt; 50%', type: 'bool'),
      TaskChecklistItem(id: 'c2', label: 'Battery Voltage (V)', type: 'text'),
      TaskChecklistItem(id: 'c3', label: 'General Condition', type: 'rating'),
    ],
  ),
   Task(
    id: 'task_2',
    title: 'Weekly HVAC Maintenance',
    description: 'Clean filters and check drainage.',
    assetId: 'asset_2',
    assignedUserId: 'staff_1',
    scheduledTime: DateTime.now().subtract(const Duration(hours: 1)), // Overdue mock
    status: 'pending',
    checklist: const [
      TaskChecklistItem(id: 'c1', label: 'Filter Cleaned', type: 'bool'),
      TaskChecklistItem(id: 'c2', label: 'Drainage Clear', type: 'bool'),
    ],
  ),
];

class TaskRepository {
  Future<List<Task>> getTasksForUser(String userId) async {
    return _mockTasks.where((t) => t.assignedUserId == userId).toList();
  }
  
  Future<List<Task>> getAllTasks() async {
    return _mockTasks;
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    final index = _mockTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _mockTasks[index] = _mockTasks[index].copyWith(status: status);
    }
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final userTasksProvider = FutureProvider.family<List<Task>, String>((ref, userId) async {
  return ref.watch(taskRepositoryProvider).getTasksForUser(userId);
});
