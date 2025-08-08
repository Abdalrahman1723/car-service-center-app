// Use case to add a shipment
import '../entities/shipment.dart';
import '../repositories/shipment_repository.dart';

class AddShipment {
  final ShipmentRepository repository;

  AddShipment(this.repository);

  Future<void> call(ShipmentEntity shipment) async {
    await repository.addShipment(shipment);
  }
}
