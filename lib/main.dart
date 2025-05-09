import 'package:flutter/material.dart';
import 'package:gestion_scolarite/pages/HomePage.dart';
import 'package:gestion_scolarite/screens/LoginRegisterScreen.dart';
import 'package:gestion_scolarite/screens/ReceiptScreen.dart';
import 'package:gestion_scolarite/screens/RegistrationForm.dart';
import 'package:gestion_scolarite/screens/AdminScreen.dart';
// import 'package:gestion_scolarite/screens/HomeScreen.dart';
import 'package:gestion_scolarite/screens/home_screen.dart';  // Importer le fichier HomeScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inscription Étudiante',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),  // Utiliser HomeScreen depuis le fichier séparé
        '/admin': (context) => const AdminScreen(),
        '/inscription': (context) => const RegistrationScreen(),
        '/login': (context) => const LoginRegisterScreen(),
        '/home': (context) => const HomePage(),
        
      },
    );
  }
}









// class RegistrationForm extends StatefulWidget {
//   const RegistrationForm({Key? key}) : super(key: key);

//   @override
//   _RegistrationFormState createState() => _RegistrationFormState();
// }

// class _RegistrationFormState extends State<RegistrationForm> {
//   // Déclaration des contrôleurs pour chaque champ de texte
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController cinController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();

//   String? selectedFiliere;
//   String? selectedAnnee;

//   final List<String> filieres = ['Informatique de gestion', 'Finance comptabilite', 'Banque et assurance', 'Gestion de ressource humaine','Technique Commerciale et Marketing','Statistique appliquee a la economie'];
//   final List<String> annees = ['L1', 'L2', 'L3', 'M1','M2'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Formulaire d\'inscription'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: ListView(
//           children: <Widget>[
//             const Text(
//               'Informations personnelles',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),

//             // Champ pour le nom
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Nom',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 15),

//             // Champ pour le prénom
//             TextField(
//               controller: lastNameController,
//               decoration: const InputDecoration(
//                 labelText: 'Prénom',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 15),

//             // Champ pour le CIN
//             TextField(
//               controller: cinController,
//               decoration: const InputDecoration(
//                 labelText: 'CNI',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 15),

//             // Champ pour le téléphone
//             TextField(
//               controller: phoneController,
//               decoration: const InputDecoration(
//                 labelText: 'Téléphone',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.phone,
//             ),
//             const SizedBox(height: 20),

//             const Text(
//               'Informations académiques',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),

//             // Dropdown pour la filière
//             DropdownButtonFormField<String>(
//               value: selectedFiliere,
//               items: filieres.map((String filiere) {
//                 return DropdownMenuItem<String>(
//                   value: filiere,
//                   child: Text(filiere),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedFiliere = value;
//                 });
//               },
//               decoration: const InputDecoration(
//                 labelText: 'Filière',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 15),

//             // Dropdown pour l'année d'étude
//             DropdownButtonFormField<String>(
//               value: selectedAnnee,
//               items: annees.map((String annee) {
//                 return DropdownMenuItem<String>(
//                   value: annee,
//                   child: Text(annee),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedAnnee = value;
//                 });
//               },
//               decoration: const InputDecoration(
//                 labelText: 'Année d\'étude',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Bouton pour soumettre le formulaire
//             ElevatedButton(
//               onPressed: () {
//                 if (nameController.text.isNotEmpty &&
//                     lastNameController.text.isNotEmpty &&
//                     cinController.text.isNotEmpty &&
//                     phoneController.text.isNotEmpty &&
//                     selectedFiliere != null &&
//                     selectedAnnee != null) {
//                   // Ici, tu peux envoyer les données au backend ou aux étapes suivantes
//                   // Pour l'instant, on affiche un message de confirmation
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Formulaire soumis avec succès')),
//                   );
//                 } else {
//                   // Afficher un message d'erreur si un champ est vide
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Veuillez remplir tous les champs')),
//                   );
//                 }
//               },
//               child: const Text('Soumettre'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }


