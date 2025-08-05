// Use case for adding a new client
import '../../../../../../core/usecases/usecase.dart';
import '../../../../../../shared/models/client.dart';
import '../repositories/client_repository.dart';

class AddClient implements UseCase<void, Client> {
  final ClientRepository repository;

  AddClient(this.repository);

  @override
  Future<void> call(Client client) async {
    await repository.addClient(client);
  }
}
