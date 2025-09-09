import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_world/modules/client/client_feature/domain/entities/reservation.dart';

class ManagerReservationDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _reservationsCollection = 'reservations';

  Future<List<Reservation>> getReservations() async {
    try {
      final snapshot = await _firestore
          .collection(_reservationsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Reservation.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reservations: $e');
    }
  }

  Future<void> markReservationContacted(String reservationId) async {
    try {
      await _firestore
          .collection(_reservationsCollection)
          .doc(reservationId)
          .update({'contacted': true});
    } catch (e) {
      throw Exception('Failed to mark reservation as contacted: $e');
    }
  }

  Future<void> deleteReservation(String reservationId) async {
    try {
      await _firestore
          .collection(_reservationsCollection)
          .doc(reservationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete reservation: $e');
    }
  }
}
