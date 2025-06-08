import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_scolarite/models/student.dart';

class StudentService {
  final CollectionReference _studentsCollection = FirebaseFirestore.instance.collection('students');

  // Créer un nouvel étudiant
  Future<Student> createStudent(Student student) async {
    try {
      DocumentReference docRef = await _studentsCollection.add(student.toFirestore());
      DocumentSnapshot doc = await docRef.get();
      return Student.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'étudiant: $e');
    }
  }

  // Obtenir un étudiant par son ID
  Future<Student> getStudent(String id) async {
    try {
      DocumentSnapshot doc = await _studentsCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Étudiant non trouvé');
      }
      return Student.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'étudiant: $e');
    }
  }

  // Mettre à jour un étudiant
  Future<Student> updateStudent(String id, Map<String, dynamic> data) async {
    try {
      await _studentsCollection.doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return getStudent(id);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'étudiant: $e');
    }
  }

  // Supprimer un étudiant
  Future<void> deleteStudent(String id) async {
    try {
      await _studentsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'étudiant: $e');
    }
  }

  // Obtenir tous les étudiants
  Stream<List<Student>> getAllStudents() {
    return _studentsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Student.fromFirestore(doc))
            .toList());
  }

  // Obtenir les étudiants par filière
  Stream<List<Student>> getStudentsByFiliere(String filiere) {
    return _studentsCollection
        .where('filiere', isEqualTo: filiere)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Student.fromFirestore(doc))
            .toList());
  }

  // Obtenir les étudiants par statut
  Stream<List<Student>> getStudentsByStatus(String status) {
    return _studentsCollection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Student.fromFirestore(doc))
            .toList());
  }

  // Mettre à jour le statut d'un étudiant
  Future<Student> updateStudentStatus(String id, String status) async {
    try {
      await _studentsCollection.doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return getStudent(id);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Mettre à jour le statut de paiement
  Future<Student> updatePaymentStatus(String id, String status) async {
    try {
      await _studentsCollection.doc(id).update({
        'paymentStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return getStudent(id);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut de paiement: $e');
    }
  }

  // Mettre à jour la photo de profil
  Future<Student> updateProfilePhoto(String id, String photoUrl) async {
    try {
      await _studentsCollection.doc(id).update({
        'photoUrl': photoUrl,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      });
      return getStudent(id);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la photo: $e');
    }
  }

  // Rechercher des étudiants
  Stream<List<Student>> searchStudents(String query) {
    return _studentsCollection
        .orderBy('name')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Student.fromFirestore(doc))
            .toList());
  }
} 