import 'package:flutter/material.dart';
import 'package:scrm/common/widgets/text_field_widget.dart';
import '../../common/styles/text_styles.dart';
import '../../common/widgets/hl_button_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Editar Perfil', style: kTitleTextStyle,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12,),
            TextFieldWidget(textController: nameController, text: 'Nombre', inputType: TextInputType.name,),
            SizedBox(height: 12,),
            TextFieldWidget(textController: emailController, text: 'Email', inputType: TextInputType.emailAddress,),
            Spacer(),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: HighlightedButton(buttonText: 'Guardar Cambios', onPressed: (){
                // add logic to save changes
                Navigator.pop(context);
              },),
            ),
            SizedBox(height: 12,),
          ],
        ),),
      ),
    );
  }
}