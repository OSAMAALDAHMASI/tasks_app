import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_tasks/controller/task_controller.dart';
import 'package:my_tasks/models/task_model.dart';

import '../../core/functions/get_card_color.dart';

class CustomCardTask extends GetView<TaskController> {
  final TaskModel task;
  final int index;

  const CustomCardTask({
    super.key,
    required this.task,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: getCardColor(task.priority),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.content),
            const SizedBox(height: 4),
            Text(
              'Priority: ${task.getPriorityString()}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) {
            controller.toggleTaskCompletion(index);
          },
        ),
        onTap: () {
          controller.editTask(index);
        },
      ),
    );
  }
}
