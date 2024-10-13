import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_tasks/models/task_model.dart';

import '../core/class/sqflite_helper.dart';
import '../core/functions/build_task_form.dart';
import '../core/functions/get_priority_value.dart';

class TaskController extends GetxController {
  var tasks = <TaskModel>[].obs;
  var titleController = TextEditingController();
  var contentController = TextEditingController();
  var priority = 'Medium'.obs;

  @override
  void onInit() {
    loadTasks();
    super.onInit();
  }

  void loadTasks() async {
    final loadedTasks = await DatabaseHelper().getTasks();
    tasks.assignAll(loadedTasks);
  }

  void addTask() async {
    final String title = titleController.text.trim();
    final String content = contentController.text.trim();
    int priorityValue = getPriorityValue(priority.value);

    if (title.isEmpty || content.isEmpty) {
      Get.snackbar('Error', 'Title and Content cannot be empty');
      return;
    }

    final newTask = TaskModel(title, content, priorityValue, false);
    await DatabaseHelper().insertTask(newTask);
    titleController.clear();
    contentController.clear();
    priority.value = 'Medium';
    loadTasks();
    Get.back();
  }

  void editTask(int index) async {
    titleController.text = tasks[index].title;
    contentController.text = tasks[index].content;
    priority.value = tasks[index].getPriorityString();

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Task'),
        content: buildTaskForm(
            titleController: titleController,
            contentController: contentController,
            priority: priority),
        actions: [
          TextButton(
            onPressed: () async {
              final String title = titleController.text.trim();
              final String content = contentController.text.trim();
              int priorityValue = getPriorityValue(priority.value);

              if (title.isEmpty || content.isEmpty) {
                Get.snackbar('Error', 'Title and Content cannot be empty');
                return;
              }

              tasks[index].title = title;
              tasks[index].content = content;
              tasks[index].priority = priorityValue;
              await DatabaseHelper().updateTask(tasks[index]);
              loadTasks();
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void toggleTaskCompletion(int index) async {
    tasks[index].isCompleted = !tasks[index].isCompleted;
    await DatabaseHelper().updateTask(tasks[index]);
    tasks.refresh(); // Refresh the tasks list
  }

  void deleteTask(int index) async {
    await DatabaseHelper().deleteTask(tasks[index].id!);
    tasks.removeAt(index);
  }

  void showAddTaskDialog() {
    titleController.clear();
    contentController.clear();
    priority.value = 'Medium';
    Get.dialog(
      AlertDialog(
        title: const Text('Add Task'),
        content: buildTaskForm(
            titleController: titleController,
            contentController: contentController,
            priority: priority),
        actions: [
          TextButton(
            onPressed: () {
              addTask();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
