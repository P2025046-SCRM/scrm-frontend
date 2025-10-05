import 'package:flutter/widgets.dart';
import 'package:scrm/presentation/login/login_screen.dart';
import 'package:scrm/presentation/signup/signup_screen.dart';
import '../presentation/profile/profile_screen.dart';

class AppRoutes {
  static String initialRoute = 'profile';
  static Map<String, Widget Function(BuildContext)> getRoutes = {
    'login': (BuildContext context) => LoginScreen(),
    'signup': (BuildContext context) => SignupScreen(),
    'profile': (BuildContext context) => ProfileScreen(),
  };
}