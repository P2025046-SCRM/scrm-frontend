import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Login'),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
              ),
              TextFormField(
                keyboardType: TextInputType.visiblePassword,
                controller: passwordController,
              ),
            ],
          )),),
      ),
    );
  }
}