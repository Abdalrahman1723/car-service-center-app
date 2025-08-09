import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/auth/login/presentation/pages/login_screen.dart';
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
import 'package:m_world/modules/manager/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/pages/inventory_panel.dart';
import 'package:m_world/modules/manager/features/manage_clients/presentation/pages/client_list_screen.dart';
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

class Routes {
  static const String splash = "/"; //?initial route
  static const String login = '/LoginScreen';
  static const String adminDashboard = '/DashboardScreen';
  static const String inventoryPanel = '/InventoryPanel';
  static const String clientManagement = '/ClientManagementScreen';
  static const String clientList = '/ClientListScreen';
  static const String invoiceAdd = '/InvoiceAddScreen';
  static const String invoiceList = '/InvoiceListScreen';
  static const String invoiceDraftList = '/InvoiceDraftListScreen';
  static const String suppliers = '/SuppliersPage';
  static const String addSupplier = '/AddSupplierPage';
  static const String shipments = '/ShipmentsPage';
  static const String addShipment = '/AddShipmentPage';
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
    child: InvoiceAddScreen(
      draftData:
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?,
    ),
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
  Routes.invoiceDraftList: (context) => const InvoiceDraftListScreen(),

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
    )..loadShipments(),
    child: const ShipmentsScreen(),
  ),
  //-------------add shipment screen
  Routes.addShipment: (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    log('${args['shipment'] as ShipmentEntity?}');
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
      ),
      child: AddShipmentScreen(
        shipment: args['shipment'] as ShipmentEntity?,
        isEdit: args['isEdit'] as bool? ?? false,
      ),
    );
  },
};
