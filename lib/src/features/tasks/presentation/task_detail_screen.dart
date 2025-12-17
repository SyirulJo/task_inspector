import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/task_repository.dart';
import '../../assets/data/asset_repository.dart';
import '../../reports/data/report_repository.dart';
import '../../reports/domain/report.dart';
import '../../authentication/data/auth_repository.dart';
import '../domain/task.dart';
import '../../../shared/widgets/photo_picker_widget.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isVerified = false;
  final Map<String, dynamic> _formValues = {};
  List<String> _photos = [];
  
  // Future implementation: Fetch task
  Future<Task?> _fetchTask() async {
    // In a real app we'd get single task, here we search the list to keep it simple with our mock repo
    final tasks = await ref.read(taskRepositoryProvider).getAllTasks();
    try {
      return tasks.firstWhere((t) => t.id == widget.taskId);
    } catch (e) {
      return null;
    }
  }

  void _onScanSuccess(String code, String expectedCode) {
    if (code == expectedCode) {
      setState(() {
        _isVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asset Verified! Checklist Unlocked.')),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid QR Code. Expected: $expectedCode, Got: $code'), 
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitReport(Task task) async {
    // Basic validation
    if (_formValues.length < task.checklist.length) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all checklist items.')),
      );
      return;
    }

    final user = ref.read(authControllerProvider).value!;
    
    final report = Report(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      taskId: task.id,
      userId: user.id,
      submittedAt: DateTime.now(),
      results: _formValues.entries.map((e) => ReportItemResult(checklistItemId: e.key, value: e.value)).toList(),
      remarks: 'Submitted via App',
      photos: _photos,
    );

    // Save report
    await ref.read(reportRepositoryProvider).submitReport(report);
    
    // Update task status
    await ref.read(taskRepositoryProvider).updateTaskStatus(task.id, 'completed');

    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report Submitted Successfully!')),
      );
      context.pop(); 
      // Refresh task list
      ref.invalidate(userTasksProvider);
      ref.invalidate(reportsListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Task?>(
      future: _fetchTask(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final task = snapshot.data!;
        
        return Scaffold(
          appBar: AppBar(title: Text(task.title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTaskHeader(task),
                const SizedBox(height: 24),
                if (!_isVerified && task.status != 'completed')
                  _buildVerificationSection(context, task)
                else
                  _buildChecklistSection(task),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskHeader(Task task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(task.description),
            const Divider(),
             Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Scheduled: ${task.scheduledTime.toString()}'),
              ],
            ),
             const SizedBox(height: 8),
             Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Asset ID: ${task.assetId}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationSection(BuildContext context, Task task) {
    return Consumer(
      builder: (context, ref, child) {
        final assetAsync = ref.watch(assetsListProvider);
        return assetAsync.when(
          data: (assets) {
            final asset = assets.firstWhere((a) => a.id == task.assetId);
            return Column(
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Asset Verification Required',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Scan the QR code on the asset to unlock the checklist.'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Navigate to scan screen and wait for result
                    final scannedCode = await context.push<String>('/scan');
                    if (scannedCode != null) {
                      _onScanSuccess(scannedCode, asset.qrCode);
                    }
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR Code'),
                ),
                const SizedBox(height: 16),
                 TextButton(
                  onPressed: () {
                    // Developer Bypass
                    _onScanSuccess(asset.qrCode, asset.qrCode);
                  }, 
                  child: const Text('(Dev) Simulate Scan'),
                ),
              ],
            ); 
          }, 
          error: (e,s) => Text('Error loading asset info: $e'), 
          loading: () => const Center(child: CircularProgressIndicator())
        );
      },
    );
  }

  Widget _buildChecklistSection(Task task) {
    if (task.status == 'completed') {
      return const Card(
        color: Colors.green,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 16),
              Text('Task Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Checklist', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...task.checklist.map((item) => _buildChecklistItem(item)).toList(),
        const SizedBox(height: 24),
        PhotoPickerWidget(
          onPhotosChanged: (photos) {
            setState(() {
              _photos = photos;
            });
          },
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => _submitReport(task),
          child: const Text('Submit Report'),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(TaskChecklistItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (item.type == 'bool')
              SwitchListTile(
                title: const Text('Pass / Fail'),
                value: _formValues[item.id] as bool? ?? false,
                onChanged: (val) {
                  setState(() {
                    _formValues[item.id] = val;
                  });
                },
              )
            else if (item.type == 'rating')
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Rating (1-5)'),
                items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                onChanged: (val) {
                   setState(() {
                    _formValues[item.id] = val;
                  });
                },
              )
            else
              TextField(
                decoration: const InputDecoration(labelText: 'Enter value'),
                onChanged: (val) {
                   setState(() {
                    _formValues[item.id] = val;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
