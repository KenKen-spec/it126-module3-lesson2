import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TaskScreen(),
    );
  }
}


Future<Database> openTaskDatabase() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'tasks.db');
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          is_completed INTEGER NOT NULL DEFAULT 0
        )
      ''');
    },
  );
}

Future<int> addTask(Database db, String title) {
  return db.insert('tasks', {'title': title});
}

Future<List<Map<String, Object?>>> getTasks(Database db) {
  return db.query('tasks', orderBy: 'id DESC');
}

Future<int> completeTask(Database db, int id) {
  return db.update(
    'tasks',
    {'is_completed': 1},
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<int> deleteTask(Database db, int id) {
  return db.delete(
    'tasks',
    where: 'id = ?',
    whereArgs: [id],
  );
}


class TaskRepository {
  final Database database;
  TaskRepository(this.database);

  Future<int> create(String title) => addTask(database, title);
  Future<List<Map<String, Object?>>> getAll() => getTasks(database);
  Future<int> markCompleted(int id) => completeTask(database, id);
  Future<int> delete(int id) => deleteTask(database, id);
}


class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Database? _db;
  TaskRepository? _repository;
  List<Map<String, Object?>> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    try {
      final db = await openTaskDatabase();
      final repo = TaskRepository(db);
      setState(() {
        _db = db;
        _repository = repo;
      });
      await _loadTasks();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing database: $e')),
      );
    }
  }

  Future<void> _loadTasks() async {
    if (_repository == null) return;
    setState(() => _isLoading = true);
    try {
      final tasks = await _repository!.getAll();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tasks: $e')),
      );
    }
  }

  Future<void> _addNewTask() async {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task title cannot be empty or whitespace-only.')),
      );
      return;
    }

    try {
      await _repository!.create(title);
      _controller.clear();
      await _loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task: $e')),
      );
    }
  }

  Future<void> _completeTask(int id) async {
    try {
      await _repository!.markCompleted(id);
      await _loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    }
  }

  Future<void> _deleteTask(int id) async {
    try {
      await _repository!.delete(id);
      await _loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Task Manager (SQLite)'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter task title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addNewTask,
                  child: const Text('Add Task'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? const Center(child: Text('No tasks found.'))
                    : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          final id = task['id'] as int;
                          final title = task['title'] as String;
                          final isCompleted = (task['is_completed'] as int) == 1;

                          return ListTile(
                            title: Text(
                              title,
                              style: TextStyle(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: isCompleted,
                                  onChanged: (val) {
                                    if (!isCompleted) {
                                      _completeTask(id);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteTask(id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}