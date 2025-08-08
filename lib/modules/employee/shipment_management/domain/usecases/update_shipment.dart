// Use case to update a shipment
import '../entities/shipment.dart';
import '../repositories/shipment_repository.dart';

class UpdateShipment {
  final ShipmentRepository repository;

  UpdateShipment(this.repository);

  Future<void> call(
    ShipmentEntity oldShipment,
    ShipmentEntity newShipment,
  ) async {
    await repository.updateShipment(oldShipment, newShipment);
  }
}
