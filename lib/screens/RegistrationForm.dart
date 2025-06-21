import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:gestion_scolarite/screens/ReceiptScreen.dart';
import 'package:gestion_scolarite/services/sqlite_service.dart';
import 'package:gestion_scolarite/models/student.dart';
import 'package:gestion_scolarite/services/local_storage_service.dart';
import 'package:gestion_scolarite/widgets/bottom_nav_bar.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController cinController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController montantController = TextEditingController();  // Nouveau champ pour le montant
  final TextEditingController studentNumberController = TextEditingController();
  String? selectedFiliere;
  String? selectedAnnee;
  final List<String> filieres = ['Informatique de gestion', 'Finance comptabilite', 'Banque et assurance', 'Gestion de ressource humaine', 'Technique Commerciale et Marketing', 'Statistique appliquee a la economie'];
  final List<String> annees = ['L1', 'L2', 'L3', 'M1', 'M2'];

  XFile? _image;
  String? _filePath;

  bool _paymentSuccessful = false;
  String _registrationStatus = "En cours"; // Statut initial de l'inscription
    int _currentIndex = 0;
  // Méthode pour choisir la photo
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedImage;
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  // Sauvegarder les données de l'étudiant dans Firestore
  Future<void> _registerStudent() async {
    // Validation des champs
    if (nameController.text.isEmpty) {
      _showErrorDialog("Le nom est requis");
      return;
    }
    if (lastNameController.text.isEmpty) {
      _showErrorDialog("Le prénom est requis");
      return;
    }
    if (cinController.text.isEmpty || !RegExp(r'^\d{10}$').hasMatch(cinController.text)) {
      _showErrorDialog("Le CIN doit contenir exactement 10 chiffres");
      return;
    }
    // if (phoneController.text.isEmpty || !RegExp(r'^\d{5}$').hasMatch(phoneController.text)) {
    //   _showErrorDialog("Le numéro Bac doit contenir exactement 5 chiffres");
    //   return;
    // }
    if (studentNumberController.text.isEmpty || !RegExp(r'^\d{5}$').hasMatch(studentNumberController.text)) {
      _showErrorDialog("Le numéro d'étudiant doit contenir exactement 5 chiffres");
      return;
    }
    if (selectedFiliere == null) {
      _showErrorDialog("Veuillez sélectionner une filière");
      return;
    }
    if (_image == null) {
      _showErrorDialog("Veuillez choisir une photo");
      return;
    }
    if (montantController.text.isEmpty || double.tryParse(montantController.text) == null) {
      _showErrorDialog("Veuillez entrer un montant valide");
      return;
    }

    try {
      // Save image locally
      final String imagePath = await LocalStorageService.saveImage(
        File(_image!.path),
        _image!.name,
      );
      // Create a new Student object
      final student = Student(
        name: nameController.text,
        lastName: lastNameController.text,
        studentId: studentNumberController.text,
        bacNumber: phoneController.text,
        email: phoneController.text, // or use a separate email field if needed
        phone: phoneController.text,
        filiere: selectedFiliere!,
        annee: selectedAnnee!,
        photoPath: imagePath,
        montant: double.parse(montantController.text),
        paymentStatus: _paymentSuccessful ? 'Payé' : 'Non payé',
        createdAt: DateTime.now().toIso8601String(),
      );
      await SQLiteService().insertStudent(student);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription réussie !')),
      );
      // Navigate to ReceiptScreen after successful registration
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            name: nameController.text,
            lastName: lastNameController.text,
            filiere: selectedFiliere!,
            annee: selectedAnnee!,
            montant: double.parse(montantController.text),
            studentId: studentNumberController.text,
            createdAt: DateTime.now().toIso8601String(),
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog("Une erreur est survenue lors de l'inscription: "+e.toString());
    }
  }

  // Fonction pour afficher un alert dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erreur"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
   void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/receipt');
        break;
      case 2:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription d\'un ancien étudiant',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 30,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: <Widget>[
              const Text(
                'Informations personnelles',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  labelStyle: const TextStyle(color: Colors.white), // Couleur du label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // Coins arrondis
                    borderSide: BorderSide(
                      color: Colors.white, // Couleur de la bordure
                      width: 2, // Épaisseur de la bordure
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  labelStyle: const TextStyle(color: Colors.white), // Couleur du label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // Coins arrondis
                    borderSide: BorderSide(
                      color: Colors.white, // Couleur de la bordure
                      width: 2, // Épaisseur de la bordure
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Le prénom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: cinController,
                decoration: InputDecoration(
                  labelText: 'CIN',
                  labelStyle: const TextStyle(color: Colors.white), // Couleur du label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // Coins arrondis
                    borderSide: BorderSide(
                      color: Colors.white, // Couleur de la bordure
                      width: 2, // Épaisseur de la bordure
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty || value.length != 10 || !RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Le CIN doit contenir exactement 10 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  labelStyle: const TextStyle(color: Colors.white), // Couleur du label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // Coins arrondis
                    borderSide: BorderSide(
                      color: Colors.white, // Couleur de la bordure
                      width: 2, // Épaisseur de la bordure
                    ),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty || value.length != 5 || !RegExp(r'^\d{5}$').hasMatch(value)) {
                    return 'Le numéro Bac doit contenir exactement 5 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: studentNumberController,
                decoration: InputDecoration(
                  labelText: 'Numéro d\'étudiant',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty || value.length != 8 || !RegExp(r'^\d{8}$').hasMatch(value)) {
                    return 'Le numéro d\'étudiant doit contenir exactement 8 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Informations académiques',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedFiliere,
                items: filieres.map((String filiere) {
                  return DropdownMenuItem<String>(
                    value: filiere,
                    child: Text(filiere),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFiliere = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Filière',
                  labelStyle: const TextStyle(color: Colors.white), // Couleur du label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // Coins arrondis
                    borderSide: BorderSide(
                      color: Colors.white, // Couleur de la bordure
                      width: 2, // Épaisseur de la bordure
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedAnnee,
                items: annees.map((String annee) {
                  return DropdownMenuItem<String>(
                    value: annee,
                    child: Text(annee, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAnnee = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Année d\'étude',
                  labelStyle: const TextStyle(color: Colors.white), // Couleur du label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // Coins arrondis
                    borderSide: BorderSide(
                      color: Colors.white, // Couleur de la bordure
                      width: 2, // Épaisseur de la bordure
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Nouveau champ pour le paiement
              TextFormField(
                controller: montantController,
                decoration: InputDecoration(
                  labelText: 'Montant à payer',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Veuillez entrer un montant valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Choisir une photo'),
              ),
              if (_image != null) ...[
                const SizedBox(height: 10),
                Text('Photo sélectionnée: ${_image!.name}', style: TextStyle(color: Colors.white)),
              ],
             
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerStudent,
                child: const Text('S\'inscrire'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
