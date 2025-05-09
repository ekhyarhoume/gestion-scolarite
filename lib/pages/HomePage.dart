import 'package:flutter/material.dart';
import 'package:gestion_scolarite/screens/RegistrationForm.dart';
import 'package:gestion_scolarite/screens/StudentRegistrationScreen.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bienvenue dans votre iscae',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
        ),
        elevation: 10,
        backgroundColor: Colors.teal, // Couleur de l'AppBar
      ),
      body: Container(
        // Appliquer un background color ou un dégradé
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green], // Dégradé du bleu au vert
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(  // Centrer tous les éléments
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  // Centrer verticalement
              crossAxisAlignment: CrossAxisAlignment.center,  // Centrer horizontalement
              children: <Widget>[
                const Text(
                  'Choisissez une option',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,  // Couleur du texte en blanc
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Rediriger vers l'écran de nouveau étudiant (inscription)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentRegistrationScreen(),
                      ),
                    );
                  },
                  child: const Text('Nouveau Étudiant',style: TextStyle(
                    color: Colors.white, ),),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50), backgroundColor: Colors.teal,
                    textStyle: const TextStyle(fontSize: 18 ), // Couleur du bouton
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Rediriger vers l'écran de l'ancien étudiant (connexion)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrationScreen(),
                      ),
                    );
                  },
                  child: const Text('Ancien Étudiant',
                  style: TextStyle(
                    color: Colors.white, 
    ),),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50), backgroundColor: Colors.teal,
                    textStyle: const TextStyle(fontSize: 18), // Couleur du bouton
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
