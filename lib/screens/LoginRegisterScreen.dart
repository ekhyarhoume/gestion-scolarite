import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_scolarite/main.dart';
//import 'home_screen.dart';  // L'écran d'accueil ou administrateur après connexion
import 'package:gestion_scolarite/constants/iamges_paths.dart';
import 'package:gestion_scolarite/models/auth.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  String? errorMessage = '';
  bool isLogin = true;
  bool _isObscured = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 210, 10, 255),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(
        isLogin ? 'Login' : 'Register',
        style: TextStyle(color: Colors.white, fontSize: 24),
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
          child: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  // Appliquer un dégradé de fond
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.green], // Dégradé du bleu au vert
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: h * .1),
                      Image.asset(IamgesPaths.appLogo, width: w * .7),
                      SizedBox(height: h * .05),
                      Column(
                        children: [
                          Text(
                            "ISCAE",
                            style: TextStyle(
                                color: Color.fromARGB(255, 56, 83, 98),
                                fontSize: w * .06,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Pacifico"),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(w * .1, h * .01, w * .1, h * .01),
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextField(
                              controller: _controllerEmail,
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
                            child: TextField(
                              obscureText: _isObscured,
                              controller: _controllerPassword,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0x3900FF37),
                                hintText: "password",
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
                                      _isObscured
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscured = !_isObscured;
                                      });
                                    }),
                              ),
                            ),
                          )
                        ]),
                      ),
                      _submitButton(),
                      const SizedBox(height: 10),
                      _switchFormButton(),
                    ],
                  ),
                ),
              ))),
    );
  }
}
