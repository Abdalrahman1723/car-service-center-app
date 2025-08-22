import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../cubit/client_management_cubit.dart';

// Page for adding a new client with multiple cars
class ClientManagementScreen extends StatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  ClientManagementScreenState createState() => ClientManagementScreenState();
}

class ClientManagementScreenState extends State<ClientManagementScreen> {
  // Controllers for client details
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final balanceController = TextEditingController(text: '0.0');
  final emailController = TextEditingController();
  final notesController = TextEditingController();

  // List of controllers for multiple cars
  List<Map<String, TextEditingController>> carControllers = [
    {
      'type': TextEditingController(),
      'model': TextEditingController(),
      'licensePlateNumber': TextEditingController(),
      'licensePlateLetter': TextEditingController(),
    },
  ];

  // Add a new car entry
  void _addCar() {
    setState(() {
      carControllers.add({
        'type': TextEditingController(),
        'model': TextEditingController(),
        'licensePlateNumber': TextEditingController(),
        'licensePlateLetter': TextEditingController(),
      });
    });
  }

  // Remove a car entry
  void _removeCar(int index) {
    setState(() {
      carControllers[index].values.forEach(
        (controller) => controller.dispose(),
      );
      carControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    // Dispose client controllers
    nameController.dispose();
    phoneController.dispose();
    balanceController.dispose();
    emailController.dispose();
    notesController.dispose();
    // Dispose car controllers
    for (var car in carControllers) {
      for (var controller in car.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عميل جديد')),
      body: BlocConsumer<ClientManagementCubit, ClientManagementState>(
        listener: (context, state) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client Information Form Fields
                _buildClientFormFields(
                  nameController: nameController,
                  phoneController: phoneController,
                  balanceController: balanceController,
                  emailController: emailController,
                  notesController: notesController,
                ),
                const SizedBox(height: 24),
                // Car Information Form Fields
                const Text(
                  'معلومات السيارات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...carControllers.asMap().entries.map(
                  (entry) => _buildCarFormFields(
                    index: entry.key,
                    typeController: entry.value['type']!,
                    modelController: entry.value['model']!,
                    licensePlateNumberController:
                        entry.value['licensePlateNumber']!,
                    licensePlateLetterController:
                        entry.value['licensePlateLetter']!,
                  ),
                ),
                const SizedBox(height: 16),
                // Add Car Button
                ElevatedButton.icon(
                  onPressed: _addCar,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة سيارة أخرى'),
                ),
                const SizedBox(height: 24),
                // Submit Button
                _buildSubmitButton(
                  context: context,
                  state: state,
                  nameController: nameController,
                  phoneController: phoneController,
                  balanceController: balanceController,
                  emailController: emailController,
                  notesController: notesController,
                  carControllers: carControllers,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Builds form fields for client information
  Widget _buildClientFormFields({
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController balanceController,
    required TextEditingController emailController,
    required TextEditingController notesController,
  }) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'الاسم *',
            hintText: 'أدخل الاسم الكامل للعميل',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          maxLength: 15,
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف',
            hintText: 'أدخل رقم الاتصال',
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: balanceController,
          decoration: const InputDecoration(
            labelText: 'الرصيد *',
            hintText: 'أدخل الرصيد الحالي',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'البريد الإلكتروني',
            hintText: 'أدخل عنوان البريد الإلكتروني',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'ملاحظات',
            hintText: 'ملاحظات إضافية حول العميل',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  // Builds form fields for a single car
  Widget _buildCarFormFields({
    required int index,
    required TextEditingController typeController,
    required TextEditingController modelController,
    required TextEditingController licensePlateNumberController,
    required TextEditingController licensePlateLetterController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'سيارة ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (index > 0)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeCar(index),
              ),
          ],
        ),
        TextField(
          controller: typeController,
          decoration: const InputDecoration(
            labelText: 'نوع السيارة *',
            hintText: 'مثال: BMW X6',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: modelController,
          decoration: const InputDecoration(
            labelText: 'الموديل',
            hintText: 'مثال: 2025 - فئة اولى',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                maxLength: 7,
                controller: licensePlateNumberController,
                decoration: const InputDecoration(
                  labelText: 'أرقام اللوحة',
                  hintText: '١ ٢ ٣ ٤',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9 ]*')),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                maxLength: 5,
                controller: licensePlateLetterController,
                decoration: const InputDecoration(
                  labelText: 'حروف اللوحة',
                  hintText: 'أ ب ج',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^[a-zA-Z\u0600-\u06FF ]*'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Builds the submit button
  Widget _buildSubmitButton({
    required BuildContext context,
    required ClientManagementState state,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController balanceController,
    required TextEditingController emailController,
    required TextEditingController notesController,
    required List<Map<String, TextEditingController>> carControllers,
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
                balanceController: balanceController,
                emailController: emailController,
                notesController: notesController,
                carControllers: carControllers,
              ),
        child: state is ClientManagementLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('إضافة العميل'),
      ),
    );
  }

  // Handles form submission with validation
  void _handleFormSubmission({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController balanceController,
    required TextEditingController emailController,
    required TextEditingController notesController,
    required List<Map<String, TextEditingController>> carControllers,
  }) {
    // Validate required client fields
    if (nameController.text.isEmpty || balanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة للعميل')),
      );
      return;
    }

    // Validate at least one car with type
    if (carControllers.isEmpty ||
        carControllers.any((car) => car['type']!.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال نوع السيارة لكل سيارة')),
      );
      return;
    }

    // Parse balance
    final balance = double.tryParse(balanceController.text) ?? 0.0;

    // Build cars list
    final cars = carControllers.map((car) {
      String licensePlate = '';
      if (car['licensePlateNumber']!.text.trim().isNotEmpty ||
          car['licensePlateLetter']!.text.trim().isNotEmpty) {
        licensePlate =
            '${car['licensePlateNumber']!.text.trim()} / ${car['licensePlateLetter']!.text.trim()}';
      }
      return {
        'type': car['type']!.text,
        'model': car['model']!.text.isEmpty ? null : car['model']!.text,
        'licensePlate': licensePlate.isEmpty ? null : licensePlate,
      };
    }).toList();

    // Submit to cubit
    context.read<ClientManagementCubit>().addClient(
      name: nameController.text,
      phoneNumber:phoneController.text,
      cars: cars,
      balance: balance,
      email: emailController.text.isEmpty ? null : emailController.text,
      notes: notesController.text.isEmpty ? null : notesController.text,
    );
  }
}
