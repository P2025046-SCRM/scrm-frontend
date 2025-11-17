import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrm/common/widgets/text_field_widget.dart';
import 'package:scrm/data/providers/user_provider.dart';
import 'package:scrm/utils/error_handler.dart';
import 'package:scrm/utils/constants.dart';
import '../../common/styles/text_styles.dart';
import '../../common/widgets/hl_button_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser;
      if (user != null) {
        nameController.text = userProvider.userName ?? '';
        emailController.text = userProvider.userEmail ?? '';
      }
      _isInitialized = true;
    }
  }

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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Editar Perfil', style: kTitleTextStyle,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12,),
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
            Spacer(),
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                return SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: HighlightedButton(
                    buttonText: userProvider.isLoading ? 'Guardando...' : 'Guardar Cambios',
                    onPressed: userProvider.isLoading ? () {} : () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await userProvider.updateProfile(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Perfil actualizado exitosamente'),
                              backgroundColor: AppColors.recyclableGreen,
                            ),
                          );

                          Navigator.pop(this.context);
                        } catch (e) {
                          if (!mounted) return;

                          final errorMessage = ErrorHandler.getErrorMessage(e);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: AppColors.nonRecyclableRed,
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (userProvider.isLoading) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: const CircularProgressIndicator(),
                  );
                }
                return SizedBox.shrink();
              },
            ),
            SizedBox(height: 12,),
          ],
        ),),
      ),
    );
  }
}