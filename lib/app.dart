import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/config/themes/theme.dart';
import 'package:m_world/core/services/firestore_listener.dart';
import 'package:m_world/core/utils/notification_service.dart';
import 'package:m_world/modules/manager/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:m_world/modules/manager/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Start Firestore listener
    FirestoreListener().startListening();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardCubit(FirebaseDashboardRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // ✅ needed for notification taps
        locale: const Locale('ar', 'EG'), // Default Arabic
        theme: carServiceTheme(),
        initialRoute: '/',
        routes: routes,
        builder: (context, child) {
          final previewChild = DevicePreview.appBuilder(context, child);
          return Directionality(
            textDirection: TextDirection.rtl,
            child: previewChild,
          );
        },
      ),
    );
  }
}
