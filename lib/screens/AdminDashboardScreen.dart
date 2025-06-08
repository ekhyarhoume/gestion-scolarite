import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_scolarite/widgets/bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

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

  Future<void> _updateStudentPhoto(String studentId, String currentPhotoUrl) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Supprimer l'ancienne photo si elle existe
      if (currentPhotoUrl.isNotEmpty) {
        try {
          final oldPhotoRef = FirebaseStorage.instance.refFromURL(currentPhotoUrl);
          await oldPhotoRef.delete();
        } catch (e) {
          print('Erreur lors de la suppression de l\'ancienne photo: $e');
        }
      }

      // Télécharger la nouvelle photo
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('student_photos/${DateTime.now().millisecondsSinceEpoch}_${image.name}');
      
      final uploadTask = storageRef.putFile(File(image.path));
      final snapshot = await uploadTask;
      final newPhotoUrl = await snapshot.ref.getDownloadURL();

      // Mettre à jour l'URL de la photo dans Firestore
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .update({
        'photoUrl': newPhotoUrl,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Fermer l'indicateur de chargement
      Navigator.pop(context);

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Fermer l'indicateur de chargement en cas d'erreur
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour de la photo: $e'),
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
                onPressed: () => _updateStudentPhoto(studentId, studentData['photoUrl'] ?? ''),
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
                        backgroundImage: studentData['photoUrl'] != null
                            ? NetworkImage(studentData['photoUrl'])
                            : null,
                        child: studentData['photoUrl'] == null
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
                            onPressed: () => _updateStudentPhoto(studentId, studentData['photoUrl'] ?? ''),
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
                            backgroundImage: data['photoUrl'] != null
                                ? NetworkImage(data['photoUrl'])
                                : null,
                            child: data['photoUrl'] == null
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