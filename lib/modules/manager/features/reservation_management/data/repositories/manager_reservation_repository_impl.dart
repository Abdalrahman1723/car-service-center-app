import 'package:m_world/modules/client/client_feature/domain/entities/reservation.dart';
import 'package:m_world/modules/manager/features/reservation_management/data/datasources/manager_reservation_datasource.dart';
import 'package:m_world/modules/manager/features/reservation_management/domain/repositories/manager_reservation_repository.dart';

class ManagerReservationRepositoryImpl implements ManagerReservationRepository {
  final ManagerReservationDataSource dataSource;

  ManagerReservationRepositoryImpl(this.dataSource);

  @override
  Future<List<Reservation>> getReservations() async {
    try {
      return await dataSource.getReservations();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<void> markReservationContacted(String reservationId) async {
    try {
      await dataSource.markReservationContacted(reservationId);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<void> deleteReservation(String reservationId) async {
    try {
      await dataSource.deleteReservation(reservationId);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}
