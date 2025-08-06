import 'package:m_world/modules/manager/features/manage_clients/domain/repositories/client_repository.dart';

import '../../../../../../shared/models/client.dart';

class GetAllClients {
  final ClientRepository repository;

  GetAllClients(this.repository);

  Future<List<Client>> call() async {
    return await repository.getAllClients();
  }
}