import 'package:flutter/material.dart';
    import 'package:firebase_core/firebase_core.dart';
    import 'firebase_options.dart'; // Import firebase_options.dart
    import 'package:firebase_auth/firebase_auth.dart';
    import 'homepage.dart'; // Import homepage.dart

    void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase with options from firebase_options.dart
    );
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
    home: AuthenticationScreen(), // Updated to remove 'const'
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
    bool _isLoggedIn = false;

    @override
    void initState() {
    super.initState();
    _checkLoginStatus();
    }

    void _checkLoginStatus() {
    if (_auth.currentUser != null) {
    setState(() {
    _isLoggedIn = true;
    });
    }
    }

    @override
    Widget build(BuildContext context) {
    if (_isLoggedIn) {
    return Homepage(user: _auth.currentUser!);
    } else {
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
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;
      print('Signed up: ${user!.email}');
      // If signed up successfully, update login status
      setState(() {
      _isLoggedIn = true;
      });
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
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;
      print('Signed in: ${user!.email}');
      // If signed in successfully, update login status
      setState(() {
      _isLoggedIn = true;
      });
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
}
