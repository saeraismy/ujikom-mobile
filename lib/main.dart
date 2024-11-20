import 'package:flutter/material.dart';
import 'tab_screen.dart'; // Import your TabScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TabScreen(), // Set TabScreen as the initial screen
    );
  }
}
