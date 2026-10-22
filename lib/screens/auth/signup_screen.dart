import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/screens/auth/auth_wrapper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailName = TextEditingController();
  TextEditingController password1 = TextEditingController();
  TextEditingController password2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup screen")),
      body: Column(
        spacing: 4,
        children: [
          TextField(
            controller: emailName,
            decoration: InputDecoration(hint: Text('Email')),
          ),
          TextField(
            controller: password1,
            decoration: InputDecoration(hint: Text('Password')),
          ),
          TextField(
            controller: password2,
            decoration: InputDecoration(hint: Text('Reenter Password')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (password1.text == password2.text) {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: emailName.text,
                  password: password1.text,
                );
                Get.offAll(AuthWrapper());
              } else {
                Get.snackbar('Error', "Password does not match");
              }
            },
            child: Text('Sign up'),
          ),
        ],
      ),
    );
  }
}
