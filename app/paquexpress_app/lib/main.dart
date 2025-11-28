import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Buena práctica, déjalo si lo necesitas para otros plugins.
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paquexpress',
      theme: ThemeData(
        // Tema naranja/rojo para empresa de paquetería
        primaryColor: const Color(0xFFFF6B35),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        cardTheme: CardThemeData( 
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}