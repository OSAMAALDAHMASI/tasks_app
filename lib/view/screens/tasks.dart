import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_tasks/view/widgets/custom_card_task.dart';

import '../../controller/task_controller.dart';
import '../widgets/custom_add_task_button.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.put(TaskController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: Obx(() {
        return controller.tasks.isEmpty
            ? const Center(child: Text('No tasks available.'))
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.tasks.length,
                      itemBuilder: (context, index) {
                        final task = controller.tasks[index];
                        return Dismissible(
                          key: Key(task.title),
                          onDismissed: (direction) {
                            controller.deleteTask(index);
                            Get.snackbar('Success', "Task deleted");
                          },
                          background: Container(color: Colors.red),
                          child: CustomCardTask(
                            task: task,
                            index: index,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
      }),
      floatingActionButton: const CustomAddTaskButton(),
    );
  }
}
