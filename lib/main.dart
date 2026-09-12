import 'package:flutter/material.dart';
import 'package:fitflow/screens/home/home_page.dart';

void main() {
  runApp(FitFlowCode());
}

class FitFlowCode extends StatelessWidget {
  FitFlowCode({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1565C0),
          elevation: 0,

          centerTitle: false,

          titleTextStyle: TextStyle(
            color: Color(0xFF1565C0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),

          iconTheme: IconThemeData(
            color: Color(0xFF1565C0),
            size: 26,
          ),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),

      home: HomePage(),
    );
  }
}