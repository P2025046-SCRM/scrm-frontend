import 'package:flutter/widgets.dart';
import 'package:scrm/presentation/login/login_screen.dart';

class AppRoutes {
  static String initialRoute = 'login';
  static Map<String, Widget Function(BuildContext)> getRoutes = {
    'login': (BuildContext context) => LoginScreen(),
  };
}