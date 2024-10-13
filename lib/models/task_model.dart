class TaskModel {
  int? id;
  String title;
  String content;
  int priority;
  bool isCompleted;

  TaskModel(this.title, this.content, this.priority, this.isCompleted,
      {this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  TaskModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        content = map['content'],
        priority = map['priority'],
        isCompleted = map['isCompleted'] == 1;

  String getPriorityString() {
    switch (priority) {
      case 0:
        return 'High';
      case 1:
        return 'Medium';
      case 2:
        return 'Low';
      default:
        return 'Medium';
    }
  }
}
