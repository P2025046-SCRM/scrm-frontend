/// Centralized error handling utility
/// 
/// Provides user-friendly error messages and error logging
class ErrorHandler {
  /// Get user-friendly error message from exception
  /// 
  /// [error] - The exception or error object
  /// 
  /// Returns a user-friendly error message in Spanish
  static String getErrorMessage(dynamic error) {
    if (error is String) {
      return _getMessageFromString(error);
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Error de conexión. Verifique su conexión a internet.';
    }

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Sesión expirada. Por favor, inicie sesión nuevamente.';
    }

    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'Acceso denegado. No tiene permisos para realizar esta acción.';
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Recurso no encontrado.';
    }

    if (errorString.contains('server') || errorString.contains('500')) {
      return 'Error del servidor. Por favor, intente más tarde.';
    }

    if (errorString.contains('timeout')) {
      return 'Tiempo de espera agotado. Por favor, intente nuevamente.';
    }

    if (errorString.contains('invalid') || errorString.contains('validation')) {
      return 'Datos inválidos. Por favor, verifique la información ingresada.';
    }

    // Default error message
    return 'Ocurrió un error inesperado. Por favor, intente nuevamente.';
  }

  /// Get error message from string
  static String _getMessageFromString(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('login failed')) {
      return 'Email o contraseña incorrectos.';
    }

    if (lowerError.contains('signup failed')) {
      return 'Error al crear la cuenta. El email ya puede estar en uso.';
    }

    if (lowerError.contains('email') && lowerError.contains('already')) {
      return 'Este email ya está registrado.';
    }

    if (lowerError.contains('password') && lowerError.contains('weak')) {
      return 'La contraseña es demasiado débil. Use al menos 6 caracteres.';
    }

    if (lowerError.contains('token') && lowerError.contains('expired')) {
      return 'Sesión expirada. Por favor, inicie sesión nuevamente.';
    }

    return error;
  }

  /// Log error for debugging
  /// 
  /// In production, this could send errors to a logging service
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    print('Error: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
    // TODO: Integrate with logging service (e.g., Sentry, Firebase Crashlytics)
  }

  /// Get error code from exception
  /// 
  /// Returns error code if available, null otherwise
  static int? getErrorCode(dynamic error) {
    final errorString = error.toString();

    // Try to extract HTTP status code
    final regex = RegExp(r'\b(\d{3})\b');
    final match = regex.firstMatch(errorString);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    return null;
  }
}

