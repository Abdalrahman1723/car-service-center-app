import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../modules/employee/invoice_management/data/datasources/invoice_datasource.dart';
import '../../../../../modules/employee/invoice_management/data/repositories/invoice_repository_impl.dart';
import '../../../../../modules/employee/invoice_management/domain/usecases/add_invoice.dart';
import '../../../../../modules/employee/invoice_management/domain/usecases/get_all_invoices.dart';
import '../../../../../modules/employee/invoice_management/presentation/cubit/invoice_management_cubit.dart';
import '../../../../../modules/employee/invoice_management/presentation/pages/invoice_add_screen.dart';
import '../../../../../modules/manager/features/manage_clients/data/datasources/client_datasource.dart';
import '../../../../../modules/manager/features/manage_clients/data/repositories/client_repository_impl.dart';
import '../../../../../modules/manager/features/manage_clients/domain/usecases/get_all_clients.dart';
import '../../../../../modules/manager/features/inventory/inventory_module.dart';

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
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => InvoiceManagementCubit(
                              addInvoiceUseCase: AddInvoice(
                                InvoiceRepositoryImpl(
                                  FirebaseInvoiceDataSource(),
                                  FirebaseClientDataSource(),
                                ),
                              ),
                              getAllInvoicesUseCase: GetAllInvoices(
                                InvoiceRepositoryImpl(
                                  FirebaseInvoiceDataSource(),
                                  FirebaseClientDataSource(),
                                ),
                              ),
                              getAllClientsUseCase: GetAllClients(
                                ClientRepositoryImpl(
                                  FirebaseClientDataSource(),
                                ),
                              ),
                              inventoryRepository:
                                  InventoryModule.provideInventoryRepository(),
                            ),
                            child: InvoiceAddScreen(draftData: draft),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
