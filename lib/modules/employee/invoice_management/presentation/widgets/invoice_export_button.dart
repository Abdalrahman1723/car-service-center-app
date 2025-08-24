import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_world/shared/models/invoice.dart';
import 'package:m_world/core/constants/app_strings.dart';
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

  // Helper method to get payment method display text in Arabic
  String _getPaymentMethodText(String paymentMethod) {
    switch (paymentMethod) {
      case 'Cash':
        return 'نقداً';
      case 'Credit Card':
        return 'بطاقة ائتمان';
      case 'Bank Transfer':
        return 'تحويل بنكي';
      case 'Instapay':
        return 'انستاباي';
      default:
        return 'غير محدد';
    }
  }

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

    // Load logo image with error handling
    pw.MemoryImage? logoImage;
    try {
      final imageData = await rootBundle.load('assets/icon.png');
      logoImage = pw.MemoryImage(imageData.buffer.asUint8List());
      print('Logo loaded successfully');
    } catch (e) {
      print('Error loading logo: $e');
      // Continue without logo if loading fails
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header with logo and service center info
              _buildHeader(logoImage, boldFont, font),
              pw.SizedBox(height: 30),

              // Invoice title and number
              _buildInvoiceTitle(boldFont),
              pw.SizedBox(height: 25),

              // Two column layout for client and invoice details
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Client information
                  pw.Expanded(child: _buildClientSection(font, boldFont)),
                  pw.SizedBox(width: 20),
                  // Invoice details
                  pw.Expanded(
                    child: _buildInvoiceDetailsSection(font, boldFont),
                  ),
                ],
              ),
              pw.SizedBox(height: 25),

              // Items table
              _buildItemsTable(font, boldFont),
              pw.SizedBox(height: 20),

              // Summary section
              _buildSummarySection(font, boldFont),
              pw.SizedBox(height: 20),

              // Notes section
              if (invoice.notes != null && invoice.notes!.isNotEmpty)
                _buildNotesSection(invoice.notes!, font, boldFont),
              pw.SizedBox(height: 30),

              // Footer
              _buildFooter(font),
            ],
          );
        },
      ),
    );

    // Generate and display the PDF
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  pw.Widget _buildHeader(
    pw.MemoryImage? logoImage,
    pw.Font boldFont,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Service center name at the top
          pw.Text(
            'مركز خدمة M World',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 20,
              color: PdfColors.blue800,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 15),

          // Logo and contact info in a row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo (with fallback if image fails to load)
              if (logoImage != null)
                pw.Image(logoImage, width: 80, height: 80)
              else
                pw.Container(
                  width: 80,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue100,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.blue300, width: 2),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'M\nWorld',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 14,
                        color: PdfColors.blue800,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ),

              // Service center information
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'الهاتف: 01000094049',
                      style: pw.TextStyle(font: font, fontSize: 14),
                      textAlign: pw.TextAlign.right,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'العنوان:',
                      style: pw.TextStyle(font: boldFont, fontSize: 12),
                      textAlign: pw.TextAlign.right,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'العبور المنطقة الصناعية الدولى',
                      style: pw.TextStyle(font: font, fontSize: 11),
                      textAlign: pw.TextAlign.right,
                    ),
                    pw.Text(
                      'قطعه 13021 شارع 50 بجوار شركة امون للادوية',
                      style: pw.TextStyle(font: font, fontSize: 11),
                      textAlign: pw.TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInvoiceTitle(pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200, width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Job order',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 20,
              color: PdfColors.blue800,
            ),
          ),
          pw.Text(
            'رقم: ${invoice.id}',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 16,
              color: PdfColors.blue700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildClientSection(pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'معلومات العميل',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: PdfColors.grey800,
            ),
          ),
          pw.Divider(color: PdfColors.grey400, height: 20),
          _buildDetailRow('الاسم', clientName, font),
          _buildDetailRow('رقم العميل', invoice.clientId, font),
        ],
      ),
    );
  }

  pw.Widget _buildInvoiceDetailsSection(pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'تفاصيل الفاتورة',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: PdfColors.grey800,
            ),
          ),
          pw.Divider(color: PdfColors.grey400, height: 20),
          _buildDetailRow(
            'تاريخ الإصدار',
            DateFormat.yMMMd('ar').format(invoice.issueDate),
            font,
          ),
          _buildDetailRow('الصيانة بواسطة', invoice.maintenanceBy, font),
          _buildDetailRow(
            'حالة الدفع',
            invoice.isPayLater ? 'آجل' : 'مدفوع',
            font,
            color: invoice.isPayLater ? PdfColors.red700 : PdfColors.green700,
          ),
          if (invoice.paymentMethod != null)
            _buildDetailRow(
              'طريقة الدفع',
              _getPaymentMethodText(invoice.paymentMethod!),
              font,
            ),
          if (invoice.isPayLater &&
              invoice.downPayment != null &&
              invoice.downPayment! > 0)
            _buildDetailRow(
              'الدفعة المقدمة',
              '${invoice.downPayment!.toStringAsFixed(2)} ${AppStrings.currency}',
              font,
            ),
        ],
      ),
    );
  }

  pw.Widget _buildItemsTable(pw.Font font, pw.Font boldFont) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Table.fromTextArray(
        headers: ['الاسم', 'الكمية', 'السعر', 'الإجمالي'],
        data: invoice.items.map((item) {
          return [
            item.name,
            item.quantity.toString(),
            '${item.price!.toStringAsFixed(2)} ${AppStrings.currency}',
            '${(item.price! * item.quantity).toStringAsFixed(2)} ${AppStrings.currency}',
          ];
        }).toList(),
        headerStyle: pw.TextStyle(
          font: boldFont,
          color: PdfColors.white,
          fontSize: 12,
        ),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
        cellStyle: pw.TextStyle(font: font, fontSize: 11),
        cellAlignments: {
          0: pw.Alignment.centerRight,
          1: pw.Alignment.center,
          2: pw.Alignment.center,
          3: pw.Alignment.center,
        },
        columnWidths: {
          0: const pw.FlexColumnWidth(3),
          1: const pw.FlexColumnWidth(1),
          2: const pw.FlexColumnWidth(1.5),
          3: const pw.FlexColumnWidth(1.5),
        },
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      ),
    );
  }

  pw.Widget _buildSummarySection(pw.Font font, pw.Font boldFont) {
    final subtotal = invoice.items.fold<double>(
      0,
      (sum, item) => sum + (item.price! * item.quantity),
    );
    final discount = invoice.discount ?? 0.0;
    final total = subtotal - discount;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200, width: 1),
      ),
      child: pw.Column(
        children: [
          _buildSummaryRow('المجموع الفرعي', subtotal, font),
          _buildSummaryRow('الخصم', discount, font),
          pw.Divider(color: PdfColors.blue300, height: 20),
          _buildSummaryRow(
            'الإجمالي',
            total,
            font,
            isTotal: true,
            boldFont: boldFont,
          ),
          // Add total overall amount row
          pw.Divider(color: PdfColors.blue300, height: 20),
          _buildSummaryRow(
            'المبلغ الإجمالي للفاتورة',
            invoice.amount,
            font,
            isTotal: true,
            boldFont: boldFont,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryRow(
    String label,
    double amount,
    pw.Font font, {
    bool isTotal = false,
    pw.Font? boldFont,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: isTotal ? boldFont : font,
              fontSize: isTotal ? 14 : 12,
              color: isTotal ? PdfColors.blue800 : PdfColors.black,
            ),
          ),
          pw.Text(
            '${amount.toStringAsFixed(2)} ${AppStrings.currency}',
            style: pw.TextStyle(
              font: isTotal ? boldFont : font,
              fontSize: isTotal ? 14 : 12,
              color: isTotal ? PdfColors.blue800 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildNotesSection(String notes, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.yellow300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            AppStrings.notes,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: PdfColors.orange800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(notes, style: pw.TextStyle(font: font, fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'شكراً لثقتكم في خدماتنا',
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'للاستفسارات: ${AppStrings.serviceCenterPhoneNumber}',
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
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
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 11)),
          pw.Text(
            value,
            style: pw.TextStyle(font: font, fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}
