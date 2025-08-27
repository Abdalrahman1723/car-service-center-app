import 'package:equatable/equatable.dart';
import '../../domain/entities/sales_report_item.dart';

abstract class SalesReportState extends Equatable {
  const SalesReportState();

  @override
  List<Object?> get props => [];
}

class SalesReportInitial extends SalesReportState {}

class SalesReportLoading extends SalesReportState {}

class SalesReportLoaded extends SalesReportState {
  final List<SalesReportItem> items;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;

  const SalesReportLoaded({
    required this.items,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
  });

  @override
  List<Object?> get props => [items, totalRevenue, totalCost, totalProfit];
}

class SalesReportError extends SalesReportState {
  final String message;

  const SalesReportError(this.message);

  @override
  List<Object?> get props => [message];
}
