// Use case for updating an existing client
import '../../../../../../core/usecases/usecase.dart';
import '../../../../../../shared/models/client.dart';
import '../repositories/client_repository.dart';

class UpdateClient implements UseCase<void, Client> {
  final ClientRepository repository;

  UpdateClient(this.repository);

  @override
  Future<void> call(Client client) async {
    await repository.updateClient(client);
  }
}
