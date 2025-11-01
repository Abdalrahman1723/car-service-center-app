import 'dart:developer';

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
      log('Logo loaded successfully');
    } catch (e) {
      log('Error loading logo: $e');
      // Continue without logo if loading fails
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        header: (pw.Context context) {
          if (context.pageNumber == 1) {
            return pw.SizedBox.shrink();
          }
          return _buildPageHeader(
            logoImage,
            boldFont,
            font,
            context.pageNumber,
          );
        },
        footer: (pw.Context context) {
          return _buildPageFooter(font, context.pageNumber, context.pagesCount);
        },
        build: (pw.Context ctx) {
          // Return all widgets - MultiPage will handle pagination
          // First-page-only content is added first, so it will naturally appear on page 1
          // Last-page-only content will be placed by the system on the last page
          return [
            // Header with logo and service center info (first page only - added first)
            _buildHeader(logoImage, boldFont, font),
            pw.SizedBox(height: 20),

            // Invoice title and number (first page only)
            _buildInvoiceTitle(boldFont, ctx),
            pw.SizedBox(height: 20),

            // Two column layout for client and invoice details (first page only)
            _buildClientAndInvoiceDetailsRow(font, boldFont, ctx),
            pw.SizedBox(height: 20),

            // Items table (can span multiple pages - auto-paginated)
            _buildItemsTable(font, boldFont, ctx),

            // Detailed breakdown section (will appear after table)
            // Note: These sections will naturally appear on the last page after the table
            pw.SizedBox(height: 20),
            _buildDetailedBreakdown(font, boldFont, ctx),

            // Summary section
            pw.SizedBox(height: 20),
            _buildSummarySection(font, boldFont, ctx),

            // Notes section
            if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildNotesSection(invoice.notes!, font, boldFont, ctx),
            ],
          ];
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
      padding: const pw.EdgeInsets.all(12),
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
              fontSize: 18,
              color: PdfColors.blue800,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 12),

          // Logo and contact info in a row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo (with fallback if image fails to load)
              if (logoImage != null)
                pw.Image(
                  logoImage,
                  width: 70,
                  height: 70,
                  fit: pw.BoxFit.contain,
                )
              else
                pw.Container(
                  width: 70,
                  height: 70,
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
                        fontSize: 12,
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
                      style: pw.TextStyle(font: font, fontSize: 12),
                      textAlign: pw.TextAlign.right,
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'العنوان:',
                      style: pw.TextStyle(font: boldFont, fontSize: 11),
                      textAlign: pw.TextAlign.right,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'العبور المنطقة الصناعية الدولى',
                      style: pw.TextStyle(font: font, fontSize: 10),
                      textAlign: pw.TextAlign.right,
                    ),
                    pw.Text(
                      'قطعه 13021 شارع 50 بجوار شركة امون للادوية',
                      style: pw.TextStyle(font: font, fontSize: 10),
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

  pw.Widget _buildPageHeader(
    pw.MemoryImage? logoImage,
    pw.Font boldFont,
    pw.Font font,
    int pageNumber,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'صفحة $pageNumber',
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'مركز خدمة M World - Job order رقم: ${invoice.id}',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 11,
              color: PdfColors.blue800,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPageFooter(pw.Font font, int pageNumber, int totalPages) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'صفحة $pageNumber من $totalPages',
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInvoiceTitle(pw.Font boldFont, pw.Context ctx) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200, width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Flexible(
            child: pw.Text(
              'Job order',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 16,
                color: PdfColors.blue800,
              ),
            ),
          ),
          pw.Flexible(
            child: pw.Text(
              'رقم: ${invoice.id}',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 14,
                color: PdfColors.blue700,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildClientAndInvoiceDetailsRow(
    pw.Font font,
    pw.Font boldFont,
    pw.Context ctx,
  ) {
    // On smaller pages, stack vertically, otherwise use row
    // A4 width (595) minus margins (40) = ~555 points
    final availableWidth = PdfPageFormat.a4.width - 40;
    final useRow = availableWidth > 400;

    if (useRow) {
      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _buildClientSection(font, boldFont)),
          pw.SizedBox(width: 15),
          pw.Expanded(child: _buildInvoiceDetailsSection(font, boldFont)),
        ],
      );
    } else {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildClientSection(font, boldFont),
          pw.SizedBox(height: 15),
          _buildInvoiceDetailsSection(font, boldFont),
        ],
      );
    }
  }

  pw.Widget _buildClientSection(pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
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
              fontSize: 12,
              color: PdfColors.grey800,
            ),
          ),
          pw.Divider(color: PdfColors.grey400, height: 15),
          _buildDetailRow('الاسم', clientName, font),
          _buildDetailRow('رقم العميل', invoice.clientId, font),
          _buildDetailRow('السيارة', invoice.selectedCar, font),
        ],
      ),
    );
  }

  pw.Widget _buildInvoiceDetailsSection(pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'تفاصيل العملية',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              color: PdfColors.grey800,
            ),
          ),
          pw.Divider(color: PdfColors.grey400, height: 15),
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

  pw.Widget _buildItemsTable(pw.Font font, pw.Font boldFont, pw.Context ctx) {
    // A4 width (595) minus margins (40) = ~555 points
    final availableWidth = PdfPageFormat.a4.width - 40;

    // Note: We can't safely check pageNumber during build
    // The table header will default to the first page style
    final currentPage = 1; // Default, will be correct when rendered

    // Prepare table data - service fees should be in the table data but will only show on the page where it fits
    final tableData = [
      ...invoice.items.map((item) {
        return [
          item.name,
          item.quantity.toString(),
          '${item.price!.toStringAsFixed(2)} ${AppStrings.currency}',
          '${(item.price! * item.quantity).toStringAsFixed(2)} ${AppStrings.currency}',
        ];
      }).toList(),
      // Add service fees as a separate row if they exist
      if (invoice.serviceFees > 0) ...[
        [
          'مصنعية',
          '1',
          '${invoice.serviceFees.toStringAsFixed(2)} ${AppStrings.currency}',
          '${invoice.serviceFees.toStringAsFixed(2)} ${AppStrings.currency}',
        ],
      ],
    ];

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Table Header
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: currentPage == 1 ? PdfColors.blue700 : PdfColors.blue600,
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Text(
              currentPage == 1 ? 'تفاصيل العناصر' : 'تفاصيل العناصر (متابعة)',
              style: pw.TextStyle(
                font: boldFont,
                color: PdfColors.white,
                fontSize: currentPage == 1 ? 12 : 11,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),

          // Items Table
          pw.Table.fromTextArray(
            headers: ['اسم العنصر', 'الكمية', 'سعر الوحدة', 'الإجمالي'],
            data: tableData,
            headerStyle: pw.TextStyle(
              font: boldFont,
              color: PdfColors.white,
              fontSize: 10,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue600),
            cellStyle: pw.TextStyle(font: font, fontSize: 9),
            cellAlignments: {
              0: pw.Alignment.centerRight,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
            },
            columnWidths: {
              0: pw.FlexColumnWidth(availableWidth > 400 ? 3 : 2.5),
              1: pw.FlexColumnWidth(1),
              2: pw.FlexColumnWidth(availableWidth > 400 ? 1.5 : 1.3),
              3: pw.FlexColumnWidth(availableWidth > 400 ? 1.5 : 1.3),
            },
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          ),

          // Items Summary (appears after table)
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(8),
                bottomRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Column(
              children: [
                // Items subtotal
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Flexible(
                      child: pw.Text(
                        'مجموع العناصر:',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ),
                    pw.Text(
                      '${invoice.items.fold<double>(0, (sum, item) => sum + (item.price! * item.quantity)).toStringAsFixed(2)} ${AppStrings.currency}',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                // Service fees if applicable
                if (invoice.serviceFees > 0) ...[
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Flexible(
                        child: pw.Text(
                          'مصنعية:',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ),
                      pw.Text(
                        '${invoice.serviceFees.toStringAsFixed(2)} ${AppStrings.currency}',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
                // Total including service fees
                pw.SizedBox(height: 4),
                pw.Divider(color: PdfColors.grey400, height: 1),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Flexible(
                      child: pw.Text(
                        'إجمالي العناصر والرسوم:',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 11,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ),
                    pw.Text(
                      '${(invoice.items.fold<double>(0, (sum, item) => sum + (item.price! * item.quantity)) + invoice.serviceFees).toStringAsFixed(2)} ${AppStrings.currency}',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 11,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDetailedBreakdown(
    pw.Font font,
    pw.Font boldFont,
    pw.Context ctx,
  ) {
    final subtotal = invoice.items.fold<double>(
      0,
      (sum, item) => sum + (item.price! * item.quantity),
    );
    final discount = invoice.discount ?? 0.0;
    final serviceFees = invoice.serviceFees;
    final total = subtotal - discount + serviceFees;

    // A4 width (595) minus margins (40) = ~555 points
    final availableWidth = PdfPageFormat.a4.width - 40;
    final baseFontSize = availableWidth > 400 ? 14.0 : 12.0;

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
          // Section Title
          pw.Text(
            'تفصيل الحساب',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: baseFontSize + 2,
              color: PdfColors.orange800,
            ),
          ),
          pw.SizedBox(height: 12),

          // Step by step breakdown
          _buildBreakdownRow('1. مجموع العناصر', subtotal, font),

          if (discount > 0) ...[
            _buildBreakdownRow('2. الخصم', -discount, font, isNegative: true),
            _buildBreakdownRow(
              '3. المجموع بعد الخصم',
              subtotal - discount,
              font,
            ),
          ],

          if (serviceFees > 0) ...[
            _buildBreakdownRow(
              discount > 0 ? '4. رسوم الخدمة' : '2. رسوم الخدمة',
              serviceFees,
              font,
            ),
          ],

          pw.Divider(color: PdfColors.orange300, height: 20),

          // Final calculation
          _buildBreakdownRow(
            'المبلغ الإجمالي النهائي',
            total,
            font,
            isTotal: true,
            boldFont: boldFont,
          ),

          // Show payment breakdown if applicable
          if (invoice.isPayLater &&
              invoice.downPayment != null &&
              invoice.downPayment! > 0) ...[
            pw.SizedBox(height: 15),
            pw.Text(
              'تفاصيل الدفع',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 14,
                color: PdfColors.orange700,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildBreakdownRow('الدفعة المقدمة', invoice.downPayment!, font),
            _buildBreakdownRow(
              'المبلغ المتبقي للدفع',
              total - invoice.downPayment!,
              font,
              isTotal: true,
              boldFont: boldFont,
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildBreakdownRow(
    String label,
    double amount,
    pw.Font font, {
    bool isTotal = false,
    bool isNegative = false,
    pw.Font? boldFont,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: isTotal ? boldFont : font,
              fontSize: isTotal ? 13 : 11,
              color: isTotal ? PdfColors.orange800 : PdfColors.black,
            ),
          ),
          pw.Text(
            '${isNegative ? '-' : ''}${amount.abs().toStringAsFixed(2)} ${AppStrings.currency}',
            style: pw.TextStyle(
              font: isTotal ? boldFont : font,
              fontSize: isTotal ? 13 : 11,
              color: isNegative
                  ? PdfColors.red700
                  : (isTotal ? PdfColors.orange800 : PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummarySection(
    pw.Font font,
    pw.Font boldFont,
    pw.Context ctx,
  ) {
    final subtotal = invoice.items.fold<double>(
      0,
      (sum, item) => sum + (item.price! * item.quantity),
    );
    final discount = invoice.discount ?? 0.0;
    final serviceFees = invoice.serviceFees;
    final total = subtotal - discount + serviceFees;

    // A4 width (595) minus margins (40) = ~555 points
    final availableWidth = PdfPageFormat.a4.width - 40;
    final baseFontSize = availableWidth > 400 ? 14.0 : 12.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
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
            'الملخص النهائي',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: baseFontSize + 4,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 12),

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
                      'المبلغ الإجمالي المطلوب:',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 16,
                        color: PdfColors.green800,
                      ),
                    ),
                    pw.Text(
                      '${total.toStringAsFixed(2)} ${AppStrings.currency}',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 18,
                        color: PdfColors.green800,
                      ),
                    ),
                  ],
                ),

                // Payment status and amount
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: invoice.isPayLater
                        ? PdfColors.red50
                        : PdfColors.green50,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(
                      color: invoice.isPayLater
                          ? PdfColors.red300
                          : PdfColors.green300,
                      width: 1,
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        invoice.isPayLater
                            ? 'حالة الدفع: آجل'
                            : 'حالة الدفع: مدفوع بالكامل',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 12,
                          color: invoice.isPayLater
                              ? PdfColors.red700
                              : PdfColors.green700,
                        ),
                      ),
                      if (!invoice.isPayLater)
                        pw.Text(
                          'تم الدفع: ${total.toStringAsFixed(2)} ${AppStrings.currency}',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 12,
                            color: PdfColors.green700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Show payment method if available
          if (invoice.paymentMethod != null) ...[
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: PdfColors.blue300, width: 1),
              ),
              child: pw.Text(
                'طريقة الدفع: ${_getPaymentMethodText(invoice.paymentMethod!)}',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: PdfColors.blue700,
                ),
              ),
            ),
          ],

          // Show down payment if applicable
          if (invoice.isPayLater &&
              invoice.downPayment != null &&
              invoice.downPayment! > 0) ...[
            pw.SizedBox(height: 10),
            _buildSummaryRow('الدفعة المقدمة', invoice.downPayment!, font),
            _buildSummaryRow(
              'المبلغ المتبقي للدفع',
              total - invoice.downPayment!,
              font,
              isTotal: true,
              boldFont: boldFont,
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildSummaryRow(
    String label,
    double amount,
    pw.Font font, {
    bool isTotal = false,
    bool isNegative = false,
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
            '${isNegative ? '-' : ''}${amount.abs().toStringAsFixed(2)} ${AppStrings.currency}',
            style: pw.TextStyle(
              font: isTotal ? boldFont : font,
              fontSize: isTotal ? 14 : 12,
              color: isNegative
                  ? PdfColors.red700
                  : (isTotal ? PdfColors.blue800 : PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildNotesSection(
    String notes,
    pw.Font font,
    pw.Font boldFont,
    pw.Context ctx,
  ) {
    // A4 width (595) minus margins (40) = ~555 points
    final availableWidth = PdfPageFormat.a4.width - 40;
    final baseFontSize = availableWidth > 400 ? 12.0 : 10.0;

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
              fontSize: baseFontSize + 2,
              color: PdfColors.orange800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            notes,
            style: pw.TextStyle(font: font, fontSize: baseFontSize),
            textAlign: pw.TextAlign.right,
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
