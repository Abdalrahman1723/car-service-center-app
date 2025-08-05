import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../shared/models/client.dart';
import '../cubit/client_management_cubit.dart';

/// Page for adding or updating a client
///
/// This screen provides a form interface for creating new clients or editing existing ones.
/// When [client] is null, the screen operates in "add" mode.
/// When [client] is provided, the screen operates in "edit" mode.
class ClientManagementScreen extends StatelessWidget {
  /// The client to edit. Null for adding a new client, non-null for editing existing client
  final Client? client;

  const ClientManagementScreen({super.key, this.client});

  @override
  Widget build(BuildContext context) {
    // Initialize text controllers with existing client data if editing
    // This pre-fills the form fields when editing an existing client
    final nameController = TextEditingController(text: client?.name ?? '');
    final phoneController = TextEditingController(
      text: client?.phoneNumber ?? '',
    );
    final carTypeController = TextEditingController(
      text: client?.carType ?? '',
    );
    final modelController = TextEditingController(text: client?.model ?? '');
    final balanceController = TextEditingController(
      text: client?.balance.toString() ?? '0.0',
    );
    final emailController = TextEditingController(text: client?.email ?? '');
    final licensePlateController = TextEditingController(
      text: client?.licensePlate ?? '',
    );
    final notesController = TextEditingController(text: client?.notes ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(client == null ? 'Add New Client' : 'Edit Client'),
        actions: [
          // Show delete button only when editing an existing client
          if (client != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context.read<ClientManagementCubit>().deleteClient(client!.id);
              },
            ),
        ],
      ),
      body: BlocConsumer<ClientManagementCubit, ClientManagementState>(
        listener: (context, state) {
          // Handle success and error states with snackbar notifications
          if (state is ClientManagementSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is ClientManagementError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Client Information Form Fields
                _buildFormFields(
                  nameController: nameController,
                  phoneController: phoneController,
                  carTypeController: carTypeController,
                  modelController: modelController,
                  balanceController: balanceController,
                  emailController: emailController,
                  licensePlateController: licensePlateController,
                  notesController: notesController,
                ),

                const SizedBox(height: 24),

                // Submit Button
                _buildSubmitButton(
                  context: context,
                  state: state,
                  nameController: nameController,
                  phoneController: phoneController,
                  carTypeController: carTypeController,
                  modelController: modelController,
                  balanceController: balanceController,
                  emailController: emailController,
                  licensePlateController: licensePlateController,
                  notesController: notesController,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the form fields for client information
  Widget _buildFormFields({
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController carTypeController,
    required TextEditingController modelController,
    required TextEditingController balanceController,
    required TextEditingController emailController,
    required TextEditingController licensePlateController,
    required TextEditingController notesController,
  }) {
    return Column(
      children: [
        // Required field - Client Name
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name *',
            hintText: 'Enter client full name',
          ),
        ),

        const SizedBox(height: 16),

        // Optional field - Phone Number
        TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter contact number',
          ),
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 16),

        // Required field - Car Type
        TextField(
          controller: carTypeController,
          decoration: const InputDecoration(
            labelText: 'Car Type *',
            hintText: 'e.g., Sedan, SUV, Truck',
          ),
        ),

        const SizedBox(height: 16),

        // Optional field - Car Model
        TextField(
          controller: modelController,
          decoration: const InputDecoration(
            labelText: 'Model',
            hintText: 'e.g., Toyota Camry 2020',
          ),
        ),

        const SizedBox(height: 16),

        // Required field - Balance
        TextField(
          controller: balanceController,
          decoration: const InputDecoration(
            labelText: 'Balance *',
            hintText: 'Enter current balance',
          ),
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 16),

        // Optional field - Email
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter email address',
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 16),

        // Optional field - License Plate
        TextField(
          controller: licensePlateController,
          decoration: const InputDecoration(
            labelText: 'License Plate',
            hintText: 'Enter vehicle license plate',
          ),
        ),

        const SizedBox(height: 16),

        // Optional field - Notes
        TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Additional notes about the client',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  /// Builds the submit button with validation and form submission logic
  Widget _buildSubmitButton({
    required BuildContext context,
    required ClientManagementState state,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController carTypeController,
    required TextEditingController modelController,
    required TextEditingController balanceController,
    required TextEditingController emailController,
    required TextEditingController licensePlateController,
    required TextEditingController notesController,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state is ClientManagementLoading
            ? null
            : () => _handleFormSubmission(
                context: context,
                nameController: nameController,
                phoneController: phoneController,
                carTypeController: carTypeController,
                modelController: modelController,
                balanceController: balanceController,
                emailController: emailController,
                licensePlateController: licensePlateController,
                notesController: notesController,
              ),
        child: state is ClientManagementLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(client == null ? 'Add Client' : 'Update Client'),
      ),
    );
  }

  /// Handles form submission with validation
  void _handleFormSubmission({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController carTypeController,
    required TextEditingController modelController,
    required TextEditingController balanceController,
    required TextEditingController emailController,
    required TextEditingController licensePlateController,
    required TextEditingController notesController,
  }) {
    // Validate required fields
    if (nameController.text.isEmpty ||
        carTypeController.text.isEmpty ||
        balanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Parse balance with fallback to 0.0
    final balance = double.tryParse(balanceController.text) ?? 0.0;

    if (client == null) {
      // Add new client
      context.read<ClientManagementCubit>().addClient(
        name: nameController.text,
        phoneNumber: phoneController.text.isEmpty ? null : phoneController.text,
        carType: carTypeController.text,
        model: modelController.text.isEmpty ? null : modelController.text,
        balance: balance,
        email: emailController.text.isEmpty ? null : emailController.text,
        licensePlate: licensePlateController.text.isEmpty
            ? null
            : licensePlateController.text,
        notes: notesController.text.isEmpty ? null : notesController.text,
      );
    } else {
      // Update existing client
      context.read<ClientManagementCubit>().updateClient(
        Client(
          id: client!.id,
          name: nameController.text,
          phoneNumber: phoneController.text.isEmpty
              ? null
              : phoneController.text,
          carType: carTypeController.text,
          model: modelController.text.isEmpty ? null : modelController.text,
          balance: balance,
          email: emailController.text.isEmpty ? null : emailController.text,
          licensePlate: licensePlateController.text.isEmpty
              ? null
              : licensePlateController.text,
          notes: notesController.text.isEmpty ? null : notesController.text,
          history: client!.history, // Preserve existing history
        ),
      );
    }
  }
}
