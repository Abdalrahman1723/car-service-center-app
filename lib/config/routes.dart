import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/auth/login/presentation/pages/login_screen.dart';
import 'package:m_world/modules/client/client_feature/data/datasources/reservation_datasource.dart';
import 'package:m_world/modules/client/client_feature/data/repositories/reservation_repository_impl.dart';
import 'package:m_world/modules/client/client_feature/domain/usecases/submit_reservation.dart';
import 'package:m_world/modules/client/client_feature/presentation/cubit/client_screen_cubit.dart';
import 'package:m_world/modules/client/client_feature/presentation/pages/client_screen.dart';
import 'package:m_world/modules/employee/invoice_management/presentation/pages/invoice_add_screen.dart';
import 'package:m_world/modules/employee/invoice_management/presentation/pages/invoice_list_screen.dart';
import 'package:m_world/modules/employee/shipment_management/data/datasources/shipment_datasource.dart';
import 'package:m_world/modules/employee/shipment_management/data/repositories/shipment_repository_impl.dart';
import 'package:m_world/modules/employee/shipment_management/domain/entities/shipment.dart';
import 'package:m_world/modules/employee/shipment_management/domain/usecases/add_shipment.dart';
import 'package:m_world/modules/employee/shipment_management/domain/usecases/delete_shipment.dart';
import 'package:m_world/modules/employee/shipment_management/domain/usecases/get_shipment.dart';
import 'package:m_world/modules/employee/shipment_management/domain/usecases/update_shipment.dart';
import 'package:m_world/modules/employee/shipment_management/presentation/cubit/shipments_cubit.dart';
import 'package:m_world/modules/employee/shipment_management/presentation/pages/add_shipment_screen.dart';
import 'package:m_world/modules/employee/shipment_management/presentation/pages/shipments_screen.dart';
import 'package:m_world/modules/employee/supplier_management/presentation/pages/suppliers_screen.dart';
import 'package:m_world/modules/manager/features/attendance_management/presentation/cubit/attendance_cubit.dart';
import 'package:m_world/modules/manager/features/attendance_management/presentation/pages/attendance_table_screen.dart';
import 'package:m_world/modules/manager/features/attendance_management/presentation/pages/employee_attendance_screen.dart';
import 'package:m_world/modules/manager/features/attendance_management/presentation/pages/manage_attendance_screen.dart';
import 'package:m_world/modules/manager/features/employee_management/domain/entities/employee.dart';
import 'package:m_world/modules/manager/features/employee_management/presentation/cubit/employee_management_cubit.dart';
import 'package:m_world/modules/manager/features/employee_management/presentation/pages/add_employee_screen.dart';
import 'package:m_world/modules/manager/features/employee_management/presentation/pages/employee_list_screen.dart';
import 'package:m_world/modules/manager/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:m_world/modules/manager/features/employee_management/presentation/pages/employee_profile_screen.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/pages/inventory_panel.dart';
import 'package:m_world/modules/manager/features/manage_clients/presentation/pages/client_list_screen.dart';
import 'package:m_world/modules/manager/features/vault/data/repositories/vault_repository_impl.dart';
import 'package:m_world/modules/manager/features/vault/domain/usecases/add_vault_transaction.dart';
import 'package:m_world/modules/manager/features/vault/presentation/cubit/vault_cubit.dart';
import 'package:m_world/modules/manager/features/vault/presentation/pages/add_vault_transaction_screen.dart';
import 'package:m_world/modules/manager/features/vault/presentation/pages/vault_screen.dart';
import 'package:m_world/modules/employee/supervisor/presentation/pages/supervisor_dashboard_screen.dart';
import 'package:m_world/modules/employee/inventory/presentation/pages/inventory_dashboard_screen.dart';
import 'package:m_world/modules/employee/inventory/presentation/pages/restricted_inventory_panel.dart';
import 'package:m_world/shared/splash/splash_screen.dart';
import '../modules/employee/invoice_management/data/datasources/invoice_datasource.dart';
import '../modules/employee/invoice_management/data/repositories/invoice_repository_impl.dart';
import '../modules/employee/invoice_management/domain/usecases/add_invoice.dart';
import '../modules/employee/invoice_management/domain/usecases/get_all_invoices.dart';
import '../modules/employee/invoice_management/presentation/cubit/invoice_management_cubit.dart';
import '../modules/employee/invoice_management/presentation/pages/invoice_draft_list_screen.dart';
import '../modules/employee/supplier_management/data/datasources/supplier_datasource.dart';
import '../modules/employee/supplier_management/data/repositories/supplier_repository_impl.dart';
import '../modules/employee/supplier_management/domain/entities/supplier.dart';
import '../modules/employee/supplier_management/domain/usecases/add_supplier.dart';
import '../modules/employee/supplier_management/domain/usecases/delete_supplier.dart';
import '../modules/employee/supplier_management/domain/usecases/get_suppliers.dart';
import '../modules/employee/supplier_management/domain/usecases/update_supplier.dart';
import '../modules/employee/supplier_management/presentation/cubit/suppliers_cubit.dart';
import '../modules/employee/supplier_management/presentation/pages/add_supplier_screen.dart';
import '../modules/manager/features/manage_clients/data/datasources/client_datasource.dart';
import '../modules/manager/features/manage_clients/data/repositories/client_repository_impl.dart';
import '../modules/manager/features/manage_clients/domain/usecases/add_client.dart';
import '../modules/manager/features/manage_clients/domain/usecases/delete_client.dart';
import '../modules/manager/features/manage_clients/domain/usecases/get_all_clients.dart';
import '../modules/manager/features/manage_clients/domain/usecases/update_client.dart';
import '../modules/manager/features/manage_clients/presentation/cubit/client_management_cubit.dart';
import '../modules/manager/features/manage_clients/presentation/pages/client_management_screen.dart';
import '../modules/manager/features/inventory/inventory_module.dart';
import '../modules/manager/features/reports/presentation/cubit/reports_cubit.dart';
import '../modules/manager/features/reports/presentation/cubit/sales_report_cubit.dart';
import '../modules/manager/features/reports/presentation/cubit/transaction_summary_cubit.dart';
import '../modules/manager/features/reports/presentation/cubit/revenue_expense_cubit.dart';
import '../modules/manager/features/reports/presentation/cubit/item_profitability_cubit.dart';
import '../modules/manager/features/reports/presentation/pages/reports_screen.dart';
import '../modules/manager/features/reports/presentation/pages/sales_report_screen.dart';
import '../modules/manager/features/reports/presentation/pages/transaction_summary_screen.dart';
import '../modules/manager/features/reports/presentation/pages/revenue_expense_screen.dart';
import '../modules/manager/features/reports/presentation/pages/item_profitability_screen.dart';

