abstract class ClientScreenState {}

class ClientScreenInitial extends ClientScreenState {}

class ClientScreenLoading extends ClientScreenState {}

class ClientScreenSuccess extends ClientScreenState {
  final String message;

  ClientScreenSuccess(this.message);
}

class ClientScreenError extends ClientScreenState {
  final String message;

  ClientScreenError(this.message);
}
