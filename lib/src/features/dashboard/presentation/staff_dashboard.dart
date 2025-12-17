import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../authentication/data/auth_repository.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/task.dart';

class StaffDashboard extends ConsumerWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Not logged in'));
          final tasksAsync = ref.watch(userTasksProvider(user.id));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(context, user.name),
                const SizedBox(height: 24),
                // Tasks List
                Text(
                  'Assigned Tasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                tasksAsync.when(
                  data: (tasks) {
                     if (tasks.isEmpty) {
                       return const Card(
                         child: Padding(
                           padding: EdgeInsets.all(32),
                           child: Center(child: Text('No tasks assigned.')),
                         )
                       );
                     }
                     return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(task.status),
                                child: Icon(_getStatusIcon(task.status), color: Colors.white),
                              ),
                              title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(task.description),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(DateFormat('MMM dd, HH:mm').format(task.scheduledTime)),
                                    backgroundColor: Colors.grey[100],
                                    labelStyle: const TextStyle(fontSize: 12),
                                    padding: EdgeInsets.zero,
                                  )
                                ],
                              ),
                              onTap: () {
                                context.push('/task/${task.id}');
                              },
                            ),
                          );
                        },
                     );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           // General Scan (can find asset and open relevant task)
           context.push('/scan');
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary, // Will fallback if undefined or use compute
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello,',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Keep up the good work! Scan assets to start inspections.',
            style: TextStyle(color: Colors.white70),
          )
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'missed': return Colors.red;
      default: return Colors.orange;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed': return Icons.check;
      case 'missed': return Icons.warning;
      default: return Icons.schedule;
    }
  }
}
