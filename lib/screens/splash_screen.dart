import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gestion_scolarite/constants/iamges_paths.dart';
import 'package:gestion_scolarite/pages/HomePage.dart';
import 'package:gestion_scolarite/screens/home_screen.dart'; // ou HomeScreen selon votre choix

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Afficher le splash screen pendant 3 secondes puis naviguer vers l'écran d'accueil
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          IamgesPaths.appLogo, // Assurez-vous que le chemin est correct
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}