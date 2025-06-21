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
  bool isLogin = true;
  bool _isLoading = false;
  bool _isNewStudentRegistration = true; // Pour basculer entre BAC et Matricule

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _bacNumberController = TextEditingController();
  final TextEditingController _matriculeController = TextEditingController();

  Future<void> _loginWithStudentId() async {
    if (_studentIdController.text.isEmpty) {
      setState(() { errorMessage = 'Veuillez entrer votre numéro d\'étudiant'; });
      return;
    }
    setState(() { _isLoading = true; errorMessage = ''; });
    try {
      final student = await SQLiteService().getStudentById(_studentIdController.text.trim());
      if (student != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() { errorMessage = 'Aucun étudiant trouvé avec ce numéro'; });
      }
    } catch (e) {
      setState(() { errorMessage = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

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
        Navigator.pushReplacementNamed(context, '/inscription');
      }
    } catch (e) {
      setState(() { errorMessage = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _verifyOldStudent() async {
    if (_matriculeController.text.isEmpty) {
      setState(() { errorMessage = 'Veuillez entrer votre matricule'; });
      return;
    }
    setState(() { _isLoading = true; errorMessage = ''; });
    try {
      final student = await SQLiteService().getStudentById(_matriculeController.text.trim());
      if (student != null) {
        setState(() { errorMessage = 'Un compte pour ce matricule existe déjà. Veuillez vous connecter.'; });
      } else {
        // Si l'étudiant n'est pas trouvé par matricule, peut-être qu'il devrait s'inscrire normalement.
        // Ou afficher un message que le matricule n'est pas reconnu.
        setState(() { errorMessage = 'Matricule non reconnu. Veuillez vérifier ou vous inscrire comme nouvel étudiant.'; });
      }
    } catch (e) {
      setState(() { errorMessage = e.toString(); });
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
          : (isLogin ? _loginWithStudentId : _handleRegistrationVerification),
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
              isLogin ? 'Connexion' : 'Vérifier',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
    );
  }

  Widget _switchFormButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
          errorMessage = '';
          // Réinitialiser le type d'inscription lors du basculement
          _isNewStudentRegistration = true;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 194, 194, 194),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(
        isLogin ? "Je suis un nouveau étudiant" : "J'ai déjà un compte",
        style: const TextStyle(color: Colors.black, fontSize: 20),
      ),
    );
  }

  Widget _buildRegistrationTypeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: Text('Nouveau'),
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
        SizedBox(width: 10),
        ChoiceChip(
          label: Text('Ancien'),
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
                        if (isLogin) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: _studentIdController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0x3900FF37),
                                hintText: "Numéro d'étudiant",
                                hintStyle: const TextStyle(color: Color(0xFF717171)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(
                                  Icons.person_sharp,
                                  color: Color.fromARGB(255, 159, 159, 159),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
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
                                  hintStyle: const TextStyle(color: Color(0xFF717171)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.school,
                                    color: Color.fromARGB(255, 159, 159, 159),
                                  ),
                                ),
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
                                  hintStyle: const TextStyle(color: Color(0xFF717171)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.person_pin,
                                    color: Color.fromARGB(255, 159, 159, 159),
                                  ),
                                ),
                              ),
                            ),
                        ],
                        _errorMessage(),
                        _submitButton(),
                        const SizedBox(height: 10),
                        _switchFormButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
