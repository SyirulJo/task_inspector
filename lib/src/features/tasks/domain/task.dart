import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'task.g.dart';

@HiveType(typeId: 2)
class TaskChecklistItem extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String label;
  @HiveField(2)
  final String type; // 'bool', 'text', 'rating'

  const TaskChecklistItem({
    required this.id,
    required this.label,
    required this.type,
  });

  @override
  List<Object?> get props => [id, label, type];
}

@HiveType(typeId: 3)
class Task extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String assetId;
  @HiveField(4)
  final String assignedUserId;
  @HiveField(5)
  final DateTime scheduledTime;
  @HiveField(6)
  final String status; // 'pending', 'completed', 'verified', 'missed'
  @HiveField(7)
  final List<TaskChecklistItem> checklist;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assetId,
    required this.assignedUserId,
    required this.scheduledTime,
    required this.status,
    required this.checklist,
  });
  
  // Helper to copyWith
  Task copyWith({
    String? status,
  }) {
    return Task(
      id: id,
      title: title,
      description: description,
      assetId: assetId,
      assignedUserId: assignedUserId,
      scheduledTime: scheduledTime,
      status: status ?? this.status,
      checklist: checklist,
    );
  }

  @override
  List<Object?> get props => [id, title, description, assetId, assignedUserId, scheduledTime, status, checklist];
}
