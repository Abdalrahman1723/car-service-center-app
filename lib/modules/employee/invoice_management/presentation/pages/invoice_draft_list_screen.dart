import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m_world/config/routes.dart';
import '../cubit/invoice_management_cubit.dart';

class InvoiceDraftListScreen extends StatelessWidget {
  const InvoiceDraftListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة المسودات')),
      body: BlocBuilder<InvoiceManagementCubit, InvoiceManagementState>(
        builder: (context, state) {
          if (state is InvoiceManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InvoiceManagementDraftsLoaded) {
            final drafts = state.drafts;
            if (drafts.isEmpty) {
              return const Center(child: Text('لا توجد مسودات'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: drafts.length,
              itemBuilder: (context, index) {
                final draft = drafts[index];
                return ListTile(
                  title: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('clients')
                        .doc(draft['clientId'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('...جاري التحميل');
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          !snapshot.data!.exists) {
                        return const Text('عميل غير معروف');
                      }
                      final clientData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return Text(clientData['name'] ?? 'عميل غير معروف');
                    },
                  ),
                  subtitle: Text(
                    'تاريخ: ${draft['issueDate'] != null ? DateFormat.yMMMd().format(DateTime.parse(draft['issueDate'])) : 'غير محدد'}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('invoice_drafts')
                          .doc(draft['id'])
                          .delete();
                      context.read<InvoiceManagementCubit>().loadDrafts();
                    },
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      Routes.invoiceAdd,
                      arguments: {'draftData': draft},
                    );
                  },
                );
              },
            );
          } else if (state is InvoiceManagementError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('اضغط لتحميل المسودات'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<InvoiceManagementCubit>().loadDrafts(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
