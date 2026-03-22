import 'package:flutter/material.dart';
import 'package:ikibina/screens/Unsplash/on_boarding_screen.dart';
void main() {
   runApp(const IkibinaApp());
}

class IkibinaApp extends StatelessWidget {
  const IkibinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ikibina',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const OnboardingFlow(),
    );
  }
}
