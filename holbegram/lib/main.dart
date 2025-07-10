import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:holbegram/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBla-Egpuhcu5OY0Usc0_mlQoVnLxSETrs",
          appId: "1:370075037595:android:640c02525908e7c4cebb3e",
          messagingSenderId: "370075037595",
          projectId: "holbegram-6d805",
          storageBucket: "holbegram-6d805.firebasestorage.app"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'holbegram',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(
        emailController: TextEditingController(),
        passwordController: TextEditingController(),
      ),
    );
  }
}
