import 'package:equatable/equatable.dart';
import '../../domain/entities/net_profit.dart';

abstract class NetProfitState extends Equatable {
  const NetProfitState();

  @override
  List<Object?> get props => [];
}

class NetProfitInitial extends NetProfitState {}

class NetProfitLoading extends NetProfitState {}

class NetProfitLoaded extends NetProfitState {
  final NetProfit netProfit;

  const NetProfitLoaded(this.netProfit);

  @override
  List<Object?> get props => [netProfit];
}

class NetProfitError extends NetProfitState {
  final String message;

  const NetProfitError(this.message);

  @override
  List<Object?> get props => [message];
}
