





import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskManager(),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, priority INTEGER, isCompleted INTEGER)',
        );
      },
    );
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}

class Task {
  int? id;
  String title;
  String content;
  int priority;
  bool isCompleted;

  Task(this.title, this.content, this.priority, this.isCompleted, {this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  Task.fromMap(Map<String, dynamic> map)
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

class TaskManager extends StatefulWidget {
  @override
  _TaskManagerState createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  final List<Task> _tasks = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _priority = 'Medium';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseHelper().getTasks();
    setState(() {
      _tasks.clear();
      _tasks.addAll(tasks);
    });
  }

  void _addTask(BuildContext context) async {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();
    int priorityValue;

    switch (_priority) {
      case 'Low':
        priorityValue = 2;
        break;
      case 'Medium':
        priorityValue = 1;
        break;
      case 'High':
        priorityValue = 0;
        break;
      default:
        priorityValue = 1;
    }
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Title and Content cannot be empty')));
      return; // Don't proceed if fields are empty
    }

    final newTask = Task(title, content, priorityValue, false);
    await DatabaseHelper().insertTask(newTask);
    _titleController.clear();
    _contentController.clear();
    _priority = 'Medium';
    await _loadTasks(); // Ensure tasks are reloaded after insertion
    Navigator.pop(context);
  }

  void _toggleTaskCompletion(int index) async {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
    await DatabaseHelper().updateTask(_tasks[index]);
  }

  void _editTask(int index, BuildContext context) {
    _titleController.text = _tasks[index].title;
    _contentController.text = _tasks[index].content;
    _priority = _tasks[index].getPriorityString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: _contentController, decoration: InputDecoration(labelText: 'Content')),
            DropdownButton<String>(
              value: _priority,
              items: <String>['Low', 'Medium', 'High']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _priority = newValue!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final String title = _titleController.text.trim();
              final String content = _contentController.text.trim();
              int priorityValue;

              switch (_priority) {
                case 'Low':
                  priorityValue = 2;
                  break;
                case 'Medium':
                  priorityValue = 1;
                  break;
                case 'High':
                  priorityValue = 0;
                  break;
                default:
                  priorityValue = 1;
              }

              if (title.isEmpty || content.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Title and Content cannot be empty')));
                return; // Don't proceed if fields are empty
              }

              setState(() {
                _tasks[index].title = title;
                _tasks[index].content = content;
                _tasks[index].priority = priorityValue;
              });
              await DatabaseHelper().updateTask(_tasks[index]);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(int index) async {
    await DatabaseHelper().deleteTask(_tasks[index].id!);
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _showAddTaskDialog(BuildContext context) {
    _titleController.clear();
    _contentController.clear();
    _priority = 'Medium';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: _contentController, decoration: InputDecoration(labelText: 'Content')),

            DropdownButton<String>(
              value: _priority,
              items: <String>['Low', 'Medium', 'High']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _priority = newValue!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _addTask(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _getCardColor(int priority) {
    switch (priority) {
      case 0: // High
        return Colors.redAccent;
      case 1: // Medium
        return Colors.amber;
      case 2: // Low
        return Colors.lightGreen;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
      ),
      body: _tasks.isEmpty
          ? Center(child: Text('No tasks available.'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Dismissible(
                  key: Key(task.title),
                  onDismissed: (direction) {
                    _deleteTask(index);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Task deleted")));
                  },
                  background: Container(color: Colors.red),
                  child: Card(
                    color: _getCardColor(task.priority),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.content),
                          SizedBox(height: 4),
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
                          _toggleTaskCompletion(index);
                        },
                      ),
                      onTap: () {
                        _editTask(index, context);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
