import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/config/themes/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: carServiceTheme(),
      initialRoute: '/',
      routes: routes, //using routes instead of home
    );
  }
}
