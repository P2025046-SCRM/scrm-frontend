import 'package:flutter/material.dart';
import 'package:scrm/common/widgets/hl_button_widget.dart';

import '../../common/styles/text_styles.dart';
import '../../common/widgets/text_field_widget.dart';

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          SizedBox(height: 40,),
          Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bienvenido', style: kTitleTextStyle,),
              SizedBox(height: 24,),
              TextFieldWidget(textController: emailController, text: 'Email'),
              SizedBox(height: 12,),
              TextFieldWidget(textController: passwordController, text: 'Contraseña'),
              SizedBox(height: 24,),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: HighlightedButton(buttonText: 'Iniciar Sesión', onPressed: (){
                  Navigator.pushReplacementNamed(context, 'dashboard');
                },),
              ),
              SizedBox(height: 16,),
              Center(
                child: Column(
                  children: [
                    TextButton(onPressed: (){},
                      child: Text('Olvidé mi contraseña',
                        style: kTextButtonStyle,)),
                    SizedBox(height: 8,),
                    TextButton(onPressed: (){
                      Navigator.pushReplacementNamed(context, 'signup');
                    },
                      child: Text('Crear una cuenta',
                        style: kTextButtonStyle,)),
                  ],
                ),
              )
            ],
          )),),],
      ),
    );
  }
}