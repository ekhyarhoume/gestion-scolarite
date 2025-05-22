import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    // Récupère la hauteur totale de l'écran
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Inscription Étudiante',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 20,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.5, // fixe la hauteur à 50% de l'écran
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 50,
                      childAspectRatio: 2.5,
                    ),
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 76, 175, 162),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _navigateTo(context, '/home'),
                        child: const Center(child: Text('Inscription Étudiante')),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 76, 175, 145),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _navigateTo(context, '/admin-dashboard'),
                        child: const Center(child: Text('dashboard ')),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 76, 175, 162),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _navigateTo(context, '/interface3'),
                        child: const Center(child: Text('Reçu d\'inscription')),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 76, 175, 162),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _navigateTo(context, '/login'),
                        child: const Center(child: Text('login du register')),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10), // espace entre la grid et le texte
              const Text(
                'Bienvenue',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
