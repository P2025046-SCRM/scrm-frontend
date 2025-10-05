import 'package:flutter/widgets.dart';
import 'package:scrm/presentation/login/login_screen.dart';
import 'package:scrm/presentation/signup/signup_screen.dart';

class AppRoutes {
  static String initialRoute = 'signup';
  static Map<String, Widget Function(BuildContext)> getRoutes = {
    'login': (BuildContext context) => LoginScreen(),
    'signup': (BuildContext context) => SignupScreen(),
  };
}