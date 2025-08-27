import 'package:equatable/equatable.dart';
import '../../domain/entities/item_profitability.dart';

abstract class ItemProfitabilityState extends Equatable {
  const ItemProfitabilityState();

  @override
  List<Object?> get props => [];
}

class ItemProfitabilityInitial extends ItemProfitabilityState {}

class ItemProfitabilityLoading extends ItemProfitabilityState {}

class ItemProfitabilityLoaded extends ItemProfitabilityState {
  final List<ItemProfitability> items;

  const ItemProfitabilityLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class ItemProfitabilityError extends ItemProfitabilityState {
  final String message;

  const ItemProfitabilityError(this.message);

  @override
  List<Object?> get props => [message];
}
