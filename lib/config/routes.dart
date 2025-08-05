import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/auth/login/presentation/pages/login_screen.dart';
import 'package:m_world/modules/manager/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/pages/inventory_panel.dart';
import 'package:m_world/shared/splash/splash_screen.dart';

import '../modules/manager/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../modules/manager/features/manage_clients/data/datasources/client_datasource.dart';
import '../modules/manager/features/manage_clients/data/repositories/client_repository_impl.dart';
import '../modules/manager/features/manage_clients/domain/usecases/add_client.dart';
import '../modules/manager/features/manage_clients/domain/usecases/delete_client.dart';
import '../modules/manager/features/manage_clients/domain/usecases/update_client.dart';
import '../modules/manager/features/manage_clients/presentation/cubit/client_management_cubit.dart';
import '../modules/manager/features/manage_clients/presentation/pages/client_management_screen.dart';

class Routes {
  static const String splash = "/"; //?initial route
  static const String login = '/LoginScreen';
  static const String adminDashboard = '/DashboardScreen';
  static const String inventoryPanel = '/InventoryPanel';
  static const String clientManagement = '/ClientManagementScreen';
}

final routes = {
  Routes.splash: (context) => const SplashScreen(),
  Routes.login: (context) => const LoginScreen(),
  Routes.adminDashboard: (context) => const DashboardScreen(),
  Routes.inventoryPanel: (context) => const InventoryPanel(),
  Routes.clientManagement: (context) => BlocProvider(
    create: (context) => ClientManagementCubit(
      FirebaseDashboardRepository(),
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
};
