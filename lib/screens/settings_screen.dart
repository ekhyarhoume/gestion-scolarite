import 'package:flutter/material.dart';
import 'package:gestion_scolarite/widgets/bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 2;
  String? _profilePhotoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();
        
        if (doc.exists && doc.data()?['photoUrl'] != null) {
          setState(() {
            _profilePhotoUrl = doc.data()?['photoUrl'];
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement de la photo: $e');
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
          .child('admin_photos/${user.uid}_${DateTime.now().millisecondsSinceEpoch}');
      
      final uploadTask = storageRef.putFile(File(image.path));
      final snapshot = await uploadTask;
      final newPhotoUrl = await snapshot.ref.getDownloadURL();

      // Mettre à jour l'URL de la photo dans Firestore
      await FirebaseFirestore.instance
          .collection('admins')
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
        // Already on settings screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF395D5D),
        elevation: 30,
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with profile info
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : CircleAvatar(
                              radius: 50,
                              backgroundImage: _profilePhotoUrl != null
                                  ? NetworkImage(_profilePhotoUrl!)
                                  : null,
                              child: _profilePhotoUrl == null
                                  ? const Icon(Icons.person, size: 50, color: Colors.white)
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
                          onPressed: _isLoading ? null : _updateProfilePhoto,
                          tooltip: 'Modifier la photo de profil',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Profil Administrateur',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Contact Info
              Card(
                color: Colors.white.withOpacity(0.2),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.white),
                      title: const Text(
                        '+22231676691',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          // TODO: Implement edit phone functionality
                        },
                      ),
                    ),
                    const Divider(color: Colors.white),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.white),
                      title: const Text(
                        'iscae.mr@gmail.com',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          // TODO: Implement edit email functionality
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Additional Settings
              Card(
                color: Colors.white.withOpacity(0.2),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language, color: Colors.white),
                      title: const Text(
                        'Langue',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: () {
                        // TODO: Implement language selection
                      },
                    ),
                    const Divider(color: Colors.white),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text(
                        'Déconnexion',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur lors de la déconnexion: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
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