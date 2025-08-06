import 'package:flutter/material.dart';
import 'package:offline_logs/app_logger.dart';
import 'package:offline_logs/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger().initialize();
  // Log a test message
  AppLogger().info("main", "Application started successfully.");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Log',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
