import 'package:flutter/material.dart';

import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/alt_button_widget.dart';
import '../../../common/widgets/hl_button_widget.dart';

class LogoutConfirmationWidget extends StatelessWidget {
  const LogoutConfirmationWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('¿Está seguro que desea cerrar sesión?',
            style: kSubtitleTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AltButtonWidget(buttonText: 'Cancelar', onPressed: () => Navigator.pop(context),), // Close bottom sheet
              Spacer(),
              HighlightedButton(buttonText: 'Cerrar Sesión', onPressed: () {
                Navigator.pop(context); // Close bottom sheet
                Navigator.pushReplacementNamed(context, 'login'); // Navigate to login screen
              }),
            ],
          ),
          const SizedBox(height: 10.0,),
        ],
      ),
    );
  }
}