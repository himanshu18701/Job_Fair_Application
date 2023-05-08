import 'package:flutter/material.dart';
import 'JobSeekerPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobSeeker',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue, // Change primarySwatch to red
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: JobSeekerPage(),
    );
  }
}
