import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m_world/core/services/auth_service.dart';
import 'package:m_world/modules/manager/features/reservation_management/data/datasources/manager_reservation_datasource.dart';
import 'package:m_world/modules/manager/features/reservation_management/data/repositories/manager_reservation_repository_impl.dart';
import 'package:m_world/modules/manager/features/reservation_management/domain/usecases/delete_reservation.dart';
import 'package:m_world/modules/manager/features/reservation_management/domain/usecases/get_reservations.dart';
import 'package:m_world/modules/manager/features/reservation_management/domain/usecases/mark_reservation_contacted.dart';
import 'package:m_world/modules/manager/features/reservation_management/presentation/cubit/manager_reservation_cubit.dart';
import 'package:m_world/modules/manager/features/reservation_management/presentation/cubit/manager_reservation_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ManagerReservationListScreen extends StatefulWidget {
  const ManagerReservationListScreen({super.key});

  @override
  State<ManagerReservationListScreen> createState() =>
      _ManagerReservationListScreenState();
}

class _ManagerReservationListScreenState
    extends State<ManagerReservationListScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return BlocProvider(
      create: (context) => ManagerReservationCubit(
        getReservations: GetReservations(
          ManagerReservationRepositoryImpl(ManagerReservationDataSource()),
        ),
        markReservationContacted: MarkReservationContacted(
          ManagerReservationRepositoryImpl(ManagerReservationDataSource()),
        ),
        deleteReservation: DeleteReservation(
          ManagerReservationRepositoryImpl(ManagerReservationDataSource()),
        ),
        authHelper: AuthService(),
      )..loadReservations(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قائمة الحجوزات'),
          backgroundColor: Colors.blueAccent,
        ),
        body: BlocConsumer<ManagerReservationCubit, ManagerReservationState>(
          listener: (context, state) {
            if (state is ManagerReservationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ManagerReservationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ManagerReservationLoaded) {
              final reservations = state.reservations;
              if (reservations.isEmpty) {
                return const Center(child: Text('لا توجد حجوزات'));
              }
              return ListView.builder(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                itemCount: reservations.length,
                itemBuilder: (context, index) {
                  final reservation = reservations[index];
                  return Card(
                    color: reservation.contacted == true
                        ? Colors.green.withOpacity(0.4)
                        : reservation.contacted == false
                        ? const Color(0xFFE3F2FD) // Light blue for uncontacted
                        : Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reservation.name,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final url = 'tel:${reservation.phoneNumber}';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('لا يمكن إجراء المكالمة'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'رقم الهاتف: ${reservation.phoneNumber}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 22,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'السيارة: ${reservation.carType}',
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'المشكلة: ${reservation.problem}',
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'تاريخ الزيارة: ${DateFormat.yMMMd('ar').format(reservation.visitDate)}',
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          ),
                          const SizedBox(height: 8),
                          if (reservation.inquiries != null)
                            Text(
                              'استفسارات: ${reservation.inquiries}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: reservation.contacted
                                    ? Colors.green
                                    : Colors.red,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'تم التواصل: ${reservation.contacted ? 'نعم' : 'لا'}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 22,
                                color: reservation.contacted
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!reservation.contacted)
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<ManagerReservationCubit>()
                                        .markAsContacted(reservation.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 12 : 16,
                                      vertical: isSmallScreen ? 8 : 10,
                                    ),
                                  ),
                                  child: Text(
                                    'تحديد كمتواصل',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('تأكيد الحذف'),
                                      content: const Text(
                                        'هل أنت متأكد من حذف هذا الحجز؟',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('إلغاء'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('حذف'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    context
                                        .read<ManagerReservationCubit>()
                                        .removeReservation(reservation.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is ManagerReservationError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('اضغط لتحميل الحجوزات'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              context.read<ManagerReservationCubit>().loadReservations();
            });
          },
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }
}
