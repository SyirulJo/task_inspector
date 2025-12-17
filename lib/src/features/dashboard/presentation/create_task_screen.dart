import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/data/task_repository.dart';
import '../../assets/data/asset_repository.dart';
import '../../authentication/data/auth_repository.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedAssetId;
  String? _selectedStaffId;
  DateTime _scheduledTime = DateTime.now().add(const Duration(hours: 1));
  
  final List<TaskChecklistItem> _checklistItems = [];
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addChecklistItem() {
    showDialog(
      context: context,
      builder: (context) => _ChecklistItemDialog(
        onAdd: (item) {
          setState(() {
            _checklistItems.add(item);
          });
        },
      ),
    );
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklistItems.removeAt(index);
    });
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledTime),
      );
      
      if (time != null) {
        setState(() {
          _scheduledTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedAssetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an asset')),
      );
      return;
    }
    
    if (_selectedStaffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign to a staff member')),
      );
      return;
    }
    
    if (_checklistItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one checklist item')),
      );
      return;
    }

    final task = Task(
      id: const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      assetId: _selectedAssetId!,
      assignedUserId: _selectedStaffId!,
      scheduledTime: _scheduledTime,
      status: 'pending',
      checklist: _checklistItems,
    );

    // In real app, this would call repository.createTask()
    // For now, we'll just show success and go back
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(assetsListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Task'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g., Daily Generator Inspection',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Detailed instructions for this task',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              assetsAsync.when(
                data: (assets) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Asset'),
                  value: _selectedAssetId,
                  items: assets.map((asset) {
                    return DropdownMenuItem(
                      value: asset.id,
                      child: Text('${asset.name} (${asset.location})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAssetId = value;
                    });
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error loading assets: $e'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Assign to Staff'),
                value: _selectedStaffId,
                items: const [
                  DropdownMenuItem(value: 'staff_1', child: Text('John Staff')),
                  DropdownMenuItem(value: 'staff_2', child: Text('Jane Operator')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStaffId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.calendar_today),
                title: const Text('Scheduled Time'),
                subtitle: Text(_scheduledTime.toString().substring(0, 16)),
                trailing: const Icon(Icons.edit),
                onTap: _selectDateTime,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Checklist Items (${_checklistItems.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton.filled(
                    onPressed: _addChecklistItem,
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Checklist Item',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_checklistItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No checklist items yet.\nTap + to add one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._checklistItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(item.label),
                      subtitle: Text('Type: ${item.type}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeChecklistItem(index),
                      ),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _createTask,
                child: const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistItemDialog extends StatefulWidget {
  final Function(TaskChecklistItem) onAdd;

  const _ChecklistItemDialog({required this.onAdd});

  @override
  State<_ChecklistItemDialog> createState() => _ChecklistItemDialogState();
}

class _ChecklistItemDialogState extends State<_ChecklistItemDialog> {
  final _labelController = TextEditingController();
  String _selectedType = 'bool';

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Checklist Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Label',
              hintText: 'e.g., Fuel Level > 50%',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Type'),
            value: _selectedType,
            items: const [
              DropdownMenuItem(value: 'bool', child: Text('Pass/Fail (Switch)')),
              DropdownMenuItem(value: 'text', child: Text('Text Input')),
              DropdownMenuItem(value: 'rating', child: Text('Rating (1-5)')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_labelController.text.isNotEmpty) {
              widget.onAdd(TaskChecklistItem(
                id: const Uuid().v4(),
                label: _labelController.text,
                type: _selectedType,
              ));
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
