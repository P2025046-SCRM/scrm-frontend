import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:scrm/data/services/classification_service.dart';
import 'package:scrm/firebase_options.dart';
import 'package:scrm/utils/routes.dart';
import 'package:scrm/data/services/storage_service.dart';
import 'package:scrm/data/services/auth_service.dart';
import 'package:scrm/data/services/user_service.dart';
import 'package:scrm/data/services/history_service.dart';
import 'package:scrm/data/services/remote_config_service.dart';
import 'package:scrm/data/services/prediction_service.dart';
import 'package:scrm/data/providers/auth_provider.dart';
import 'package:scrm/data/providers/user_provider.dart';
import 'package:scrm/data/providers/settings_provider.dart';
import 'package:scrm/data/providers/classification_provider.dart';
import 'package:scrm/data/providers/dashboard_provider.dart';
import 'package:scrm/data/providers/admin_dashboard_provider.dart';
import 'package:scrm/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Remote Config
  final remoteConfigService = RemoteConfigService(FirebaseRemoteConfig.instance);
  await remoteConfigService.initialize();

  // Initialize Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  // Enable Crashlytics collection only in non-debug mode by default
  // Set to true for testing in debug mode
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }
  
  // Initialize services
  final storageService = await StorageService.getInstance();
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final authService = AuthService(firebaseAuth, firestore, storageService, remoteConfigService);
  // UserService uses Firestore as primary data source
  final userService = UserService(storageService, firestore, firebaseAuth);
  final historyService = HistoryService(storageService, firestore);
  final predictionService = PredictionService(firestore, firebaseAuth);
  final classificationService = ClassificationService(remoteConfigService);

  // Initialize providers
  final authProvider = AuthProvider(authService);
  final userProvider = UserProvider(userService);
  final settingsProvider = SettingsProvider(storageService);
  final classificationProvider = ClassificationProvider(historyService);
  final dashboardProvider = DashboardProvider(firestore);
  final adminDashboardProvider = AdminDashboardProvider(firestore);

  // Initialize authentication state
  await authProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: classificationProvider),
        ChangeNotifierProvider.value(value: dashboardProvider),
        ChangeNotifierProvider.value(value: adminDashboardProvider),
        Provider.value(value: predictionService), // Make PredictionService available via Provider
        Provider.value(value: historyService), // Make HistoryService available via Provider
        Provider.value(value: remoteConfigService), // Make RemoteConfigService available via Provider
        Provider.value(value: classificationService), // Make ClassificationService available via Provider
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return MaterialApp(
          title: 'SCRM',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryGreen,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: settingsProvider.themeMode,
          initialRoute: AppRoutes.getInitialRoute(context),
          routes: AppRoutes.getRoutes,
        );
      },
    );
  }
}