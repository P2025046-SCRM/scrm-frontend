import 'package:flutter/material.dart';

import '../../../common/widgets/alt_button_widget.dart';
import '../../../common/widgets/hl_button_widget.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({
    super.key,
    required this.editProfile,
    required this.logout,
  });
  final VoidCallback editProfile;
  final VoidCallback logout;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          width: double.infinity,
          child: HighlightedButton(buttonText: 'Editar Perfil', onPressed: editProfile,),
        ),
        SizedBox(height: 12,),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: AltButtonWidget(buttonText: 'Cerrar Sesión', onPressed: logout,),
        ),
      ],
    );
  }
}