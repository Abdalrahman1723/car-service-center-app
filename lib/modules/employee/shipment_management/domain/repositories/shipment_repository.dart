import '../entities/shipment.dart';

// Abstract repository for shipment operations
abstract class ShipmentRepository {
  Future<List<ShipmentEntity>> getShipments();
  Future<void> addShipment(ShipmentEntity shipment);
  Future<void> updateShipment(ShipmentEntity oldShipment, ShipmentEntity newShipment);
  Future<void> deleteShipment(ShipmentEntity shipment);
}