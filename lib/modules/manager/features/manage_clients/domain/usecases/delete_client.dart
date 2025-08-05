// Use case for deleting a client
import '../../../../../../core/usecases/usecase.dart';
import '../repositories/client_repository.dart';

class DeleteClient implements UseCase<void, String> {
  final ClientRepository repository;

  DeleteClient(this.repository);

  @override
  Future<void> call(String clientId) async {
    await repository.deleteClient(clientId);
  }
}
