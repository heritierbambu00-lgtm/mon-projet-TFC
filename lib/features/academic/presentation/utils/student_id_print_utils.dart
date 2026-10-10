import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../auth/domain/entities/etudiant_entity.dart';

class StudentIdPrintUtils {
  static const PdfColor officialBlue = PdfColor.fromInt(0xFF0D47A1);

  static Future<pw.Widget> _buildHeader(pw.ImageProvider? logo) async {
    return pw.Column(
      children: [
        pw.Text('REPUBLIQUE DEMOCRATIQUE DU CONGO',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: officialBlue)),
        pw.Text('ENSEIGNEMENT SUPERIEUR ET UNIVERSITAIRE',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: officialBlue)),
        pw.Text('INSTITUT SUPERIEUR DES TECHNIQUES MEDICALES DE MAHAGI',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: officialBlue)),
        pw.Text('Site : www.istm-mahagi.edu',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 10, color: officialBlue, decoration: pw.TextDecoration.underline)),
        pw.SizedBox(height: 10),
        if (logo != null)
          pw.Container(height: 65, width: 65, child: pw.Image(logo)),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 1.5, color: officialBlue),
        pw.SizedBox(height: 1),
        pw.Divider(thickness: 0.5, color: officialBlue),
      ],
    );
  }

  static Future<void> print(List<EtudiantEntity> students) async {
    final pdf = pw.Document();
    final logo = await imageFromAssetBundle('assets/images/logo.jpg');
    final header = await _buildHeader(logo);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Center(child: header),
          pw.SizedBox(height: 25),
          pw.Center(
            child: pw.Text('IDENTIFIANTS DE CONNEXION DES ETUDIANTS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, decoration: pw.TextDecoration.underline, color: officialBlue)),
          ),
          pw.SizedBox(height: 30),
          pw.TableHelper.fromTextArray(
            context: context,
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: officialBlue),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.center,
            headers: ['N°', 'NOM COMPLET', 'MATRICULE', 'MOT DE PASSE'],
            data: List<List<dynamic>>.generate(students.length, (index) {
              final s = students[index];
              return [
                index + 1,
                "${s.nomEtu} ${s.postnomEtu} ${s.prenomEtu}".toUpperCase(),
                s.matriculeEtu,
                s.password,
              ];
            }),
          ),
          pw.SizedBox(height: 50),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              children: [
                pw.Text('Fait à Mahagi, le ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 10),
                pw.Text('Le Secrétaire de Direction', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
