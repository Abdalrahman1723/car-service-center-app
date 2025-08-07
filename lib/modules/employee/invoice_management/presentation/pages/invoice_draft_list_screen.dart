import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../config/routes.dart';


// Screen to display all drafted invoices
class InvoiceDraftListScreen extends StatefulWidget {
  const InvoiceDraftListScreen({super.key});

  @override
  InvoiceDraftListScreenState createState() => InvoiceDraftListScreenState();
}

class InvoiceDraftListScreenState extends State<InvoiceDraftListScreen> {
  List<Map<String, dynamic>> _drafts = [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = prefs.getStringList('invoice_drafts') ?? [];
    setState(() {
      _drafts = drafts
          .map((draft) => jsonDecode(draft) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _deleteDraft(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = prefs.getStringList('invoice_drafts') ?? [];
    drafts.removeWhere(
      (draft) => (jsonDecode(draft) as Map<String, dynamic>)['id'] == id,
    );
    await prefs.setStringList('invoice_drafts', drafts);
    await _loadDrafts();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Draft deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draft Invoices')),
      body: _drafts.isEmpty
          ? const Center(child: Text('No drafts found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _drafts.length,
              itemBuilder: (context, index) {
                final draft = _drafts[index];
                return Card(
                  color: Theme.of(context).cardColor,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('Draft #${draft['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Client: ${draft['clientName'] ?? 'Not selected'}',
                        ),
                        Text(
                          'Amount: \$${draft['amount']?.toStringAsFixed(2) ?? '0.00'}',
                        ),
                        Text(
                          'Created: ${DateFormat.yMMMd().format(DateTime.parse(draft['createdAt']))}',
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteDraft(draft['id']),
                    ),
                    onTap: () {
                      log("the draft : $draft");
                      Navigator.of(context).pushReplacementNamed(
                        Routes.invoiceAdd,
                        arguments: draft,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
