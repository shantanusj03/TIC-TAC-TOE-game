import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth/login_screen.dart'; // Make sure this file exists in your project

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAInugP7J_8uNmRtSeEX0xgS_ky8Db-E-Q",
      authDomain: "tic-tac-toe-app-56543.firebaseapp.com",
      projectId: "tic-tac-toe-app-56543",
      storageBucket: "tic-tac-toe-app-56543.firebasestorage.app",
      messagingSenderId: "1002482489789",
      appId: "1:1002482489789:web:9991b49ac8d65af6a49ad4",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic-Tac-Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
    );
  }
}
