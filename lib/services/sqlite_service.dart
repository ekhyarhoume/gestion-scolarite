// No code changes needed for Firestore removal. This file is already only using SQLite and local logic.
// Requires sqflite and path packages. Make sure to add them to pubspec.yaml:
// sqflite: ^2.0.0+4
// path: ^1.8.0
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';

class SQLiteService {
  static final SQLiteService _instance = SQLiteService._internal();
  factory SQLiteService() => _instance;
  SQLiteService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'students.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            lastName TEXT,
            studentId TEXT UNIQUE,
            bacNumber TEXT,
            email TEXT,
            phone TEXT,
            filiere TEXT,
            annee TEXT,
            photoPath TEXT,
            montant REAL,
            paymentStatus TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Student?> getStudentById(String studentId) async {
    final db = await database;
    final maps = await db.query('students', where: 'studentId = ?', whereArgs: [studentId]);
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  Future<Student?> getStudentByBac(String bacNumber) async {
    final db = await database;
    final maps = await db.query('students', where: 'bacNumber = ?', whereArgs: [bacNumber]);
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final maps = await db.query('students');
    return maps.map((e) => Student.fromMap(e)).toList();
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update('students', student.toMap(), where: 'studentId = ?', whereArgs: [student.studentId]);
  }

  Future<int> deleteStudent(String studentId) async {
    final db = await database;
    return await db.delete('students', where: 'studentId = ?', whereArgs: [studentId]);
  }

  // Generates a unique student ID in the format 'I' + 5 digits (18000-20000)
  Future<String> generateUniqueStudentId() async {
    final db = await database;
    const int min = 18000;
    const int max = 20000;
    String newId;
    bool exists = true;
    final random = DateTime.now().millisecondsSinceEpoch;
    int attempt = 0;
    do {
      // Use a deterministic but varying approach to avoid infinite loops
      int number = min + ((random + attempt) % (max - min + 1));
      newId = 'I' + number.toString().padLeft(5, '0');
      final result = await db.query('students', where: 'studentId = ?', whereArgs: [newId]);
      exists = result.isNotEmpty;
      attempt++;
      if (attempt > (max - min + 1)) {
        throw Exception('No available student IDs in the specified range.');
      }
    } while (exists);
    return newId;
  }
} 