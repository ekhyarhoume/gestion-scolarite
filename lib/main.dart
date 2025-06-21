import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestion_scolarite/pages/HomePage.dart';
import 'package:gestion_scolarite/providers/theme_provider.dart';
import 'package:gestion_scolarite/screens/LoginRegisterScreen.dart';
import 'package:gestion_scolarite/screens/ReceiptScreen.dart';
import 'package:gestion_scolarite/screens/RegistrationForm.dart';
import 'package:gestion_scolarite/screens/home_screen.dart';
import 'package:gestion_scolarite/screens/settings_screen.dart';
import 'package:gestion_scolarite/screens/student_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TEST COMMENT
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Removed Firebase initialization
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Gestion de Scolarité',
            theme: themeProvider.isDarkTheme
                ? ThemeData.dark()
                : ThemeData(
                    primarySwatch: Colors.blue,
                    appBarTheme: const AppBarTheme(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      centerTitle: true,
                    ),
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: SafeArea(child: child!),
              );
            },
            initialRoute: '/',
            routes: {
              '/': (context) => const LoginRegisterScreen(),
              '/inscription': (context) => const RegistrationScreen(),
              '/home': (context) => const HomeScreen(),
              '/home-page': (context) => const HomePage(),
              '/settings': (context) => const SettingsScreen(),
              '/student-profile': (context) => const StudentProfileScreen(),
              '/receipt': (context) => const ReceiptScreen(
                    name: '',
                    lastName: '',
                    filiere: '',
                    annee: '',
                    montant: 0.0,
                    studentId: '',
                    createdAt: '',
                  ),
            },
          );
        },
      ),
    );
  }
}

// Suppression de la classe SettingsScreen redondante
// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Paramètres'),
//       ),
//       body: ListView(
//         children: <Widget>[
//           ListTile(
//             title: const Text('Déconnexion'),
//             leading: const Icon(Icons.exit_to_app),
//             onTap: () {
//               Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

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


