import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart'; // Added for FilteringTextInputFormatter

import '../cubit/client_management_cubit.dart';

// Page for adding a new client
class ClientManagementScreen extends StatelessWidget {
  const ClientManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize text controllers for form input
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final carTypeController = TextEditingController();
    final modelController = TextEditingController();
    final balanceController = TextEditingController(text: '0.0');
    final emailController = TextEditingController();
    final licensePlateNumberController =
        TextEditingController(); // Only numbers
    final licensePlateLetterController =
        TextEditingController(); // Only letters
    final notesController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Client')),
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
                  licensePlateNumberController: licensePlateNumberController,
                  licensePlateLetterController: licensePlateLetterController,
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
                  licensePlateNumberController: licensePlateNumberController,
                  licensePlateLetterController: licensePlateLetterController,
                  notesController: notesController,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Builds the form fields for client information
  Widget _buildFormFields({
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController carTypeController,
    required TextEditingController modelController,
    required TextEditingController balanceController,
    required TextEditingController emailController,
    required TextEditingController licensePlateNumberController, // Only numbers
    required TextEditingController licensePlateLetterController, // Only letters
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
          maxLength: 15,
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
        // License Plate - Two adjacent fields
        Row(
          children: [
            // Numbers (left)
            Expanded(
              child: TextField(
                maxLength: 7,
                controller: licensePlateNumberController,
                decoration: const InputDecoration(
                  labelText: 'Plate Numbers',
                  hintText: '1 2 3 4',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^[0-9 ]*'),
                  ), // Only numbers and spaces
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Letters (right)
            Expanded(
              child: TextField(
                maxLength: 5,
                controller: licensePlateLetterController,
                decoration: const InputDecoration(
                  labelText: 'Plate Letters',
                  hintText: 'A B C',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^[a-zA-Z\u0600-\u06FF ]*'),
                  ), // Only letters and spaces
                ],
              ),
            ),
          ],
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

  // Builds the submit button with validation and form submission logic
  Widget _buildSubmitButton({
    required BuildContext context,
    required ClientManagementState state,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController carTypeController,
    required TextEditingController modelController,
    required TextEditingController balanceController,
    required TextEditingController emailController,
    required TextEditingController licensePlateNumberController, // Only numbers
    required TextEditingController licensePlateLetterController, // Only letters
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
                licensePlateNumberController: licensePlateNumberController,
                licensePlateLetterController: licensePlateLetterController,
                notesController: notesController,
              ),
        child: state is ClientManagementLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Add Client'),
      ),
    );
  }

  // Handles form submission with validation
  void _handleFormSubmission({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController carTypeController,
    required TextEditingController modelController,
    required TextEditingController balanceController,
    required TextEditingController emailController,
    required TextEditingController licensePlateNumberController, // Only numbers
    required TextEditingController licensePlateLetterController, // Only letters
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

    // Combine license plate fields
    String licensePlate = '';
    if (licensePlateNumberController.text.trim().isNotEmpty ||
        licensePlateLetterController.text.trim().isNotEmpty) {
      licensePlate =
          '${licensePlateNumberController.text.trim()} / ${licensePlateLetterController.text.trim()}';
    }

    // Add new client
    context.read<ClientManagementCubit>().addClient(
      name: nameController.text,
      phoneNumber: phoneController.text.isEmpty ? null : phoneController.text,
      carType: carTypeController.text,
      model: modelController.text.isEmpty ? null : modelController.text,
      balance: balance,
      email: emailController.text.isEmpty ? null : emailController.text,
      licensePlate: licensePlate.isEmpty ? null : licensePlate,
      notes: notesController.text.isEmpty ? null : notesController.text,
    );
  }
}
