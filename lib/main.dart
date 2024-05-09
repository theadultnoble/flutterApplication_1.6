import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const keyApplicationId = 'ThXBjb9HNe0LhOx8IZDCo4fCdwaewGwwgQVzVTAc';
  const keyClientKey = 'IbY5x4ZF1RCjxi3oHBvOKTvqfC7X4EyMgXUGCHM4';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(const MaterialApp(home: TodoApp()));
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<ParseObject> tasks = [];
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTodo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        hintColor: Colors.blue[900],
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Todo List'),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            _buildTaskInput(),
            const SizedBox(height: 20),
            Expanded(child: _buildTaskList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: taskController,
              decoration: InputDecoration(
                hintText: 'EnteR tasks',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: addTodo,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final varTodo = tasks[index];
        final varTitle = varTodo.get<String>('title') ?? '';
        bool done = varTodo.get<bool>('done') ?? false;

        return ListTile(
          title: Row(
            children: [
              Checkbox(
                value: done,
                onChanged: (newValue) {
                  updateTodo(index, newValue!);
                },
              ),
              Expanded(child: Text(varTitle)),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              deleteTodo(index, varTodo.objectId!);
            },
          ),
        );
      },
    );
  }

  Future<void> addTodo() async {
    String task = taskController.text.trim();
    if (task.isNotEmpty) {
      final todo = ParseObject('Todo')
        ..set('title', task)
        ..set('done', false);
      await todo.save();
      setState(() {
        tasks.add(todo);
      });
      taskController.clear();
    }
  }

  Future<void> updateTodo(int index, bool done) async {
    final varTodo = tasks[index];
    final String id = varTodo.objectId.toString();
    var todo = ParseObject('Todo')
      ..objectId = id
      ..set('done', done);
    await todo.save();
    setState(() {
      tasks[index] = todo;
    });
  }

  Future<List<ParseObject>> getTodo() async {
    QueryBuilder<ParseObject> queryTodo =
        QueryBuilder<ParseObject>(ParseObject('Todo'));
    final ParseResponse apiResponse = await queryTodo.query();

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        tasks = apiResponse.results as List<ParseObject>;
      });
      return tasks;
    } else {
      return [];
    }
  }

  Future<void> deleteTodo(int index, String id) async {
    setState(() {
      tasks.removeAt(index);
    });
    var todo = ParseObject('Todo')..objectId = id;
    await todo.delete();
  }
}
