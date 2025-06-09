import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_scolarite/widgets/bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:gestion_scolarite/services/local_storage_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String? selectedFiliere;
  int _currentIndex = 0;
  final List<String> filieres = [
    'Informatique de gestion',
    'Finance comptabilite',
    'Banque et assurance',
    'Gestion de ressource humaine',
    'Technique Commerciale et Marketing',
    'Statistique appliquee a la economie'
  ];

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

  Future<void> _updateStudentStatus(String studentId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inscription ${status.toLowerCase()}'),
          backgroundColor: status == 'Accepté' ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateStudentPhoto(String studentId, String currentPhotoPath) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Delete old photo if it exists
      if (currentPhotoPath.isNotEmpty) {
        await LocalStorageService.deleteImage(currentPhotoPath);
      }

      // Save new photo locally
      final String newPhotoPath = await LocalStorageService.saveImage(
        File(image.path),
        image.name,
      );

      // Update photo path in Firestore
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .update({
        'photoPath': newPhotoPath,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Close loading indicator
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading indicator if it's showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStudentDetails(Map<String, dynamic> studentData, String studentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Détails de l\'étudiant'),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _updateStudentPhoto(studentId, studentData['photoPath'] ?? ''),
                tooltip: 'Modifier la photo',
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: studentData['photoPath'] != null
                            ? NetworkImage(studentData['photoPath'])
                            : null,
                        child: studentData['photoPath'] == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            onPressed: () => _updateStudentPhoto(studentId, studentData['photoPath'] ?? ''),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Nom: ${studentData['name']} ${studentData['lastName']}'),
                Text('Email: ${studentData['email']}'),
                Text('Numéro Bac: ${studentData['bacNumber']}'),
                Text('NNI: ${studentData['nni']}'),
                Text('Filière: ${studentData['filiere']}'),
                Text('Année: ${studentData['annee']}'),
                Text('Montant: ${studentData['montant']} MRU'),
                Text('Statut: ${studentData['status'] ?? 'En attente'}'),
                if (studentData['paymentStatus'] != null)
                  Text('Paiement: ${studentData['paymentStatus']}'),
                if (studentData['photoUpdatedAt'] != null)
                  Text('Photo mise à jour le: ${(studentData['photoUpdatedAt'] as Timestamp).toDate().toString()}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tableau de bord administrateur',
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedFiliere,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Toutes les filières'),
                        ),
                        ...filieres.map((String filiere) {
                          return DropdownMenuItem<String>(
                            value: filiere,
                            child: Text(filiere),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFiliere = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Filtrer par filière',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedFiliere != null
                    ? FirebaseFirestore.instance
                        .collection('students')
                        .where('filiere', isEqualTo: selectedFiliere)
                        .orderBy('registrationDate', descending: true)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('students')
                        .orderBy('registrationDate', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Une erreur est survenue'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune inscription en attente',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      String status = data['status'] ?? 'En attente';
                      Color statusColor = status == 'Accepté'
                          ? Colors.green
                          : status == 'Rejeté'
                              ? Colors.red
                              : Colors.orange;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: Colors.white.withOpacity(0.2),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: data['photoPath'] != null
                                ? NetworkImage(data['photoPath'])
                                : null,
                            child: data['photoPath'] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            '${data['name']} ${data['lastName']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filière: ${data['filiere']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'Statut: $status',
                                style: TextStyle(color: statusColor),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.white),
                                onPressed: () => _showStudentDetails(data, document.id),
                              ),
                              if (status == 'En attente') ...[
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () => _updateStudentStatus(document.id, 'Accepté'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () => _updateStudentStatus(document.id, 'Rejeté'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
} 