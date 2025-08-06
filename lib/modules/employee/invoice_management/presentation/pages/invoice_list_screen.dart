import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../shared/models/invoice.dart';
import '../cubit/invoice_management_cubit.dart';
import '../widgets/invoice_card.dart';
import '../widgets/invoice_client_dialog.dart';

// Screen to display all invoices with search and filter
class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  InvoiceListScreenState createState() => InvoiceListScreenState();
}

class InvoiceListScreenState extends State<InvoiceListScreen> {
  final _searchController = TextEditingController();
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    context.read<InvoiceManagementCubit>().loadInvoices();
    context.read<InvoiceManagementCubit>().loadClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Invoices')),
      body: BlocConsumer<InvoiceManagementCubit, InvoiceManagementState>(
        listener: (context, state) {
          if (state is InvoiceManagementError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search and filter bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search Invoices',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        setState(() => _filterDate = date);
                      },
                    ),
                  ],
                ),
              ),
              // Invoice list
              Expanded(
                child: state is InvoiceManagementLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state is InvoiceManagementInvoicesLoaded
                    ? _buildInvoiceList(state.invoices)
                    : const Center(child: Text('No invoices found')),
              ),
            ],
          );
        },
      ),
    );
  }

  // Build filtered invoice list
  Widget _buildInvoiceList(List<Invoice> invoices) {
    var filteredInvoices = invoices.where((invoice) {
      final matchesSearch =
          invoice.clientId.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          invoice.maintenanceBy.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      final matchesDate =
          _filterDate == null ||
          invoice.issueDate.year == _filterDate!.year &&
              invoice.issueDate.month == _filterDate!.month &&
              invoice.issueDate.day == _filterDate!.day;
      return matchesSearch && matchesDate;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredInvoices.length,
      itemBuilder: (context, index) {
        final invoice = filteredInvoices[index];
        return InvoiceCard(
          invoice: invoice,
          onTap: () => InvoiceClientDialog.show(context, invoice.clientId),
        );
      },
    );
  }
}
