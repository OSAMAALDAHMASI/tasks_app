import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildTaskForm(
    {required TextEditingController titleController,
    required TextEditingController contentController,
    required RxString priority}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title')),
      TextField(
          controller: contentController,
          decoration: const InputDecoration(labelText: 'Content')),
      Obx(() => DropdownButton<String>(
            value: priority.value,
            items: <String>['Low', 'Medium', 'High']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              priority.value = newValue!;
            },
          )),
    ],
  );
}
