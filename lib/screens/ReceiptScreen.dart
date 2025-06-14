import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReceiptScreen extends StatelessWidget {
  final String name;
  final String lastName;
  final String filiere;
  final String annee;
  final double montant;

  const ReceiptScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.filiere,
    required this.annee,
    required this.montant,
  }) : super(key: key);

  Future<void> _printReceipt() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Reçu d\'inscription',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Nom: $name $lastName', style: pw.TextStyle(fontSize: 18)),
              pw.Text('Filière: $filiere', style: pw.TextStyle(fontSize: 18)),
              pw.Text('Année d\'étude: $annee', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Text('Montant payé: $montant MRU', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Text('Date de paiement: ${DateTime.now().toLocal()}',
                  style: pw.TextStyle(fontSize: 18)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text('Reçu d\'inscription',
          style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, ),),
        ),
        elevation: 30,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: const Text(
                'Reçu d\'inscription',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Text('Nom: $name $lastName', style: TextStyle(fontSize: 18)),
            Text('Filière: $filiere', style: TextStyle(fontSize: 18)),
            Text('Année d\'étude: $annee', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text('Montant payé: $montant MRU', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text('Date de paiement: ${DateTime.now().toLocal()}',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _printReceipt,
              child: const Text('Imprimer le reçu'),
            ),
          ],
        ),
      ),
    );
  }
}
