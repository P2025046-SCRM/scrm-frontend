import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scrm/utils/routes.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCRM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen)
      ),
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.getRoutes,
    );
  }
}