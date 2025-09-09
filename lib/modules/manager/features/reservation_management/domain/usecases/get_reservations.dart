import 'package:m_world/modules/client/client_feature/domain/entities/reservation.dart';
import 'package:m_world/modules/manager/features/reservation_management/domain/repositories/manager_reservation_repository.dart';

class GetReservations {
  final ManagerReservationRepository repository;

  GetReservations(this.repository);

  Future<List<Reservation>> call() async {
    return await repository.getReservations();
  }
}
