import 'package:flutter/material.dart';
import 'package:offline_logs/app-log/app_logger.dart';
import 'package:offline_logs/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Log',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF202225),
        canvasColor: Color(0xFF2F3136),
        cardColor: Color(0xFF36393E),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF5336ff),
          onPrimary: Colors.white,
          secondary: Color(0xFF5336ff),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2F3136),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2F3136),
          selectedItemColor: Color(0xFF5336ff),
          unselectedItemColor: Colors.grey,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5336ff), // replaces primary
            foregroundColor: Colors.white, // replaces onPrimary
            shape: StadiumBorder(),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70), // replaces bodyText1
          bodyMedium: TextStyle(color: Colors.white60), // replaces bodyText2
        ),
        iconTheme: IconThemeData(color: Colors.white70),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF2F3136), // Discord's panel gray
          hintStyle: TextStyle(color: Colors.white38), // muted placeholder
          labelStyle: TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: Color(0xFF202225),
            ), // deep background border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xFF202225)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: Color(0xFF5336ff),
              width: 2,
            ), // Discord blue focus
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
      home: const MyHomePage(title: 'Offline Logger'),
    );
  }
}
