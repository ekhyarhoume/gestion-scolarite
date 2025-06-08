import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String phone;
  final String filiere;
  final String annee;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? photoUrl;
  final double montant;
  final String? paymentStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? photoUpdatedAt;

  Student({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.filiere,
    required this.annee,
    required this.status,
    this.photoUrl,
    required this.montant,
    this.paymentStatus,
    required this.createdAt,
    this.updatedAt,
    this.photoUpdatedAt,
  });

  // Créer un Student à partir d'un document Firestore
  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      filiere: data['filiere'] ?? '',
      annee: data['annee'] ?? '',
      status: data['status'] ?? 'pending',
      photoUrl: data['photoUrl'],
      montant: (data['montant'] ?? 0.0).toDouble(),
      paymentStatus: data['paymentStatus'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      photoUpdatedAt: data['photoUpdatedAt'] != null ? (data['photoUpdatedAt'] as Timestamp).toDate() : null,
    );
  }

  // Convertir un Student en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'filiere': filiere,
      'annee': annee,
      'status': status,
      'photoUrl': photoUrl,
      'montant': montant,
      'paymentStatus': paymentStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (photoUpdatedAt != null) 'photoUpdatedAt': Timestamp.fromDate(photoUpdatedAt!),
    };
  }

  // Créer une copie de Student avec des modifications
  Student copyWith({
    String? name,
    String? lastName,
    String? email,
    String? phone,
    String? filiere,
    String? annee,
    String? status,
    String? photoUrl,
    double? montant,
    String? paymentStatus,
    DateTime? updatedAt,
    DateTime? photoUpdatedAt,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      filiere: filiere ?? this.filiere,
      annee: annee ?? this.annee,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      montant: montant ?? this.montant,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photoUpdatedAt: photoUpdatedAt ?? this.photoUpdatedAt,
    );
  }
} 