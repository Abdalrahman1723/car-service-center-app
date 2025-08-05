import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_world/modules/manager/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:m_world/modules/manager/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:m_world/modules/manager/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/add_item_to_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/get_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/remove_item_from_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/update_item_in_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/cubit/inventory_cubit.dart';

class InventoryModule {
  static InventoryCubit provideInventoryCubit() {
    final firestore = FirebaseFirestore.instance;
    final remoteDataSource = InventoryRemoteDataSourceImpl(firestore);
    final repository = InventoryRepositoryImpl(remoteDataSource);

    return InventoryCubit(
      getInventoryUseCase: GetInventoryUseCase(repository),
      addItemToInventoryUseCase: AddItemToInventoryUseCase(repository),
      updateItemInInventoryUseCase: UpdateItemInInventoryUseCase(repository),
      removeItemFromInventoryUseCase: RemoveItemFromInventoryUseCase(
        repository,
      ),
    );
  }

  static InventoryRepository provideInventoryRepository() {
    final firestore = FirebaseFirestore.instance;
    final remoteDataSource = InventoryRemoteDataSourceImpl(firestore);
    return InventoryRepositoryImpl(remoteDataSource);
  }
}
