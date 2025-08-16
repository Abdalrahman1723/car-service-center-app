import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/config/themes/theme.dart';
import 'package:m_world/modules/manager/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:m_world/modules/manager/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardCubit(FirebaseDashboardRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar', 'EG'), // Set Arabic locale
        theme: carServiceTheme(),
        initialRoute: '/',
        routes: routes, //using routes instead of home
        // Add RTL support and device preview
        builder: (context, child) {
          final devicePreviewChild = DevicePreview.appBuilder(context, child);
          return Directionality(
            textDirection: TextDirection.rtl,
            child: devicePreviewChild,
          );
        },
      ),
    );
  }
}
