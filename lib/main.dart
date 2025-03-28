import 'package:flutter/material.dart';
import 'package:flutter_application/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Device Info',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
