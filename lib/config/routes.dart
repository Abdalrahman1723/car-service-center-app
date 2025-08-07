import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/auth/login/presentation/pages/login_screen.dart';
import 'package:m_world/modules/employee/invoice_management/presentation/pages/invoice_add_screen.dart';
import 'package:m_world/modules/employee/invoice_management/presentation/pages/invoice_list_screen.dart';
import 'package:m_world/modules/manager/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/pages/inventory_panel.dart';
import 'package:m_world/modules/manager/features/manage_clients/presentation/pages/client_list_screen.dart';
import 'package:m_world/shared/splash/splash_screen.dart';
import '../modules/employee/invoice_management/data/datasources/invoice_datasource.dart';
import '../modules/employee/invoice_management/data/repositories/invoice_repository_impl.dart';
import '../modules/employee/invoice_management/domain/usecases/add_invoice.dart';
import '../modules/employee/invoice_management/domain/usecases/get_all_invoices.dart';
import '../modules/employee/invoice_management/presentation/cubit/invoice_management_cubit.dart';
import '../modules/manager/features/manage_clients/data/datasources/client_datasource.dart';
import '../modules/manager/features/manage_clients/data/repositories/client_repository_impl.dart';
import '../modules/manager/features/manage_clients/domain/usecases/add_client.dart';
import '../modules/manager/features/manage_clients/domain/usecases/delete_client.dart';
import '../modules/manager/features/manage_clients/domain/usecases/get_all_clients.dart';
import '../modules/manager/features/manage_clients/domain/usecases/update_client.dart';
import '../modules/manager/features/manage_clients/presentation/cubit/client_management_cubit.dart';
import '../modules/manager/features/manage_clients/presentation/pages/client_management_screen.dart';
import '../modules/manager/features/inventory/inventory_module.dart';

class Routes {
  static const String splash = "/"; //?initial route
  static const String login = '/LoginScreen';
  static const String adminDashboard = '/DashboardScreen';
  static const String inventoryPanel = '/InventoryPanel';
  static const String clientManagement = '/ClientManagementScreen';
  static const String clientList = '/ClientListScreen';
  static const String invoiceAdd = '/InvoiceAddScreen';
  static const String invoiceList = '/InvoiceListScreen';
}

final routes = {
  Routes.splash: (context) => const SplashScreen(),
  Routes.login: (context) => const LoginScreen(),
  Routes.adminDashboard: (context) => const DashboardScreen(),
  Routes.inventoryPanel: (context) => const InventoryPanel(),
  Routes.clientManagement: (context) => BlocProvider(
    create: (context) => ClientManagementCubit(
      addClientUseCase: AddClient(
        ClientRepositoryImpl(FirebaseClientDataSource()),
      ),
      updateClientUseCase: UpdateClient(
        ClientRepositoryImpl(FirebaseClientDataSource()),
      ),
      deleteClientUseCase: DeleteClient(
        ClientRepositoryImpl(FirebaseClientDataSource()),
      ),
    ),
    child: const ClientManagementScreen(),
  ),
  //-------------------
  Routes.clientList: (context) => BlocProvider(
    create: (context) => ClientManagementCubit(
      addClientUseCase: AddClient(
        ClientRepositoryImpl(FirebaseClientDataSource()),
      ),
      updateClientUseCase: UpdateClient(
        ClientRepositoryImpl(FirebaseClientDataSource()),
      ),
      deleteClientUseCase: DeleteClient(
        ClientRepositoryImpl(FirebaseClientDataSource()),
      ),
    ),
    child: const ClientListScreen(),
  ),
  //-------------------
  Routes.invoiceAdd: (context) => BlocProvider(
    create: (context) => InvoiceManagementCubit(
      addInvoiceUseCase: AddInvoice(
        InvoiceRepositoryImpl(
          FirebaseInvoiceDataSource(),
          FirebaseClientDataSource(),
        ),
      ),
      getAllInvoicesUseCase: GetAllInvoices(
        InvoiceRepositoryImpl(
          FirebaseInvoiceDataSource(),
          FirebaseClientDataSource(),
        ),
      ),
      getAllClientsUseCase: GetAllClients(
        ClientRepositoryImpl(FirebaseClientDataSource()),
      ),
      inventoryRepository: InventoryModule.provideInventoryRepository(),
    ),
    child: const InvoiceAddScreen(),
  ),
  //-------------------
  Routes.invoiceList: (context) => BlocProvider(
    create: (context) => InvoiceManagementCubit(
      addInvoiceUseCase: AddInvoice(
        InvoiceRepositoryImpl(
          FirebaseInvoiceDataSource(),
          FirebaseClientDataSource(),
        ),
      ),
      getAllInvoicesUseCase: GetAllInvoices(
        InvoiceRepositoryImpl(
          FirebaseInvoiceDataSource(),
          FirebaseClientDataSource(),
        ),
      ),
      getAllClientsUseCase: GetAllClients(
        ClientRepositoryImpl(FirebaseClientDataSource()),
      ),
      inventoryRepository: InventoryModule.provideInventoryRepository(),
    ),
    child: const InvoiceListScreen(),
  ),
};
