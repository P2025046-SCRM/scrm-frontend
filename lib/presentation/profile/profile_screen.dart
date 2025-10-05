import 'package:flutter/material.dart';
import '../../common/styles/text_styles.dart';
import 'widgets/logout_confirmation_widget.dart';
import 'widgets/profile_actions_widget.dart';
import 'widgets/profile_header_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  void _showLogoutConfirmation() {
    showModalBottomSheet(context: context,
    barrierColor: Colors.black.withAlpha(150),
    isScrollControlled: true,
    builder: (BuildContext context){
      return LogoutConfirmationWidget();
    });
  }

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
            ProfileHeaderWidget(),
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
            ProfileActions(editProfile: (){}, logout: _showLogoutConfirmation,),
          ],
        ),
      ),
    );
  }
}