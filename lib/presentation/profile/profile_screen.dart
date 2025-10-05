import 'package:flutter/material.dart';
import 'package:scrm/common/widgets/hl_button_widget.dart';

import '../../common/styles/text_styles.dart';
import '../../common/widgets/alt_button_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Mi Perfil', style: kTitleTextStyle,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'),
                  ),
                  SizedBox(height: 8,),
                  Text('Juan Perez', style: kSubtitleTextStyle,),
                  SizedBox(height: 4,),
                  Text('3J Solutions', style: kDescriptionTextStyle,),
                  SizedBox(height: 2,),
                  Text('juanperez@example.com', style: kDescriptionTextStyle,),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16,42,0,12),
              child: Text('Configuración', style: kSubtitleTextStyle,),
            ),
            Divider(
              color: Color.fromARGB(255, 99, 135, 99),
              indent: 5,
              endIndent:5,
            ),
            SizedBox(height: 12,),
            Row(
              children: [
                SizedBox(width: 16,),
                Text('Idioma', style: kRegularTextStyle,),
                Spacer(),
                Text('Español', style: kRegularTextStyle,),
                SizedBox(width: 16,),
              ],
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                SizedBox(width: 16,),
                Text('Modo Claro/Oscuro', style: kRegularTextStyle,),
                Spacer(),
                Switch(value: false, onChanged: (value){}),
                SizedBox(width: 16,),
              ],
            ),
            Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: HighlightedButton(buttonText: 'Editar Perfil', onPressed: (){},),
                ),
                SizedBox(height: 12,),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: AltButtonWidget(buttonText: 'Cerrar Sesión', onPressed: (){},),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}