import 'package:flutter/material.dart';
import 'package:m_world/shared/models/invoice.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class InvoiceExportButton extends StatelessWidget {
  final Invoice invoice;
  final String clientName;

  const InvoiceExportButton({
    super.key,
    required this.invoice,
    required this.clientName,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _exportToPdf(context),
      child: const Text('Export PDF'),
    );
  }

  Future<void> _exportToPdf(BuildContext context) async {
    // Handle case with no items
    if (invoice.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا توجد عناصر للتصدير.')));
      return;
    }

    // Load fonts for Arabic support
    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Invoice title
              pw.Text(
                'Job order',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 24,
                  color: PdfColors.blue700,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 20),

              // Client and invoice details
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildDetailRow('اسم العميل', clientName, font),
                    _buildDetailRow('رقم العميل', invoice.clientId, font),
                    _buildDetailRow(
                      'تاريخ الإصدار',
                      DateFormat.yMMMd().format(invoice.issueDate),
                      font,
                    ),
                    _buildDetailRow(
                      'الصيانة بواسطة',
                      invoice.maintenanceBy,
                      font,
                    ),
                    _buildDetailRow(
                      'حالة الدفع',
                      invoice.isPaid ? 'مدفوع' : 'غير مدفوع',
                      font,
                    ),
                    if (invoice.isPaid && invoice.paymentMethod != null)
                      _buildDetailRow(
                        'طريقة الدفع',
                        invoice.paymentMethod!,
                        font,
                      ),
                    _buildDetailRow(
                      'الخصم',
                      invoice.discount != null
                          ? '${invoice.discount!.toStringAsFixed(2)} \$'
                          : '0.00 \$',
                      font,
                    ),
                    _buildDetailRow(
                      'الإجمالي',
                      '${invoice.amount.toStringAsFixed(2)} \$',
                      font,
                      color: PdfColors.green700,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Items table
              pw.Table.fromTextArray(
                headers: ['الاسم', 'الكمية', 'السعر', 'الإجمالي'],
                data: invoice.items.map((item) {
                  return [
                    item.name,
                    item.quantity.toString(),
                    '${item.price!.toStringAsFixed(2)} \$',
                    '${(item.price! * item.quantity).toStringAsFixed(2)} \$',
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
                },
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
              ),
              pw.SizedBox(height: 20),

              // Notes section
              if (invoice.notes != null && invoice.notes!.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ملاحظات',
                      style: pw.TextStyle(font: boldFont, fontSize: 14),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      invoice.notes!,
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );

    // Generate and display the PDF
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  pw.Widget _buildDetailRow(
    String label,
    String value,
    pw.Font font, {
    PdfColor color = PdfColors.black,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(font: font, fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}
