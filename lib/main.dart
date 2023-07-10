import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import './firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final StreamSubscription<User?> _firebaseStreamEvents;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _firebaseStreamEvents =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        if (user.emailVerified) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        } else {
          user.sendEmailVerification();
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firebaseStreamEvents.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    );
                  } on FirebaseAuthException catch (e) {
                    if (e.code == "user-not-found") {
                      print('No user found for that email.');
                    } else if (e.code == "wrong-password") {
                      print('Wrong password provided for that user.');
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController _scrollController = ScrollController();
  List<String> itemList = [];
  bool _isLoading = false;
  int _pageNumber = 1;
  int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadItems();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadItems() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      // Simulación de una solicitud asíncrona para cargar elementos
      Future.delayed(const Duration(seconds: 2), () {
        // Agregar elementos simulados a la lista
        List<String> newItems = [];
        for (int i = 0; i < _pageSize; i++) {
          String newItem = '🌟 ${(_pageNumber - 1) * _pageSize + i + 1}';
          newItems.add(newItem);
        }
        setState(() {
          itemList.addAll(newItems);
          _pageNumber++;
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: itemList.length + 1,
        itemBuilder: (context, index) {
          if (index < itemList.length) {
            return ListTile(
              title: Text(itemList[index]),
            );
          } else {
            return _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container();
          }
        },
      ),
    );
  }
}
