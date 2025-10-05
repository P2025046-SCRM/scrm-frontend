import 'package:flutter/widgets.dart';
import 'package:scrm/presentation/login/login_screen.dart';
import 'package:scrm/presentation/signup/signup_screen.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/profile/edit_profile_screen.dart';
import '../presentation/profile/profile_screen.dart';

class AppRoutes {
  static String initialRoute = 'dashboard';
  static Map<String, Widget Function(BuildContext)> getRoutes = {
    'login': (BuildContext context) => LoginScreen(),
    'signup': (BuildContext context) => SignupScreen(),
    'profile': (BuildContext context) => ProfileScreen(),
    'edit_profile': (BuildContext context) => EditProfileScreen(),
    'dashboard': (BuildContext context) => DashboardScreen(),
  };
}