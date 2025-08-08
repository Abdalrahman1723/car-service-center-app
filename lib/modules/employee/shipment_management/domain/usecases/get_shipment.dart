// Use case to fetch all shipments
import '../entities/shipment.dart';
import '../repositories/shipment_repository.dart';

class GetShipments {
  final ShipmentRepository repository;

  GetShipments(this.repository);

  Future<List<ShipmentEntity>> call() async {
    return await repository.getShipments();
  }
}
