import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class CreateTaskPage extends ConsumerWidget {
  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project 
              Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('Project',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Text('Foundation Works San Giusto',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.secondary)),
                  ]),
                  const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                style: theme.textTheme.titleMedium,
                decoration: InputDecoration(
                  hintText: 'Task Name',
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,  
                    
                children: [
                              Expanded(
      child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Icon(Icons.person_outline, color: theme.iconTheme.color),
                        const SizedBox(width: 8),
                        Text('Assigned', style: theme.textTheme.bodyMedium),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement assign functionality
                          },
                          child: Text('Assign',
                              style: TextStyle(color: theme.colorScheme.secondary)),
                        ),
                      ],
                    ),
                  ),  ),            
                  Expanded(
      child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today, color: theme.iconTheme.color),
                        const SizedBox(width: 8),
                        Text('Due date', style: theme.textTheme.bodyMedium),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            // Handle the selected date
                          },
                          child: Text('Set date',
                              style: TextStyle(color: theme.colorScheme.secondary)),
                        ),
                      ],
                    ),
                  ),),
                ],
              ),
              const SizedBox(height: 24),
              Text('Description', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Add description',
                  border: InputBorder.none,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              Text('Comments', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              // TODO: Implement comments section
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle task creation logic here
                      final newTask = TaskModel(
                        id: 'new_id', // Generate or assign a unique ID
                        name: _nameController.text,
                        description: _descriptionController.text,
                        statusEnum: StatusEnum.inProgress,
                        priorityEnum: PriorityEnum.normal,
                        dueDate: null,
                        createdDate: DateTime.now(),
                        lastUpdatedDate: DateTime.now(),
                        authorUserId:
                            'current_user_id', // Replace with actual user ID
                        assignedUserId: null,
                        parentTeamId:
                            'current_team_id', // Replace with actual team ID
                        parentProjectId: null,
                        estimatedDuration: null,
                        listDurations: null,
                      );
                      // Add the new task to the database or state management
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                  child: const Text('Create Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
