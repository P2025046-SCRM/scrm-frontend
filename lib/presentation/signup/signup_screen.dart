import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrm/data/providers/auth_provider.dart';
import 'package:scrm/data/providers/user_provider.dart';
import 'package:scrm/utils/logger.dart';
import 'package:scrm/utils/constants.dart';

import '../../common/styles/text_styles.dart';
import '../../common/widgets/loading_button_widget.dart';
import '../../common/widgets/text_field_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su nombre';
    }
    if (value.length < AppDefaults.minNameLength) {
      return 'El nombre debe tener al menos ${AppDefaults.minNameLength} caracteres';
    }
    return null;
  }

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
      return 'Por favor ingrese una contraseña';
    }
    if (value.length < AppDefaults.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppDefaults.minPasswordLength} caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirme su contraseña';
    }
    if (value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPwController.dispose();
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
              Text('Crea tu cuenta', style: kTitleTextStyle,),
              SizedBox(height: 24,),
              TextFieldWidget(
                textController: nameController,
                text: 'Nombre',
                inputType: TextInputType.name,
                validator: _validateName,
              ),
              SizedBox(height: 12,),
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
              SizedBox(height: 12,),
              TextFieldWidget(
                textController: confirmPwController,
                text: 'Confirmar Contraseña',
                inputType: TextInputType.visiblePassword,
                obscureText: true,
                validator: _validateConfirmPassword,
              ),
              SizedBox(height: 24,),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return LoadingButton(
                    buttonText: 'Crear Cuenta',
                    loadingText: 'Creando Cuenta...',
                    isLoading: authProvider.isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await authProvider.signup(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text,
                        );

                        if (!mounted) return;

                        if (success) {
                          // Fetch user data after successful signup
                          if (!mounted) return;
                          final userProvider = Provider.of<UserProvider>(this.context, listen: false);
                          try {
                            await userProvider.fetchUserData();
                          } catch (e, stackTrace) {
                            // Log error but don't prevent signup
                            AppLogger.logError(e, stackTrace: stackTrace, reason: 'Failed to fetch user data after signup');
                          }

                          if (!mounted) return;

                          // Show success message
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Cuenta creada exitosamente'),
                                backgroundColor: AppColors.recyclableGreen,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }

                          // Navigate to dashboard after user data is loaded
                          if (mounted) {
                            Navigator.pushReplacementNamed(this.context, AppRouteNames.dashboard);
                          }
                        } else {
                          // Show error message (already translated in AuthService)
                          if (mounted) {
                            final errorMessage = authProvider.errorMessage ?? 'Error al crear la cuenta';
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: AppColors.nonRecyclableRed,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 16,),
              Center(
                child: Column(
                  children: [
                    TextButton(onPressed: (){
                      Navigator.pushReplacementNamed(context, AppRouteNames.login);
                    },
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