import 'package:flutter/material.dart';
import 'opening_page.dart'; // Import the OpeningPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cerebral Games',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OpeningPage(), // Set the opening page as the first screen
    );
  }
}
