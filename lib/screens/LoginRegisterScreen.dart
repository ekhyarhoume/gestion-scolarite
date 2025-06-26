import 'package:flutter/material.dart';
//import 'home_screen.dart';  // L'écran d'accueil ou administrateur après connexion
import 'package:gestion_scolarite/constants/iamges_paths.dart';
import 'package:gestion_scolarite/screens/home_screen.dart';
import 'package:gestion_scolarite/services/sqlite_service.dart';
import 'package:gestion_scolarite/models/student.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  String? errorMessage = '';
  bool _isLoading = false;
  bool _isNewStudentRegistration = true; // Pour basculer entre BAC et Matricule

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _bacNumberController = TextEditingController();
  final TextEditingController _matriculeController = TextEditingController();

  Future<void> _handleRegistrationVerification() async {
    if (_isNewStudentRegistration) {
      await _registerWithBacNumber();
    } else {
      await _verifyOldStudent();
    }
  }

  Future<void> _registerWithBacNumber() async {
    if (_bacNumberController.text.isEmpty) {
      setState(() { errorMessage = 'Veuillez entrer votre numéro de BAC'; });
      return;
    }
    setState(() { _isLoading = true; errorMessage = ''; });
    try {
      final student = await SQLiteService().getStudentByBac(_bacNumberController.text.trim());
      if (student != null) {
        setState(() { errorMessage = 'Un étudiant avec ce numéro de BAC existe déjà.'; });
      } else {
        Navigator.pushReplacementNamed(context, '/insecrie');
      }
    } catch (e) {
      setState(() { errorMessage = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _verifyOldStudent() async {
    final matricule = _matriculeController.text.trim();
    if (matricule.isEmpty) {
      setState(() { errorMessage = 'Veuillez entrer votre matricule'; });
      return;
    }
    setState(() { _isLoading = true; errorMessage = ''; });
    try {
      final student = await SQLiteService().getStudentById(matricule);
      if (student != null) {
        // Matricule found: redirect to registration form for old students
        Navigator.pushReplacementNamed(context, '/inscription', arguments: student);
      } else {
        // Not found: suggest registration
        setState(() { errorMessage = 'Matricule non reconnu. Veuillez vérifier ou vous inscrire comme nouvel étudiant.'; });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Non trouvé"),
            content: Text("Matricule non reconnu. Voulez-vous vous inscrire comme nouvel étudiant ?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/insecrie');
                },
                child: Text("S'inscrire"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Annuler"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() { errorMessage = "Erreur lors de la connexion. Veuillez réessayer."; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Widget _errorMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        errorMessage ?? '',
        style: const TextStyle(
          color: Colors.red,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : (_handleRegistrationVerification),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 210, 10, 255),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              'Entrer',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
    );
  }

  Widget _buildRegistrationTypeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 40,
          child: ChoiceChip(
            label: const Text('Nouveau'),
            selected: _isNewStudentRegistration,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _isNewStudentRegistration = true;
                  errorMessage = '';
                });
              }
            },
          ),
        ),
        const SizedBox(width: 15),
        SizedBox(
          width: 100,
          height: 40,
          child: ChoiceChip(
            label: const Text('Ancien'),
            selected: !_isNewStudentRegistration,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _isNewStudentRegistration = false;
                  errorMessage = '';
                });
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: h * .1),
                  Image.asset(IamgesPaths.appLogo, width: w * .7),
                  SizedBox(height: h * .05),
                  const Text(
                    "ISCAE",
                    style: TextStyle(
                      color: Color.fromARGB(255, 56, 83, 98),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Pacifico",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(w * .1, h * .01, w * .1, h * .01),
                    child: Column(
                      children: [
                          _buildRegistrationTypeToggle(),
                          SizedBox(height: 15),
                          if (_isNewStudentRegistration)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: TextFormField(
                                controller: _bacNumberController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0x3900FF37),
                                  hintText: "Numéro de BAC",
                                  hintStyle: const TextStyle(color: Color.fromARGB(255, 8, 8, 8)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.school,
                                    color: Color.fromARGB(255, 210, 10, 255),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre numéro de BAC';
                                  }
                                  // Vérifier que la valeur contient exactement 5 chiffres
                                  if (value.length != 5) {
                                    return 'Le numéro de BAC doit contenir exactement 5 chiffres';
                                  }
                                  final regExp = RegExp(r'^\d{5}$'); // Exactement 5 chiffres du début à la fin
                                  if (!regExp.hasMatch(value)) {
                                    return 'Le numéro de BAC doit contenir uniquement 5 chiffres';
                                  }
                                  return null;
                                },
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: TextFormField(
                                controller: _matriculeController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0x3900FF37),
                                  hintText: "Matricule",
                                  hintStyle: const TextStyle(color: Color.fromARGB(255, 7, 7, 7)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.person_pin,
                                    color: Color.fromARGB(255, 210, 10, 255),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre matricule';
                                  }
                                  final regExp = RegExp(r'^I\d{5}$');
                                  if (!regExp.hasMatch(value)) {
                                    return 'Le matricule doit commencer par I suivi de 5 chiffres';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),),
                        _errorMessage(),
                        _submitButton(),
            ]),)
          ),
        ),
      ),
    );
  }
}
