import 'package:flutter/material.dart';

import '../../common/styles/text_styles.dart';
import '../../common/widgets/hl_button_widget.dart';
import '../../common/widgets/text_field_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

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
              Text('Crea tu cuenta', style: kTitleTextStyle,),
              SizedBox(height: 24,),
              TextFieldWidget(textController: nameController, text: 'Nombre'),
              SizedBox(height: 12,),
              TextFieldWidget(textController: emailController, text: 'Email'),
              SizedBox(height: 12,),
              TextFieldWidget(textController: passwordController, text: 'Contraseña'),
              SizedBox(height: 12,),
              TextFieldWidget(textController: confirmPwController, text: 'Confirmar Contraseña'),
              SizedBox(height: 24,),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: HighlightedButton(buttonText: 'Crear Cuenta', onPressed: (){},),
              ),
              SizedBox(height: 16,),
              Center(
                child: Column(
                  children: [
                    TextButton(onPressed: (){},
                      child: Text('Ya tienes una cuenta? Inicia sesión',
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