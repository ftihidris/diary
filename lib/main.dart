import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setAppTheme(BuildContext context, ThemeData theme) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setTheme(theme);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _appTheme = ThemeData.dark();

  void setTheme(ThemeData theme) {
    setState(() {
      _appTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _appTheme,
      home: const SplashScreen(),
    );
  }
}
