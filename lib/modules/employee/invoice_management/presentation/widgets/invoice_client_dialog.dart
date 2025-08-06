import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../shared/models/client.dart';
import '../cubit/invoice_management_cubit.dart';

// Widget to display client details for an invoice
class InvoiceClientDialog {
  static void show(BuildContext context, String clientId) {
    showDialog(
      context: context,
      builder: (dialogContext) =>
          BlocBuilder<InvoiceManagementCubit, InvoiceManagementState>(
            builder: (context, state) {
              Client? client;
              if (state is InvoiceManagementClientsLoaded) {
                client = state.clients.firstWhere(
                  (c) => c.phoneNumber == clientId,
                  orElse: () => Client(
                    id: '',
                    name: 'Unknown',
                    carType: '',
                    balance: 0.0,
                  ),
                );
              }
              return AlertDialog(
                title: const Text('Client Details'),
                content: client != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${client.name}'),
                          if (client.phoneNumber != null)
                            Text('Phone: ${client.phoneNumber}'),
                          Text('Car: ${client.carType} ${client.model ?? ''}'),
                          Text(
                            'Balance: \$${client.balance.toStringAsFixed(2)}',
                          ),
                          if (client.email != null)
                            Text('Email: ${client.email}'),
                          if (client.licensePlate != null)
                            Text('License Plate: ${client.licensePlate}'),
                          if (client.notes != null)
                            Text('Notes: ${client.notes}'),
                        ],
                      )
                    : const Text('Client not found'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          ),
    );
  }
}
