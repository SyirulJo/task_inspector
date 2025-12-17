// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportItemResultAdapter extends TypeAdapter<ReportItemResult> {
  @override
  final int typeId = 4;

  @override
  ReportItemResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportItemResult(
      checklistItemId: fields[0] as String,
      value: fields[1] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, ReportItemResult obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.checklistItemId)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportItemResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportAdapter extends TypeAdapter<Report> {
  @override
  final int typeId = 5;

  @override
  Report read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Report(
      id: fields[0] as String,
      taskId: fields[1] as String,
      userId: fields[2] as String,
      submittedAt: fields[3] as DateTime,
      results: (fields[4] as List).cast<ReportItemResult>(),
      remarks: fields[5] as String?,
      photos: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Report obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.submittedAt)
      ..writeByte(4)
      ..write(obj.results)
      ..writeByte(5)
      ..write(obj.remarks)
      ..writeByte(6)
      ..write(obj.photos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
