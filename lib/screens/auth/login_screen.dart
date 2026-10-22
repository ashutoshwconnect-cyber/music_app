import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music_player/screens/auth/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailName = TextEditingController();
  TextEditingController passwordName = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login screen")),
      body: Column(
        spacing: 4,
        children: [
          TextField(
            controller: emailName,
            decoration: InputDecoration(hint: Text('Email')),
          ),
          TextField(
            controller: passwordName,
            decoration: InputDecoration(hint: Text('Password')),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: emailName.text,
                password: passwordName.text,
              );
            },
            child: Text('Sign in'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SignupScreen()));
            },
            child: Text('Sign up'),
          ),
        ],
      ),
    );
  }
}
