import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'user.g.dart';

enum UserRole { admin, staff }

@HiveType(typeId: 0)
class User extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String roleString;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.roleString,
  });

  UserRole get role => UserRole.values.firstWhere(
        (e) => e.toString() == roleString,
        orElse: () => UserRole.staff,
      );

  @override
  List<Object?> get props => [id, name, email, roleString];
}
