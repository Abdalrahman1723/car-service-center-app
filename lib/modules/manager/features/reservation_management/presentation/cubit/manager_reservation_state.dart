import 'package:m_world/modules/client/client_feature/domain/entities/reservation.dart';

abstract class ManagerReservationState {}

class ManagerReservationInitial extends ManagerReservationState {}

class ManagerReservationLoading extends ManagerReservationState {}

class ManagerReservationLoaded extends ManagerReservationState {
  final List<Reservation> reservations;

  ManagerReservationLoaded(this.reservations);
}

class ManagerReservationError extends ManagerReservationState {
  final String message;

  ManagerReservationError(this.message);
}
