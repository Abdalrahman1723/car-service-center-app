import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/manager/features/manage_clients/presentation/widgets/client_card.dart';

import '../cubit/client_management_cubit.dart';
import '../widgets/update_dialog.dart';

// Screen to display all clients in a card-based layout with update and delete options
class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger loadClients on screen initialization
    context.read<ClientManagementCubit>().loadClients();

    return Scaffold(
      appBar: AppBar(title: const Text('All Clients')),
      body: BlocConsumer<ClientManagementCubit, ClientManagementState>(
        listener: (context, state) {
          // Handle success and error states with snackbar notifications
          if (state is ClientManagementSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // Reload clients after update or delete
            context.read<ClientManagementCubit>().loadClients();
          } else if (state is ClientManagementError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          // Display loading indicator while fetching clients
          if (state is ClientManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Display client list when loaded
          else if (state is ClientManagementClientsLoaded) {
            if (state.clients.isEmpty) {
              return const Center(child: Text('No clients found'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.clients.length,
              itemBuilder: (context, index) {
                final client = state.clients[index];
                // Use ClientCard widget with correct context for actions
                return ClientCard(
                  client: client,
                  onUpdate: () => ClientUpdateDialog.show(context, client),
                  onDelete: () {
                    // Use context from ListView.builder for dialog
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Delete Client'),
                        content: Text(
                          'Are you sure you want to delete ${client.name}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Use context from ListView.builder for cubit access
                              context
                                  .read<ClientManagementCubit>()
                                  .deleteClient(client.id);
                              Navigator.pop(dialogContext);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }
          // Display initial state with loading prompt
          return const Center(child: Text('Loading clients...'));
        },
      ),
    );
  }
}