class Routes {
  static const String splash = "/"; //?initial route
  static const String login = '/LoginScreen';
  static const String adminDashboard = '/DashboardScreen';
  static const String supervisorDashboard = '/SupervisorDashboardScreen';
  static const String inventoryDashboard = '/InventoryDashboardScreen';
  static const String inventoryPanel = '/InventoryPanel';
  static const String restrictedInventoryPanel = '/RestrictedInventoryPanel';
  static const String clientManagement = '/ClientManagementScreen';
  static const String clientList = '/ClientListScreen';
  static const String invoiceAdd = '/InvoiceAddScreen';
  static const String invoiceList = '/InvoiceListScreen';
  static const String invoiceDraftList = '/InvoiceDraftListScreen';
  static const String suppliers = '/SuppliersPage';
  static const String addSupplier = '/AddSupplierPage';
  static const String shipments = '/ShipmentsPage';
  static const String addShipment = '/AddShipmentPage';
  static const String vault = '/vault';
  static const String addVaultTransaction = '/add_vault_transaction';
  static const String vaultReport = '/vault_report';
  static const String employeeList = '/Employee_List';
  static const String addEmployee = '/Add_employee';
  static const String employeeProfile = '/Employee_profile';
  static const String weeklyAttendanceTable = '/WeeklyAttendanceTableScreen';
  static const String employeeAttendance = '/EmployeeAttendanceScreen';
  static const String manageAttendance = '/ManageAttendanceScreen';
  static const String reports = '/reports';
  static const String salesReport = '/reports/sales';
  static const String transactionsReport = '/reports/transactions';
  static const String revenueExpenseReport = '/reports/revenue-expense';
  static const String profitabilityReport = '/reports/profitability';
  static const String visitor = '/clients';
}

