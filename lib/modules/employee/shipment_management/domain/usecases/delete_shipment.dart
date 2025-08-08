// Use case to delete a shipment
import '../entities/shipment.dart';
import '../repositories/shipment_repository.dart';

class DeleteShipment {
  final ShipmentRepository repository;

  DeleteShipment(this.repository);

  Future<void> call(ShipmentEntity shipment) async {
    await repository.deleteShipment(shipment);
  }
}
