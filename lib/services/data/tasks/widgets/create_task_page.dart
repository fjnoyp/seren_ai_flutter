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

                  Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('Team',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Text('ElectriciansPorto1',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.secondary)),
                  ]),
              const SizedBox(height: 16),
              // Title Input
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
              SizedBox(height: 8), // Project
              Divider(),

              Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(children: [
                    _createSelectionRow(context),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_month),
                        TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 10),
                            ),
                            child: Text(
                              'A',
                            ))
                      ],
                    ),
                    const SizedBox(height: 16),
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
                  ])),

              Text('Comments', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              // TODO: Implement comments section
              const SizedBox(height: 24),

              Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('Team:',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Electricians13',
                      ),
                    ),
                  ]),
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
                        parentTeamId:
                            'current_team_id', // Replace with actual team ID
                        parentProjectId: 'current_project_id', // Replace with actual project ID
  
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

  Widget _createSelectionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.person),
        TextButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return ListView.builder(
                  itemCount: 10, // Assuming you have a list of 10 temp strings
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Temp String ${index + 1}'),
                    );
                  },
                );
              },
            );
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10),
          ),
          child: Text(
            'Assignee',
          ),
        ),
      ],
    );
  }
}
