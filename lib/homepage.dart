import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Authentication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthenticationScreen(),
    );
  }
}

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Sign up with email and password
                  await _auth.createUserWithEmailAndPassword(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                  );
                  print('Signed up: ${_auth.currentUser!.email}');
                } catch (e) {
                  print('Failed to sign up: $e');
                }
              },
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Sign in with email and password
                  await _auth.signInWithEmailAndPassword(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                  );
                  print('Signed in: ${_auth.currentUser!.email}');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Homepage(user: _auth.currentUser!)),
                  );
                } catch (e) {
                  print('Failed to sign in: $e');
                }
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class Homepage extends StatelessWidget {
  final User user;

  const Homepage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthenticationScreen()),
              );
            },
          ),
        ],
      ),
      body: TodoList(user: user),
    );
  }
}

class TodoList extends StatefulWidget {
  final User user;

  const TodoList({Key? key, required this.user}) : super(key: key);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter todo title',
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    hintText: 'Enter time (e.g., 2:00 PM)',
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    hintText: 'Enter date (e.g., Monday)',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  if (_titleController.text.isNotEmpty &&
                      _timeController.text.isNotEmpty &&
                      _dateController.text.isNotEmpty) {
                    FirebaseFirestore.instance
                        .collection('todos')
                        .add({
                      'title': _titleController.text,
                      'time': _timeController.text,
                      'date': _dateController.text,
                      'completed': false,
                      'user_id': widget.user.uid,
                    })
                        .then((value) {
                      _titleController.clear();
                      _timeController.clear();
                      _dateController.clear();
                    })
                        .catchError(
                            (error) => print("Failed to add todo: $error"));
                  }
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('todos')
                .where('user_id', isEqualTo: widget.user.uid)
                .orderBy('date')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              final todos = snapshot.data!.docs;

              if (todos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No todos yet.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Completed Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              List<Widget> todoWidgets = [];
              List<Widget> completedTodoWidgets = [];

              for (var todo in todos) {
                ListTile tile = ListTile(
                  title: Text(
                    '${todo['title']} ${todo['date']} ${todo['time']}',
                  ),
                  leading: Checkbox(
                    value: todo['completed'],
                    onChanged: (value) {
                      FirebaseFirestore.instance
                          .collection('todos')
                          .doc(todo.id)
                          .update({'completed': value})
                          .then((value) => print("Todo updated"))
                          .catchError((error) =>
                          print("Failed to update todo: $error"));
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editTodo(todo);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('todos')
                              .doc(todo.id)
                              .delete()
                              .then((value) => print("Todo deleted"))
                              .catchError((error) =>
                              print("Failed to delete todo: $error"));
                        },
                      ),
                    ],
                  ),
                );

                if (todo['completed']) {
                  completedTodoWidgets.add(Container(
                    color: Colors.orangeAccent,
                    child: tile,
                  ));
                } else {
                  todoWidgets.add(Container(
                    color: Colors.lightBlueAccent,
                    child: tile,
                  ));
                }
              }

              return ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      ...todoWidgets,
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completed Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      ...completedTodoWidgets,
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _editTodo(DocumentSnapshot todo) {
    _titleController.text = todo['title'];
    _timeController.text = todo['time'];
    _dateController.text = todo['date'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter todo title',
                ),
              ),
              TextField(
                controller: _timeController,
                decoration: InputDecoration(
                  hintText: 'Enter time (e.g., 2:00 PM)',
                ),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  hintText: 'Enter date (e.g., Monday)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _timeController.text.isNotEmpty &&
                    _dateController.text.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('todos')
                      .doc(todo.id)
                      .update({
                    'title': _titleController.text,
                    'time': _timeController.text,
                    'date': _dateController.text,
                  })
                      .then((value) {
                    Navigator.pop(context);
                    _titleController.clear();
                    _timeController.clear();
                    _dateController.clear();
                  })
                      .catchError((error) =>
                      print("Failed to update todo: $error"));
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