final routes = {
  Routes.splash: (context) => const SplashScreen(),
  Routes.login: (context) => const LoginScreen(),
  Routes.adminDashboard: (context) => const DashboardScreen(),
  Routes.supervisorDashboard: (context) => const SupervisorDashboardScreen(),
  Routes.inventoryDashboard: (context) => const InventoryDashboardScreen(),
  Routes.inventoryPanel: (context) => const InventoryPanel(),
  Routes.restrictedInventoryPanel: (context) =>
      const RestrictedInventoryPanel(),
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
  Routes.invoiceAdd: (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    return BlocProvider(
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
        addTransaction: AddVaultTransaction(VaultRepositoryImpl()), //!
      ),
      child: InvoiceAddScreen(draftData: args['draftData']),
    );
  },
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
      addTransaction: AddVaultTransaction(VaultRepositoryImpl()), //!
    ),
    child: const InvoiceListScreen(),
  ),
  //------------------- draft
  Routes.invoiceDraftList: (context) => BlocProvider(
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
      addTransaction: AddVaultTransaction(VaultRepositoryImpl()),
    )..loadDrafts(),
    child: const InvoiceDraftListScreen(),
  ),
  //-------------------
  Routes.suppliers: (context) => BlocProvider(
    create: (context) => SuppliersCubit(
      getSuppliersUseCase: GetSuppliers(
        SupplierRepositoryImpl(SupplierDataSource(FirebaseFirestore.instance)),
      ),
      addSupplierUseCase: AddSupplier(
        SupplierRepositoryImpl(SupplierDataSource(FirebaseFirestore.instance)),
      ),
      updateSupplierUseCase: UpdateSupplier(
        SupplierRepositoryImpl(SupplierDataSource(FirebaseFirestore.instance)),
      ),
      deleteSupplierUseCase: DeleteSupplier(
        SupplierRepositoryImpl(SupplierDataSource(FirebaseFirestore.instance)),
      ),
    )..loadSuppliers(),
    child: const SuppliersScreen(),
  ),
  //------------------- takes args
  Routes.addSupplier: (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    return BlocProvider(
      create: (context) => SuppliersCubit(
        getSuppliersUseCase: GetSuppliers(
          SupplierRepositoryImpl(
            SupplierDataSource(FirebaseFirestore.instance),
          ),
        ),
        addSupplierUseCase: AddSupplier(
          SupplierRepositoryImpl(
            SupplierDataSource(FirebaseFirestore.instance),
          ),
        ),
        updateSupplierUseCase: UpdateSupplier(
          SupplierRepositoryImpl(
            SupplierDataSource(FirebaseFirestore.instance),
          ),
        ),
        deleteSupplierUseCase: DeleteSupplier(
          SupplierRepositoryImpl(
            SupplierDataSource(FirebaseFirestore.instance),
          ),
        ),
      ),
      child: AddSupplierScreen(
        supplier: args['supplier'] as SupplierEntity?,
        isEdit: args['isEdit'] as bool? ?? false,
      ),
    );
  },
  //-------------------
  Routes.shipments: (context) => BlocProvider(
    create: (context) => ShipmentsCubit(
      getShipmentsUseCase: GetShipments(
        ShipmentRepositoryImpl(ShipmentDataSource(FirebaseFirestore.instance)),
      ),
      addShipmentUseCase: AddShipment(
        ShipmentRepositoryImpl(ShipmentDataSource(FirebaseFirestore.instance)),
      ),
      updateShipmentUseCase: UpdateShipment(
        ShipmentRepositoryImpl(ShipmentDataSource(FirebaseFirestore.instance)),
      ),
      deleteShipmentUseCase: DeleteShipment(
        ShipmentRepositoryImpl(ShipmentDataSource(FirebaseFirestore.instance)),
      ),
      addTransaction: AddVaultTransaction(VaultRepositoryImpl()), //!,
    )..loadShipments(),
    child: const ShipmentsScreen(),
  ),
  //-------------add shipment screen
  Routes.addShipment: (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    return BlocProvider(
      create: (context) => ShipmentsCubit(
        getShipmentsUseCase: GetShipments(
          ShipmentRepositoryImpl(
            ShipmentDataSource(FirebaseFirestore.instance),
          ),
        ),
        addShipmentUseCase: AddShipment(
          ShipmentRepositoryImpl(
            ShipmentDataSource(FirebaseFirestore.instance),
          ),
        ),
        updateShipmentUseCase: UpdateShipment(
          ShipmentRepositoryImpl(
            ShipmentDataSource(FirebaseFirestore.instance),
          ),
        ),
        deleteShipmentUseCase: DeleteShipment(
          ShipmentRepositoryImpl(
            ShipmentDataSource(FirebaseFirestore.instance),
          ),
        ),
        addTransaction: AddVaultTransaction(VaultRepositoryImpl()), //!
      ),
      child: AddShipmentScreen(
        shipment: args['shipment'] as ShipmentEntity?,
        isEdit: args['isEdit'] as bool? ?? false,
      ),
    );
  },

  //-------------
  Routes.vault: (context) => BlocProvider(
    create: (context) => VaultCubit(),
    child: const VaultTransactionsScreen(),
  ),
  //-------------
  Routes.addVaultTransaction: (context) => BlocProvider(
    create: (context) => VaultCubit(),
    child: const AddTransactionScreen(),
  ),
  //-------------
  Routes.employeeList: (context) => BlocProvider(
    create: (context) => EmployeeManagementCubit(),
    child: const EmployeeListScreen(),
  ),
  //-------------
  Routes.addEmployee: (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    return BlocProvider(
      create: (context) => EmployeeManagementCubit(),
      child: AddEmployeeScreen(
        employee: args['employee'] as Employee?,
        isEdit: args['isEdit'] as bool? ?? false,
      ),
    );
  },
  //-------------
  Routes.employeeProfile: (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    return BlocProvider(
      create: (context) => EmployeeManagementCubit(),
      child: EmployeeProfileScreen(
        employeeId: args['employeeID'] ?? "id error",
        fullName: args['fullName'] ?? "unknown",
      ),
    );
  },
  //-------------
  Routes.weeklyAttendanceTable: (context) => BlocProvider(
    create: (context) => AttendanceCubit(),
    child: const WeeklyAttendanceTableScreen(),
  ),
  //-------------
  Routes.employeeAttendance: (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    return BlocProvider(
      create: (context) => AttendanceCubit(),
      child: EmployeeAttendanceScreen(employee: args['employee']),
    );
  },
  //-------------
  Routes.manageAttendance: (context) => BlocProvider(
    create: (context) => AttendanceCubit(),
    child: const SupervisorAttendanceScreen(),
  ),
  //-------------
  Routes.reports: (context) => BlocProvider(
    create: (context) => ReportsCubit()..loadReports(),
    child: const ReportsScreen(),
  ),
  //-------------
  Routes.salesReport: (context) => BlocProvider(
    create: (context) => SalesReportCubit(),
    child: const SalesReportScreen(),
  ),
  //-------------
  Routes.transactionsReport: (context) => BlocProvider(
    create: (context) => TransactionSummaryCubit(),
    child: const TransactionSummaryScreen(),
  ),
  //-------------
  Routes.revenueExpenseReport: (context) => BlocProvider(
    create: (context) => RevenueExpenseCubit(),
    child: const RevenueExpenseScreen(),
  ),
  //-------------
  Routes.profitabilityReport: (context) => BlocProvider(
    create: (context) => ItemProfitabilityCubit(),
    child: const ItemProfitabilityScreen(),
  ),
  //-------------
  Routes.visitor: (context) => BlocProvider(
    create: (context) => ClientScreenCubit(
      submitReservation: SubmitReservation(
        ReservationRepositoryImpl(ReservationDataSource()),
      ),
    ),
    child: const ClientsScreen(),
  ),
};
