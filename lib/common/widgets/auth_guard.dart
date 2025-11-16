import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrm/data/providers/auth_provider.dart';
import 'package:scrm/utils/constants.dart';

/// Widget that guards routes requiring authentication
/// 
/// Redirects to login if user is not authenticated
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          // Redirect to login if not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouteNames.login,
              (Route<dynamic> route) => false,
            );
          });
          // Show loading while redirecting
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return child;
      },
    );
  }
}


