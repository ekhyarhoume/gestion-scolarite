import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'Inscription Étudiante',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 20,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigation vers l'écran administrateur
            Navigator.pushNamed(context, '/home');
          },
          child: const Text('Accéder à l\'interface administrateur'),
        ),
      ),
    );
  }
}
