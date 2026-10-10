import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../auth/domain/entities/etudiant_entity.dart';

class AttendancePrintUtils {
  static const PdfColor officialBlue = PdfColor.fromInt(0xFF0D47A1);

  static Future<pw.Widget> _buildHeader(pw.ImageProvider? logo) async {
    return pw.Column(
      children: [
        pw.Text('REPUBLIQUE DEMOCRATIQUE DU CONGO',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: officialBlue)),
        pw.Text('ENSEIGNEMENT SUPERIEUR ET UNIVERSITAIRE',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: officialBlue)),
        pw.Text('INSTITUT SUPERIEUR DES TECHNIQUES MEDICALES DE MAHAGI',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: officialBlue)),
        pw.Text('Site : www.istm-mahagi.edu',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 9, color: officialBlue, decoration: pw.TextDecoration.underline)),
        pw.SizedBox(height: 8),
        if (logo != null)
          pw.Container(height: 55, width: 55, child: pw.Image(logo)),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1.2, color: officialBlue),
        pw.SizedBox(height: 1),
        pw.Divider(thickness: 0.5, color: officialBlue),
      ],
    );
  }

  static Future<void> print({
    required List<EtudiantEntity> students,
    required String department,
    required String promotion,
  }) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final logo = await imageFromAssetBundle('assets/images/logo.jpg');
    final header = await _buildHeader(logo);

    final sortedStudents = List<EtudiantEntity>.from(students)
      ..sort((a, b) {
        final nameA = "${a.nomEtu} ${a.postnomEtu} ${a.prenomEtu}".toUpperCase();
        final nameB = "${b.nomEtu} ${b.postnomEtu} ${b.prenomEtu}".toUpperCase();
        return nameA.compareTo(nameB);
      });

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4, // PORTRAIT
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        build: (context) => [
          pw.Center(child: header),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('DEPARTEMENT : ${department.toUpperCase()}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: officialBlue, fontSize: 10)),
                  pw.Text('PROMOTION : ${promotion.toUpperCase()}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: officialBlue, fontSize: 10)),
                ],
              ),
              pw.Text('DATE : $dateStr',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: officialBlue, fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Center(
            child: pw.Text('LISTE DE PRESENCE DES ETUDIANTS',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    decoration: pw.TextDecoration.underline,
                    color: officialBlue)),
          ),
          pw.SizedBox(height: 15),
          pw.Table(
            border: pw.TableBorder.all(color: officialBlue, width: 0.7),
            columnWidths: {
              0: const pw.FixedColumnWidth(22),
              1: const pw.FlexColumnWidth(4.5),
              2: const pw.FixedColumnWidth(40),
              3: const pw.FixedColumnWidth(40),
              4: const pw.FixedColumnWidth(40),
              5: const pw.FixedColumnWidth(40),
              6: const pw.FixedColumnWidth(40),
              7: const pw.FixedColumnWidth(40),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('N°', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('NOMS ET PRENOMS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                  for (var i = 1; i <= 6; i++)
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('S$i', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                ],
              ),
              ...sortedStudents.asMap().entries.map((entry) {
                final index = entry.key;
                final s = entry.value;
                return pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${index + 1}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("${s.nomEtu} ${s.postnomEtu} ${s.prenomEtu}".toUpperCase(), style: const pw.TextStyle(fontSize: 9))),
                    for (var i = 1; i <= 6; i++)
                      pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.SizedBox()), 
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                children: [
                  pw.Text('Fait à Mahagi, le $dateStr', style: const pw.TextStyle(fontSize: 9)),
                  pw.SizedBox(height: 8),
                  pw.Text('Le Secrétaire de Direction', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.SizedBox(height: 40),
                  pw.Container(width: 130, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(style: pw.BorderStyle.dashed)))),
                ],
              ),
            ],
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'ISTM-MAHAGI • Page ${context.pageNumber}/${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
