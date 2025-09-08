import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_world/modules/client/client_feature/domain/entities/reservation.dart';

class ReservationDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _reservationsCollection = 'reservations';

  Future<void> submitReservation(Reservation reservation) async {
    try {
      await _firestore
          .collection(_reservationsCollection)
          .doc(reservation.id)
          .set(reservation.toMap());
    } catch (e) {
      throw Exception('Failed to submit reservation: $e');
    }
  }
}
