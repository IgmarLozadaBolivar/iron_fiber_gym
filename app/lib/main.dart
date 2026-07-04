import 'package:app/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseDarkTheme = ThemeData(brightness: Brightness.dark);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IFG',
      themeMode: ThemeMode.dark,
      darkTheme: baseDarkTheme.copyWith(
        textTheme: GoogleFonts.soraTextTheme(baseDarkTheme.textTheme),
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: GoogleFonts.soraTextTheme(ThemeData.light().textTheme),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Row(
          children: [],
        ),
      ),
    );
  }
}
