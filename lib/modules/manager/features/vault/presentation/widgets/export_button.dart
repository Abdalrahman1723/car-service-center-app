import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Add printing for PDF preview/share
import 'package:m_world/core/constants/app_strings.dart';
import '../../domain/entities/vault_transaction.dart';
import '../../domain/usecases/export_transaction.dart';

class ExportButton extends StatelessWidget {
  final List<VaultTransaction> transactions;

  const ExportButton({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _exportToPdf(context),
      child: const Text('تصدير PDF'),
    );
  }

  // ExportButton widget code...

  Future<void> _exportToPdf(BuildContext context) async {
    // Use case to get the summary data.
    final exportUseCase = ExportVaultTransactions();
    final data = await exportUseCase.execute(transactions);

    // Handle case with no transactions.
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا توجد حركات للتصدير.')));
      return;
    }

    // Load fonts that support Arabic (e.g., Cairo).
    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl, // Set text direction to RTL
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Styled title for the document.
              pw.Text(
                'تقرير حركات الخزينة', // Translated title
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 24,
                  color: PdfColors.blue700,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 20),

              // Summary section with a clean layout.
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildSummaryRow(
                      'إجمالي الإيرادات', // Translated
                      data['totalIncome'] as double,
                      PdfColors.green700,
                      font,
                    ),
                    _buildSummaryRow(
                      'إجمالي المصروفات', // Translated
                      data['totalExpenses'] as double,
                      PdfColors.red700,
                      font,
                    ),
                    pw.Divider(),
                    _buildSummaryRow(
                      'صافي الرصيد', // Translated
                      data['netBalance'] as double,
                      PdfColors.black,
                      font,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Table of detailed transactions.
              pw.Table.fromTextArray(
                headers: [
                  'النوع',
                  'الفئة',
                  'المبلغ',
                  'التاريخ',
                  'ملاحظات',
                ], // Translated headers
                data: transactions.map((tx) {
                  return [
                    tx.type == 'income' ? 'دخل' : 'مصروف',
                    tx.category,
                    '${tx.amount.toStringAsFixed(2)} ${AppStrings.currency}',
                    tx.date.toLocal().toIso8601String().split('T').first,
                    tx.notes ?? 'غير محدد',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  font: boldFont,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey800,
                ),
                cellStyle: pw.TextStyle(font: font, fontSize: 10),
                cellAlignments: {
                  0: pw.Alignment.centerRight,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                },
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.5),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(3),
                },
              ),
            ],
          );
        },
      ),
    );

    // Generate and display the PDF.
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  // A helper function for the summary rows.
  pw.Widget _buildSummaryRow(
    String label,
    double amount,
    PdfColor color,
    pw.Font font,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text(
            '${amount.toStringAsFixed(2)} ${AppStrings.currency}',
            style: pw.TextStyle(font: font, fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}
