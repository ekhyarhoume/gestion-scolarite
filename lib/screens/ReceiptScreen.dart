import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  final String name;
  final String lastName;
  final String filiere;
  final String annee;
  final double montant;

  const ReceiptScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.filiere,
    required this.annee,
    required this.montant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text('Reçu d\'inscription',
          style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, ),),
        ),
        elevation: 30,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Reçu d\'inscription',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Nom: $name $lastName', style: TextStyle(fontSize: 18)),
            Text('Filière: $filiere', style: TextStyle(fontSize: 18)),
            Text('Année d\'étude: $annee', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text('Montant payé: $montant MRU', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text('Date de paiement: ${DateTime.now().toLocal()}',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Retour à l'écran d'accueil
              },
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
