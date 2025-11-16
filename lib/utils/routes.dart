import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:scrm/common/widgets/auth_guard.dart';
import 'package:scrm/data/providers/auth_provider.dart';
import 'package:scrm/presentation/login/login_screen.dart';
import 'package:scrm/presentation/signup/signup_screen.dart';
import 'package:scrm/utils/constants.dart';
import '../presentation/camera_module/camera_mod_screen.dart';
import '../presentation/clasif_history/history_screen.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/profile/edit_profile_screen.dart';
import '../presentation/profile/profile_screen.dart';

class AppRoutes {
  /// Get initial route based on authentication status
  static String getInitialRoute(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      return authProvider.isAuthenticated ? AppRouteNames.dashboard : AppRouteNames.login;
    } catch (e) {
      // If provider is not available, default to login
      return AppRouteNames.login;
    }
  }

  static String initialRoute = AppRouteNames.login;

  static Map<String, Widget Function(BuildContext)> getRoutes = {
    AppRouteNames.login: (BuildContext context) => LoginScreen(),
    AppRouteNames.signup: (BuildContext context) => SignupScreen(),
    AppRouteNames.profile: (BuildContext context) => AuthGuard(
      child: ProfileScreen(),
    ),
    AppRouteNames.editProfile: (BuildContext context) => AuthGuard(
      child: EditProfileScreen(),
    ),
    AppRouteNames.dashboard: (BuildContext context) => AuthGuard(
      child: DashboardScreen(),
    ),
    AppRouteNames.history: (BuildContext context) => AuthGuard(
      child: HistoryScreen(),
    ),
    AppRouteNames.camera: (BuildContext context) => AuthGuard(
      child: CameraModScreen(),
    ),
  };
}