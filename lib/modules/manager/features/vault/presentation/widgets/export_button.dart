import 'dart:io';
import 'dart:ui' as ui;
import 'package:excel/excel.dart'; // Add excel package
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart'; // Add pdf package
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Add printing for PDF preview/share
import '../../domain/entities/vault_transaction.dart';
import '../../domain/usecases/export_transaction.dart';

class ExportButton extends StatelessWidget {
  final List<VaultTransaction> transactions;

  const ExportButton({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () => _exportToExcel(),
          child: const Text('Export Excel'),
        ),
        ElevatedButton(
          onPressed: () => _exportToPdf(context),
          child: const Text('Export PDF'),
        ),
      ],
    );
  }

  Future<void> _exportToExcel() async {
    final exportUseCase = ExportVaultTransactions();
    final data = await exportUseCase.execute(transactions);
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    // Add headers
    sheet.appendRow(['ID', 'Type', 'Category', 'Amount', 'Date', 'Notes', 'Source ID', 'Running Balance']);
    for (var tx in transactions) {
      sheet.appendRow([
        tx.id,
        tx.type,
        tx.category,
        tx.amount,
        tx.date.toString(),
        tx.notes,
        tx.sourceId,
        tx.runningBalance,
      ]);
    }
    sheet.appendRow(['Total Income', data['totalIncome']]);
    sheet.appendRow(['Total Expenses', data['totalExpenses']]);
    sheet.appendRow(['Net Balance', data['netBalance']]);

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/vault_export.xlsx';
    await File(path).writeAsBytes(excel.encode()!);
    // Share or open file
  }

  Future<void> _exportToPdf(BuildContext context) async {
    final exportUseCase = ExportVaultTransactions();
    final data = await exportUseCase.execute(transactions);
    final pdf = pw.Document();

    // Simple chart: PieChart for income vs expenses
    // To include chart in PDF, render FlChart to image
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset.zero, const Offset(300, 300)));
    final paint = Paint();
    // Draw simple pie: green for income, red for expense
    canvas.drawArc(Rect.fromCircle(center: const Offset(150, 150), radius: 100), 0, 2 * 3.1416 * (data['totalIncome'] / (data['totalIncome'] + data['totalExpenses'])), true, paint..color = Colors.green);
    canvas.drawArc(Rect.fromCircle(center: const Offset(150, 150), radius: 100), 2 * 3.1416 * (data['totalIncome'] / (data['totalIncome'] + data['totalExpenses'])), 2 * 3.1416, true, paint..color = Colors.red);
    final picture = recorder.endRecording();
    final img = await picture.toImage(300, 300);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        build: (ctx) => pw.Column(
          children: [
            pw.Image(pw.MemoryImage(pngBytes)),
            pw.Table.fromTextArray(data: [
              ['ID', 'Type', 'Category', 'Amount', 'Date', 'Notes', 'Source ID', 'Running Balance'],
              ...transactions.map((tx) => [
                    tx.id,
                    tx.type,
                    tx.category,
                    tx.amount.toString(),
                    tx.date.toString(),
                    tx.notes ?? '',
                    tx.sourceId ?? '',
                    tx.runningBalance.toString(),
                  ]),
              ['Total Income', data['totalIncome'].toString()],
              ['Total Expenses', data['totalExpenses'].toString()],
              ['Net Balance', data['netBalance'].toString()],
            ]),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }
}