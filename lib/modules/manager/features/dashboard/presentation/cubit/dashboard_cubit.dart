import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:m_world/shared/models/client.dart';
import 'package:m_world/shared/models/invoice.dart';

import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repository;

  DashboardCubit(this.repository) : super(DashboardInitial());

  Future<void> searchClients(String query) async {
    emit(DashboardLoading());
    try {
      final clients = await repository.searchClients(query);
      emit(DashboardClientsLoaded(clients));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> searchInvoices(String query) async {
    emit(DashboardLoading());
    try {
      final invoices = await repository.searchInvoices(query);
      emit(DashboardInvoicesLoaded(invoices));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> addClient(Client client) async {
    emit(DashboardLoading());
    try {
      await repository.addClient(client);
      emit(DashboardSuccess('Client added successfully'));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    emit(DashboardLoading());
    try {
      await repository.addInvoice(invoice);
      emit(DashboardSuccess('Invoice added successfully'));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> loadAllClients() async {
    emit(DashboardLoading());
    try {
      final clients = await repository.getAllClients();
      emit(DashboardClientsLoaded(clients));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> loadAllInvoices() async {
    emit(DashboardLoading());
    try {
      final invoices = await repository.getAllInvoices();
      emit(DashboardInvoicesLoaded(invoices));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }



  Future<void> logout() async {
    emit(DashboardLoading());
    try {
      await repository.logout();
      emit(DashboardLoggedOut());
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}