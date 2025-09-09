import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/modules/employee/shipment_management/domain/entities/shipment.dart';
import 'package:m_world/modules/employee/supplier_management/domain/entities/supplier.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ShipmentExportButton extends StatelessWidget {
  final ShipmentEntity shipment;
  final SupplierEntity supplier;

  const ShipmentExportButton({
    super.key,
    required this.shipment,
    required this.supplier,
  });

  // Helper method to get payment method display text in Arabic
  String _getPaymentMethodText(String paymentMethod) {
    switch (paymentMethod) {
      case 'Cash':
        return 'نقداً';
      case 'Bank Transfer':
        return 'تحويل بنكي';
      case 'Credit':
        return 'آجل';
      default:
        return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _exportToPdf(context),
      child: const Text('تصدير PDF'),
    );
  }

  Future<void> _exportToPdf(BuildContext context) async {
    // Handle case with no items
    if (shipment.items.isEmpty) {
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
      log('Logo loaded successfully');
    } catch (e) {
      log('Error loading logo: $e');
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

              // Shipment title and number
              _buildShipmentTitle(boldFont),
              pw.SizedBox(height: 25),

              // Two column layout for supplier and shipment details
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Supplier information
                  pw.Expanded(child: _buildSupplierSection(font, boldFont)),
                  pw.SizedBox(width: 20),
                  // Shipment details
                  pw.Expanded(
                    child: _buildShipmentDetailsSection(font, boldFont),
                  ),
                ],
              ),
              pw.SizedBox(height: 25),

              // Items table
              _buildItemsTable(font, boldFont),
              pw.SizedBox(height: 20),

              // Payment summary section
              _buildPaymentSummary(font, boldFont),
              pw.SizedBox(height: 20),

              // Notes section
              if (shipment.notes != null && shipment.notes!.isNotEmpty)
                _buildNotesSection(shipment.notes!, font, boldFont),
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

  pw.Widget _buildShipmentTitle(pw.Font boldFont) {
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
            'فاتورة شحنة',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 20,
              color: PdfColors.blue800,
            ),
          ),
          pw.Text(
            'رقم: ${shipment.id}',
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

  pw.Widget _buildSupplierSection(pw.Font font, pw.Font boldFont) {
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
            'معلومات المورد',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: PdfColors.grey800,
            ),
          ),
          pw.Divider(color: PdfColors.grey400, height: 20),
          _buildDetailRow('الاسم', supplier.name, font),
          _buildDetailRow('رقم الهاتف', supplier.phoneNumber, font),
          _buildDetailRow(
            'الرصيد الحالي',
            '${supplier.balance.toStringAsFixed(2)} ${AppStrings.currency}',
            font,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildShipmentDetailsSection(pw.Font font, pw.Font boldFont) {
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
            'تفاصيل الشحنة',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: PdfColors.grey800,
            ),
          ),
          pw.Divider(color: PdfColors.grey400, height: 20),
          _buildDetailRow(
            'تاريخ الشحنة',
            DateFormat.yMMMd('ar').format(shipment.date),
            font,
          ),
          _buildDetailRow(
            'طريقة الدفع',
            _getPaymentMethodText(shipment.paymentMethod),
            font,
          ),
          _buildDetailRow(
            'المبلغ الإجمالي',
            '${shipment.totalAmount.toStringAsFixed(2)} ${AppStrings.currency}',
            font,
          ),
          _buildDetailRow(
            'المبلغ المدفوع',
            '${shipment.paidAmount.toStringAsFixed(2)} ${AppStrings.currency}',
            font,
          ),
          _buildDetailRow(
            'المبلغ المتبقي',
            '${(shipment.totalAmount - shipment.paidAmount).toStringAsFixed(2)} ${AppStrings.currency}',
            font,
            color: (shipment.totalAmount - shipment.paidAmount) > 0
                ? PdfColors.red700
                : PdfColors.green700,
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
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Table Header
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue700,
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'تفاصيل المنتجات',
                    style: pw.TextStyle(
                      font: boldFont,
                      color: PdfColors.white,
                      fontSize: 14,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Items Table
          pw.Table.fromTextArray(
            headers: ['اسم المنتج', 'الكمية', 'التكلفة', 'الإجمالي'],
            data: shipment.items.map((item) {
              return [
                item.name,
                item.quantity.toString(),
                '${item.cost.toStringAsFixed(2)} ${AppStrings.currency}',
                '${(item.cost * item.quantity).toStringAsFixed(2)} ${AppStrings.currency}',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              font: boldFont,
              color: PdfColors.white,
              fontSize: 11,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue600),
            cellStyle: pw.TextStyle(font: font, fontSize: 10),
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

          // Items Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(8),
                bottomRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'المجموع الإجمالي:',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 12,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.Text(
                  '${shipment.totalAmount.toStringAsFixed(2)} ${AppStrings.currency}',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 12,
                    color: PdfColors.grey800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPaymentSummary(pw.Font font, pw.Font boldFont) {
    final remainingAmount = shipment.totalAmount - shipment.paidAmount;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.green300, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Section Title
          pw.Text(
            'ملخص الدفع',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 18,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 15),

          // Payment breakdown
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green100,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.green400, width: 1),
            ),
            child: pw.Column(
              children: [
                // Total amount
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'المبلغ الإجمالي:',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 16,
                        color: PdfColors.green800,
                      ),
                    ),
                    pw.Text(
                      '${shipment.totalAmount.toStringAsFixed(2)} ${AppStrings.currency}',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 16,
                        color: PdfColors.green800,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 8),

                // Paid amount
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'المبلغ المدفوع:',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 14,
                        color: PdfColors.green700,
                      ),
                    ),
                    pw.Text(
                      '${shipment.paidAmount.toStringAsFixed(2)} ${AppStrings.currency}',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 14,
                        color: PdfColors.green700,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 8),

                // Remaining amount
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'المبلغ المتبقي:',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 14,
                        color: remainingAmount > 0
                            ? PdfColors.red700
                            : PdfColors.green700,
                      ),
                    ),
                    pw.Text(
                      '${remainingAmount.toStringAsFixed(2)} ${AppStrings.currency}',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 14,
                        color: remainingAmount > 0
                            ? PdfColors.red700
                            : PdfColors.green700,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 8),

                // Payment status
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: remainingAmount > 0
                        ? PdfColors.red50
                        : PdfColors.green50,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(
                      color: remainingAmount > 0
                          ? PdfColors.red300
                          : PdfColors.green300,
                      width: 1,
                    ),
                  ),
                  child: pw.Text(
                    remainingAmount > 0 ? 'دفع جزئي' : 'مدفوع بالكامل',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 12,
                      color: remainingAmount > 0
                          ? PdfColors.red700
                          : PdfColors.green700,
                    ),
                  ),
                ),
              ],
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
            'ملاحظات',
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
