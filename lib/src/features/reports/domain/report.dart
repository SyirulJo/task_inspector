import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'report.g.dart';

@HiveType(typeId: 4)
class ReportItemResult extends Equatable {
  @HiveField(0)
  final String checklistItemId;
  @HiveField(1)
  final dynamic value; // bool, string, etc.
  
  const ReportItemResult({required this.checklistItemId, required this.value});

  @override
  List<Object?> get props => [checklistItemId, value];
}

@HiveType(typeId: 5)
class Report extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String taskId;
  @HiveField(2)
  final String userId;
  @HiveField(3)
  final DateTime submittedAt;
  @HiveField(4)
  final List<ReportItemResult> results;
  @HiveField(5)
  final String? remarks;
  @HiveField(6)
  final List<String> photos; // Base64 encoded images for web compatibility

  const Report({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.submittedAt,
    required this.results,
    this.remarks,
    this.photos = const [],
  });

  @override
  List<Object?> get props => [id, taskId, userId, submittedAt, results, remarks, photos];
}
