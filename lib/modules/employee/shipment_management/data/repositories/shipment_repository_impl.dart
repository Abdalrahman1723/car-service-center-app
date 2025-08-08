import '../../domain/entities/shipment.dart';
import '../../domain/repositories/shipment_repository.dart';
import '../datasources/shipment_datasource.dart';
import '../models/shipment_model.dart';

// Repository implementation for shipment management
class ShipmentRepositoryImpl implements ShipmentRepository {
  final ShipmentDataSource dataSource;

  ShipmentRepositoryImpl(this.dataSource);

  @override
  Future<List<ShipmentEntity>> getShipments() async {
    final models = await dataSource.getShipments();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addShipment(ShipmentEntity shipment) async {
    await dataSource.addShipment(ShipmentModel.fromEntity(shipment));
  }

  @override
  Future<void> updateShipment(
    ShipmentEntity oldShipment,
    ShipmentEntity newShipment,
  ) async {
    await dataSource.updateShipment(
      ShipmentModel.fromEntity(oldShipment),
      ShipmentModel.fromEntity(newShipment),
    );
  }

  @override
  Future<void> deleteShipment(ShipmentEntity shipment) async {
    await dataSource.deleteShipment(ShipmentModel.fromEntity(shipment));
  }
}
