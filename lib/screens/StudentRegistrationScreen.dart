import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_scolarite/screens/ReceiptScreen.dart';
import 'package:gestion_scolarite/widgets/bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({Key? key}) : super(key: key);

  @override
  _StudentRegistrationScreenState createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bacNumberController = TextEditingController();
  final TextEditingController nniController = TextEditingController();
  final TextEditingController montantController = TextEditingController();
  final TextEditingController paymentController = TextEditingController();
  String? selectedFiliere;
  String? selectedAnnee;
  XFile? _image;
  String? _filePath;
  bool _paymentMade = false;
  int _currentIndex = 0;

  final List<String> filieres = [
    'Informatique de gestion',
    'Finance comptabilite',
    'Banque et assurance',
    'Gestion de ressource humaine',
    'Technique Commerciale et Marketing',
    'Statistique appliquee a la economie'
  ];
  final List<String> annees = ['L1', 'L2', 'L3', 'M1', 'M2'];

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

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
    if (emailController.text.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      _showErrorDialog("Veuillez entrer une adresse email valide");
      return;
    }
    if (bacNumberController.text.isEmpty ||
        !RegExp(r'^\d{5}$').hasMatch(bacNumberController.text)) {
      _showErrorDialog("Le numéro Bac doit contenir exactement 5 chiffres");
      return;
    }
    if (nniController.text.isEmpty ||
        !RegExp(r'^\d{10}$').hasMatch(nniController.text)) {
      _showErrorDialog("Le numéro NNI doit contenir exactement 10 chiffres");
      return;
    }
    if (selectedFiliere == null) {
      _showErrorDialog("Veuillez sélectionner une filière");
      return;
    }
    if (selectedAnnee == null) {
      _showErrorDialog("Veuillez sélectionner une année d'étude");
      return;
    }
    if (_image == null) {
      _showErrorDialog("Veuillez choisir une photo");
      return;
    }

    try {
      // Télécharger l'image sur Firebase Storage
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('student_photos/${_image!.name}');
      final UploadTask uploadTask = storageRef.putFile(File(_image!.path));
      final TaskSnapshot downloadUrl = await uploadTask;
      final String imageUrl = await downloadUrl.ref.getDownloadURL();

      // Sauvegarder les données de l'étudiant dans Firestore
      final studentData = {
        'name': nameController.text,
        'lastName': lastNameController.text,
        'email': emailController.text,
        'bacNumber': bacNumberController.text,
        'nni': nniController.text,
        'filiere': selectedFiliere,
        'annee': selectedAnnee,
        'photoUrl': imageUrl,
        'montant': double.tryParse(montantController.text) ?? 0.0,
        'payment': paymentController.text,
        'paymentStatus': _paymentMade ? 'Payé' : 'Non payé',
        'registrationDate': Timestamp.now(),
        'type': 'nouveau',
      };

      await FirebaseFirestore.instance.collection('students').add(studentData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription réussie !')),
      );

      // Naviguer vers le ReceiptScreen après inscription réussie
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            name: nameController.text,
            lastName: lastNameController.text,
            filiere: selectedFiliere!,
            annee: selectedAnnee!,
            montant: 100.0,
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog("Une erreur est survenue lors de l'inscription: ${e.toString()}");
    }
  }

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
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inscription d\'un nouvel étudiant',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 30,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: const BoxDecoration(
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
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: bacNumberController,
                decoration: InputDecoration(
                  labelText: 'Numéro Bac',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nniController,
                decoration: InputDecoration(
                  labelText: 'Numéro NNI',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text(
                'Informations académiques',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              
              const SizedBox(height: 20),
              TextField(
                controller: montantController,
                decoration: InputDecoration(
                  labelText: 'Montant à payer',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
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
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedAnnee,
                items: annees.map((String annee) {
                  return DropdownMenuItem<String>(
                    value: annee,
                    child: Text(annee),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAnnee = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Année d\'étude',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Choisir une photo'),
              ),
              if (_image != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Photo sélectionnée: ${_image!.name}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Choisir un fichier justificatif'),
              ),
              if (_filePath != null)
                Text(
                  'Fichier sélectionné: $_filePath',
                  style: const TextStyle(color: Colors.white),
                ),
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

