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
    // For supporting multiple cars, create a list of controllers for each car's type, model, and license plate
    final List<TextEditingController> carTypeControllers = client.cars
        .map((car) => TextEditingController(text: car['type'] ?? ''))
        .toList();
    final List<TextEditingController> carModelControllers = client.cars
        .map((car) => TextEditingController(text: car['model'] ?? ''))
        .toList();
    final List<TextEditingController> carLicensePlateControllers = client.cars
        .map((car) => TextEditingController(text: car['licensePlate'] ?? ''))
        .toList();

    final balanceController = TextEditingController(
      text: client.balance.toString(),
    );
    final emailController = TextEditingController(text: client.email ?? '');
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

              // Show car fields from map (supporting multiple cars)
              ...List.generate(
                carTypeControllers.length,
                (index) => Column(
                  children: [
                    TextField(
                      controller: carTypeControllers[index],
                      decoration: InputDecoration(
                        labelText:
                            'نوع السيارة ${carTypeControllers.length > 1 ? '(${index + 1})' : ''} *',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: carModelControllers[index],
                      decoration: InputDecoration(
                        labelText:
                            'موديل السيارة ${carModelControllers.length > 1 ? '(${index + 1})' : ''} *',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: carLicensePlateControllers[index],
                      decoration: InputDecoration(
                        labelText:
                            'رقم اللوحة ${carLicensePlateControllers.length > 1 ? '(${index + 1})' : ''}',
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
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
                  carTypeControllers.any(
                    (controller) => controller.text.isEmpty,
                  ) ||
                  carModelControllers.any(
                    (controller) => controller.text.isEmpty,
                  ) ||
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
                  cars: List.generate(
                    carTypeControllers.length,
                    (index) => {
                      'type': carTypeControllers[index].text,
                      'model': carModelControllers[index].text,
                      'licensePlate': carLicensePlateControllers[index].text,
                    },
                  ),
                  balance: balance,
                  email: emailController.text.isEmpty
                      ? null
                      : emailController.text,
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
