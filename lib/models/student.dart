import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final int? id;
  final String name;
  final String lastName;
  final String studentId; // Unique student ID
  final String bacNumber; // For new students
  final String email;
  final String phone;
  final String filiere;
  final String annee;
  final String? photoPath;
  final double montant;
  final String? paymentStatus;
  final String createdAt;

  Student({
    this.id,
    required this.name,
    required this.lastName,
    required this.studentId,
    required this.bacNumber,
    required this.email,
    required this.phone,
    required this.filiere,
    required this.annee,
    this.photoPath,
    required this.montant,
    this.paymentStatus,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'studentId': studentId,
      'bacNumber': bacNumber,
      'email': email,
      'phone': phone,
      'filiere': filiere,
      'annee': annee,
      'photoPath': photoPath,
      'montant': montant,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      lastName: map['lastName'] ?? '',
      studentId: map['studentId'] ?? '',
      bacNumber: map['bacNumber'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      filiere: map['filiere'] ?? '',
      annee: map['annee'] ?? '',
      photoPath: map['photoPath'],
      montant: (map['montant'] ?? 0.0).toDouble(),
      paymentStatus: map['paymentStatus'],
      createdAt: map['createdAt'] ?? '',
    );
  }
  static Student fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      id: int.tryParse(doc.id),
      name: data['name'] ?? '',
      lastName: data['lastName'] ?? '',
      studentId: data['studentId'] ?? '',
      bacNumber: data['bacNumber'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      filiere: data['filiere'] ?? '',
      annee: data['annee'] ?? '',
      photoPath: data['photoUrl'],
      montant: (data['montant'] ?? 0.0).toDouble(),
      paymentStatus: data['paymentStatus'],
      createdAt: (data['createdAt'] is String)
          ? data['createdAt']
          : (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? '',
    );
  }
}