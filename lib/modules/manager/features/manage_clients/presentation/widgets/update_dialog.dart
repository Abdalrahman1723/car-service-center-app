import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/constants/app_strings.dart';

import '../../../../../../shared/models/client.dart';
import '../cubit/client_management_cubit.dart';

// Widget to display a dialog for updating client details
class ClientUpdateDialog {
  // Static method to show the update dialog with provided context
  static void show(BuildContext context, Client client) {
    // Initialize controllers with existing client data
    final nameController = TextEditingController(text: client.name);
    final phoneController = TextEditingController(
      text: client.phoneNumber ?? '',
    );
    final carTypeController = TextEditingController(text: client.carType);
    final modelController = TextEditingController(text: client.model ?? '');
    final balanceController = TextEditingController(
      text: client.balance.toString(),
    );
    final emailController = TextEditingController(text: client.email ?? '');
    final licensePlateController = TextEditingController(
      text: client.licensePlate ?? '',
    );
    final notesController = TextEditingController(text: client.notes ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تحديث العميل'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Form fields for updating client information
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الاسم *'),
              ),
              SizedBox(height: 8),
              TextField(
                maxLength: 15,
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 8),

              TextField(
                controller: carTypeController,
                decoration: const InputDecoration(labelText: 'نوع السيارة *'),
              ),
              SizedBox(height: 8),

              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'الموديل'),
              ),
              SizedBox(height: 8),

              TextField(
                controller: balanceController,
                decoration: const InputDecoration(labelText: 'الرصيد *'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 8),

              TextField(
                controller: licensePlateController,
                decoration: const InputDecoration(labelText: 'رقم اللوحة'),
              ),
              SizedBox(height: 8),

              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
                maxLines: 3,
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          // Save button with validation
          TextButton(
            onPressed: () {
              // Validate required fields
              if (nameController.text.isEmpty ||
                  carTypeController.text.isEmpty ||
                  balanceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى ملء جميع الحقول المطلوبة'),
                  ),
                );
                return;
              }
              // Parse balance with fallback to 0.0
              final balance = double.tryParse(balanceController.text) ?? 0.0;
              // Update client using provided context
              context.read<ClientManagementCubit>().updateClient(
                Client(
                  id: client.id,
                  name: nameController.text,
                  phoneNumber: phoneController.text.isEmpty
                      ? null
                      : phoneController.text,
                  carType: carTypeController.text,
                  model: modelController.text.isEmpty
                      ? null
                      : modelController.text,
                  balance: balance,
                  email: emailController.text.isEmpty
                      ? null
                      : emailController.text,
                  licensePlate: licensePlateController.text.isEmpty
                      ? null
                      : licensePlateController.text,
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                  history: client.history,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
