import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:scrm/firebase_options.dart';
import 'package:scrm/utils/routes.dart';
import 'package:scrm/data/services/storage_service.dart';
import 'package:scrm/data/services/auth_service.dart';
import 'package:scrm/data/services/user_service.dart';
import 'package:scrm/data/services/history_service.dart';
import 'package:scrm/data/services/prediction_service.dart';
import 'package:scrm/data/providers/auth_provider.dart';
import 'package:scrm/data/providers/user_provider.dart';
import 'package:scrm/data/providers/settings_provider.dart';
import 'package:scrm/data/providers/classification_provider.dart';
import 'package:scrm/data/providers/dashboard_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize services
  final storageService = await StorageService.getInstance();
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final authService = AuthService(firebaseAuth, firestore, storageService);
  // UserService uses Firestore as primary data source
  final userService = UserService(storageService, firestore, firebaseAuth);
  final historyService = HistoryService(storageService, firestore);
  final predictionService = PredictionService(firestore, firebaseAuth);

  // Initialize providers
  final authProvider = AuthProvider(authService);
  final userProvider = UserProvider(userService);
  final settingsProvider = SettingsProvider(storageService);
  final classificationProvider = ClassificationProvider(historyService);
  final dashboardProvider = DashboardProvider(firestore);

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
        Provider.value(value: predictionService), // Make PredictionService available via Provider
        Provider.value(value: historyService), // Make HistoryService available via Provider
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
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.lightGreen,
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