import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrm/common/widgets/hl_button_widget.dart';
import 'package:scrm/data/providers/auth_provider.dart';
import 'package:scrm/data/providers/user_provider.dart';
import 'package:scrm/utils/error_handler.dart';

import '../../common/styles/text_styles.dart';
import '../../common/widgets/text_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingrese un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

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
          child: Form(
            key: _formKey,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bienvenido', style: kTitleTextStyle,),
              SizedBox(height: 24,),
              TextFieldWidget(
                textController: emailController,
                text: 'Email',
                inputType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              SizedBox(height: 12,),
              TextFieldWidget(
                textController: passwordController,
                text: 'Contraseña',
                inputType: TextInputType.visiblePassword,
                obscureText: true,
                validator: _validatePassword,
              ),
              SizedBox(height: 24,),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: HighlightedButton(
                      buttonText: authProvider.isLoading ? 'Iniciando Sesión...' : 'Iniciar Sesión',
                      onPressed: authProvider.isLoading ? () {} : () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await authProvider.login(
                            emailController.text.trim(),
                            passwordController.text,
                          );

                          if (!mounted) return;

                          if (success) {
                            // Fetch user data after successful login
                            if (!mounted) return;
                            final userProvider = Provider.of<UserProvider>(this.context, listen: false);
                            try {
                              await userProvider.fetchUserData();
                            } catch (e) {
                              // Log error but don't prevent login
                              print('Failed to fetch user data: $e');
                            }

                            if (!mounted) return;

                            // Show success message
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sesión iniciada exitosamente'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }

                            // Navigate to dashboard after user data is loaded
                            if (mounted) {
                              Navigator.pushReplacementNamed(this.context, 'dashboard');
                            }
                          } else {
                            // Show error message (already translated in AuthService)
                            if (mounted) {
                              final errorMessage = authProvider.errorMessage ?? 'Error al iniciar sesión';
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  );
                },
              ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  if (authProvider.isLoading) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: const CircularProgressIndicator(),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              SizedBox(height: 16,),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        if (emailController.text.isEmpty) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor ingrese su email primero'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        try {
                          final authProvider = Provider.of<AuthProvider>(this.context, listen: false);
                          
                          await authProvider.sendPasswordResetEmail(emailController.text.trim());
                          
                          if (!mounted) return;
                          
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Se ha enviado un email para restablecer su contraseña'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          
                          final errorMessage = ErrorHandler.getErrorMessage(e);
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
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