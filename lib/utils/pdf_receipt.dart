import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RentReceiptPDF {
  static Future<void> generate({
    required String tenantName,
    required String roomNo,
    required String month,
    required String amount,
    required String paidDate,
    required String status,
    required String note,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "RENT RECEIPT",
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.Text(
                  "Tenant Name: $tenantName",
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text(
                  "Room Number: $roomNo",
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 20),

                pw.Text(
                  "Rent Month: $month",
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text(
                  "Amount Paid: ₹$amount",
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text(
                  "Paid Date: $paidDate",
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text("Status: $status", style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 20),

                if (note.isNotEmpty)
                  pw.Text("Note: $note", style: pw.TextStyle(fontSize: 16)),

                pw.Spacer(),

                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    children: [
                      pw.Text("__________________________"),
                      pw.Text("Owner Signature"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
