import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_scolarite/main.dart';
//import 'home_screen.dart';  // L'écran d'accueil ou administrateur après connexion
import 'package:gestion_scolarite/constants/iamges_paths.dart';
import 'package:gestion_scolarite/models/auth.dart';
import 'package:gestion_scolarite/screens/home_screen.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  String? errorMessage = '';
  bool isLogin = true;
  bool _isObscured = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  Future<void> signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      errorMessage = '';
    });

    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun utilisateur trouvé avec cet email';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        case 'user-disabled':
          message = 'Ce compte a été désactivé';
          break;
        default:
          message = 'Une erreur est survenue: ${e.message}';
      }
      setState(() {
        errorMessage = message;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Une erreur inattendue est survenue';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      errorMessage = '';
    });

    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Le mot de passe est trop faible';
          break;
        case 'email-already-in-use':
          message = 'Un compte existe déjà avec cet email';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        default:
          message = 'Une erreur est survenue: ${e.message}';
      }
      setState(() {
        errorMessage = message;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Une erreur inattendue est survenue';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      onPressed: _isLoading ? null : (isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword),
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
              isLogin ? 'Connexion' : 'Inscription',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
    );
  }

  Widget _switchFormButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
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
        isLogin ? "Register" : "Login",
        style: TextStyle(color: Colors.black, fontSize: 24),
      ),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: TextFormField(
                            controller: _controllerEmail,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0x3900FF37),
                              hintText: "Email",
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
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: TextFormField(
                            obscureText: _isObscured,
                            controller: _controllerPassword,
                            validator: _validatePassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0x3900FF37),
                              hintText: "Mot de passe",
                              hintStyle: const TextStyle(color: Color(0xFF717171)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Color.fromARGB(255, 159, 159, 159),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscured ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscured = !_isObscured;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
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
