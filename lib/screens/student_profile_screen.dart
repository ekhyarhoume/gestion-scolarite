import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_scolarite/widgets/bottom_nav_bar.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  int _currentIndex = 2;
  String? _profilePhotoUrl;
  bool _isLoading = false;
  Map<String, dynamic>? _studentData;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          setState(() {
            _studentData = doc.data();
            _profilePhotoUrl = doc.data()?['photoUrl'];
            _nameController.text = doc.data()?['name'] ?? '';
            _lastNameController.text = doc.data()?['lastName'] ?? '';
            _emailController.text = doc.data()?['email'] ?? '';
            _phoneController.text = doc.data()?['phone'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des données: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProfilePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Supprimer l'ancienne photo si elle existe
      if (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty) {
        try {
          final oldPhotoRef = FirebaseStorage.instance.refFromURL(_profilePhotoUrl!);
          await oldPhotoRef.delete();
        } catch (e) {
          print('Erreur lors de la suppression de l\'ancienne photo: $e');
        }
      }

      // Télécharger la nouvelle photo
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('student_photos/${user.uid}_${DateTime.now().millisecondsSinceEpoch}');
      
      final uploadTask = storageRef.putFile(File(image.path));
      final snapshot = await uploadTask;
      final newPhotoUrl = await snapshot.ref.getDownloadURL();

      // Mettre à jour l'URL de la photo dans Firestore
      await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .update({
        'photoUrl': newPhotoUrl,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _profilePhotoUrl = newPhotoUrl;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour de la photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .update({
        'name': _nameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      // Recharger les données
      await _loadStudentData();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        // Already on profile screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF395D5D),
        elevation: 30,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Photo de profil
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _profilePhotoUrl != null
                                ? NetworkImage(_profilePhotoUrl!)
                                : null,
                            child: _profilePhotoUrl == null
                                ? const Icon(Icons.person, size: 60, color: Colors.white)
                                : null,
                          ),
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
                              onPressed: _updateProfilePhoto,
                              tooltip: 'Modifier la photo de profil',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Informations du profil
                    Card(
                      color: Colors.white.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEditableField(
                              'Nom',
                              _nameController,
                              Icons.person,
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              'Prénom',
                              _lastNameController,
                              Icons.person_outline,
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              'Email',
                              _emailController,
                              Icons.email,
                              enabled: _isEditing,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              'Téléphone',
                              _phoneController,
                              Icons.phone,
                              enabled: _isEditing,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Informations académiques
                    if (_studentData != null) ...[
                      Card(
                        color: Colors.white.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informations académiques',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('Filière', _studentData!['filiere'] ?? 'Non spécifiée'),
                              const SizedBox(height: 8),
                              _buildInfoRow('Année', _studentData!['annee'] ?? 'Non spécifiée'),
                              const SizedBox(height: 8),
                              _buildInfoRow('Statut', _studentData!['status'] ?? 'En attente'),
                              if (_studentData!['paymentStatus'] != null) ...[
                                const SizedBox(height: 8),
                                _buildInfoRow('Paiement', _studentData!['paymentStatus']),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white30),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: value == 'Accepté'
                ? Colors.green
                : value == 'Rejeté'
                    ? Colors.red
                    : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 