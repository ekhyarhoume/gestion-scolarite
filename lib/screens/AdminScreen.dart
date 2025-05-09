import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Liste des inscriptions simulées
  List<Map<String, String>> studentRequests = [
    {
      'name': 'Ahmed',
      'filiere': 'Informatique de gestion',
      'status': 'En attente',
      'payment': 'Non payé'
    },
    {
      'name': 'Mariem',
      'filiere': 'Banque et assurance',
      'status': 'En attente',
      'payment': 'Non payé'
    },
    {
      'name': 'Khadija',
      'filiere': 'Finance comptabilite',
      'status': 'En attente',
      'payment': 'Payé'
    }
  ];

  // Fonction pour générer le rapport PDF
  Future<void> _generateReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Rapport des Inscriptions', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Nom', 'Filière', 'État', 'Paiement'],
                data: studentRequests.map((student) {
                  return [
                    student['name'],
                    student['filiere'],
                    student['status'],
                    student['payment'],
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    // Imprimer ou afficher le PDF
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // Fonction pour mettre à jour l'état du paiement ou de l'inscription
  void _updateStatus(int index, String newStatus, String paymentStatus) {
    setState(() {
      studentRequests[index]['status'] = newStatus;
      studentRequests[index]['payment'] = paymentStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interface Administrateur'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: studentRequests.length,
              itemBuilder: (context, index) {
                final request = studentRequests[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text('${request['name']} (${request['filiere']})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('État: ${request['status']}'),
                        Text('Paiement: ${request['payment']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            _updateStatus(index, 'Validée', 'Payé');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _updateStatus(index, 'Rejetée', 'Non payé');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _generateReport,
            child: const Text('Générer le rapport'),
          ),
        ],
      ),
    );
  }
}
