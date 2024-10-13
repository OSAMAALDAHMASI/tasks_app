import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_tasks/controller/task_controller.dart';

class CustomAddTaskButton extends GetView<TaskController> {
  const CustomAddTaskButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        controller.showAddTaskDialog();
      },
      tooltip: 'Add Task',
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add),
    );
  }
}
