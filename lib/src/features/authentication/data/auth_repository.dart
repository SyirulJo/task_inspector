import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user.dart';

// Mock users database
const _mockUsers = [
  User(
    id: 'admin_1',
    name: 'System Admin',
    email: 'admin@test.com',
    roleString: 'UserRole.admin',
  ),
  User(
    id: 'staff_1',
    name: 'John Staff',
    email: 'staff@test.com',
    roleString: 'UserRole.staff',
  ),
  User(
    id: 'staff_2',
    name: 'Jane Operator',
    email: 'jane@test.com',
    roleString: 'UserRole.staff',
  ),
];

class AuthRepository {
  Future<User?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      final user = _mockUsers.firstWhere((u) => u.email == email);
      // In a real app we would check password
      return user;
    } catch (e) {
      throw Exception('Invalid credentials');
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// AsyncNotifier to manage current user state
class AuthController extends AsyncNotifier<User?> {
  
  @override
  Future<User?> build() async {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).login(email, password);
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }
  
  // Debug method to force login as admin
  void debugLoginAsAdmin() {
    state = const AsyncValue.data(User(
      id: 'admin_1',
      name: 'System Admin',
      email: 'admin@test.com',
      roleString: 'UserRole.admin',
    ));
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(() {
  return AuthController();
});
