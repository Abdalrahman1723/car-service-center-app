import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/modules/client/client_feature/domain/entities/reservation.dart';
import 'package:m_world/modules/client/client_feature/presentation/cubit/client_screen_cubit.dart';
import 'package:m_world/modules/client/client_feature/presentation/cubit/client_screen_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  ClientsScreenState createState() => ClientsScreenState();
}

class ClientsScreenState extends State<ClientsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _carTypeController = TextEditingController();
  final _problemController = TextEditingController();
  final _inquiriesController = TextEditingController();
  DateTime? _visitDate;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.login),
          child: Text(
            "M World service center",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF0f172a),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Gradient background with decorative circles
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightBlueAccent.withOpacity(0.1),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  _HeaderCard(isSmallScreen: isSmallScreen),

                  const SizedBox(height: 16),

                  // Image slider card
                  _SliderCard(isSmallScreen: isSmallScreen),

                  const SizedBox(height: 16),

                  // CTA button
                  Center(
                    child: SizedBox(
                      width: isSmallScreen ? double.infinity : 300,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 20 : 24,
                            vertical: isSmallScreen ? 14 : 16,
                          ),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        icon: const Icon(
                          Icons.event_available,
                          color: Colors.white,
                        ),
                        label: Text(
                          'حجز موعد',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reservation form card
                  _FormCard(
                    formKey: _formKey,
                    nameController: _nameController,
                    phoneController: _phoneController,
                    carTypeController: _carTypeController,
                    problemController: _problemController,
                    inquiriesController: _inquiriesController,
                    visitDate: _visitDate,
                    isSmallScreen: isSmallScreen,
                    onPickDate: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) setState(() => _visitDate = date);
                    },
                    onSubmit: () {
                      if (_formKey.currentState!.validate()) {
                        final reservation = Reservation(
                          id: DateTime.now().toIso8601String(),
                          name: _nameController.text,
                          phoneNumber: _phoneController.text,
                          carType: _carTypeController.text,
                          problem: _problemController.text,
                          visitDate: _visitDate!,
                          inquiries: _inquiriesController.text.isEmpty
                              ? null
                              : _inquiriesController.text,
                          createdAt: DateTime.now(),
                        );
                        context.read<ClientScreenCubit>().submitReservationForm(
                          reservation,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.isSmallScreen});

  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.06),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: isSmallScreen ? 44 : 56,
                  height: isSmallScreen ? 44 : 56,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.precision_manufacturing,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مركز خدمة إم وورلد',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 22 : 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'خدمة وصيانة سيارات BMW بأحدث التقنيات',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              runSpacing: 8,
              spacing: 10,
              children: [
                _InfoChip(
                  icon: Icons.location_on,
                  label: AppStrings.serviceCenterAddress,
                ),
                _InfoChip(
                  icon: Icons.phone,
                  label: AppStrings.serviceCenterPhoneNumber,
                ),
                GestureDetector(
                  onTap: () async {
                    const url = AppStrings.googleMapsLocation;
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    }
                  },
                  child: const _InfoChip(
                    icon: Icons.map,
                    label: 'الموقع على خرائط جوجل',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'مركز إم وورلد هو وجهتك المثالية لصيانة سيارات BMW. نقدم خدمات متميزة بأحدث التقنيات، فريقنا المحترف يضمن عودة سيارتك إلى أفضل حالاتها بسرعة وكفاءة!',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.lightBlueAccent),
          const SizedBox(width: 6),
          Flexible(
            child: SelectableText(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              maxLines: null,
              minLines: 1,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({required this.isSmallScreen});

  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.06),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: isSmallScreen ? 12 : 16,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CarouselSlider(
            options: CarouselOptions(
              height: isSmallScreen ? 170 : 220,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              viewportFraction: isSmallScreen ? 0.9 : 0.7,
            ),
            items: ['assets/icon.png'].map((url) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(url, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.carTypeController,
    required this.problemController,
    required this.inquiriesController,
    required this.visitDate,
    required this.isSmallScreen,
    required this.onPickDate,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController carTypeController;
  final TextEditingController problemController;
  final TextEditingController inquiriesController;
  final DateTime? visitDate;
  final bool isSmallScreen;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
    );

    return Card(
      color: Colors.white.withOpacity(0.06),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.assignment_turned_in,
                    color: Colors.lightBlueAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'نموذج الحجز',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'الاسم *',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Colors.lightBlueAccent,
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: const BorderSide(color: Colors.lightBlueAccent),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 14),

              // Phone
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف *',
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: Colors.lightBlueAccent,
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: const BorderSide(color: Colors.lightBlueAccent),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'رقم الهاتف مطلوب' : null,
              ),
              const SizedBox(height: 14),

              // Car type
              TextFormField(
                controller: carTypeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'نوع وموديل السيارة *',
                  prefixIcon: const Icon(
                    Icons.directions_car_filled_outlined,
                    color: Colors.lightBlueAccent,
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: const BorderSide(color: Colors.lightBlueAccent),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'نوع السيارة مطلوب' : null,
              ),
              const SizedBox(height: 14),

              // Problem
              TextFormField(
                controller: problemController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'المشكلة في السيارة *',
                  prefixIcon: const Icon(
                    Icons.build_outlined,
                    color: Colors.lightBlueAccent,
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: const BorderSide(color: Colors.lightBlueAccent),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'المشكلة مطلوبة' : null,
              ),
              const SizedBox(height: 14),

              // Date
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: visitDate != null
                      ? DateFormat.yMMMd().format(visitDate!)
                      : '',
                ),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'تاريخ الزيارة *',
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.lightBlueAccent,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.event,
                      color: Colors.lightBlueAccent,
                    ),
                    onPressed: onPickDate,
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: const BorderSide(color: Colors.lightBlueAccent),
                  ),
                ),
                validator: (value) =>
                    visitDate == null ? 'تاريخ الزيارة مطلوب' : null,
              ),
              const SizedBox(height: 14),

              // Inquiries
              TextFormField(
                controller: inquiriesController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'استفسارات أخرى (اختياري)',
                  prefixIcon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.lightBlueAccent,
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: const BorderSide(color: Colors.lightBlueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit button with loading state via Bloc
              BlocConsumer<ClientScreenCubit, ClientScreenState>(
                listener: (context, state) {
                  if (state is ClientScreenSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                    formKey.currentState!.reset();
                    nameController.clear();
                    phoneController.clear();
                    carTypeController.clear();
                    problemController.clear();
                    inquiriesController.clear();
                  } else if (state is ClientScreenError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is ClientScreenLoading ? null : onSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 20 : 30,
                          vertical: isSmallScreen ? 14 : 16,
                        ),
                        backgroundColor: Colors.lightBlueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: state is ClientScreenLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'تقديم الحجز',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
