import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'asset.g.dart';

@HiveType(typeId: 1)
class Asset extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String location;

  @HiveField(3)
  final String description;

  // The code that is encoded in the QR. 
  // For simplicity, we might just match the 'id' or generate a unique string.
  @HiveField(4)
  final String qrCode; 

  const Asset({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.qrCode,
  });

  @override
  List<Object?> get props => [id, name, location, description, qrCode];
}
