import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/core/services/auth_service.dart';
import 'splash_cubit.dart';
import 'splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit()..initialize(),
      child: Scaffold(
        body: BlocListener<SplashCubit, SplashState>(
          listener: (context, state) {
            if (state is SplashCompleted) {
              Navigator.pushReplacementNamed(context, Routes.login);
            } else if (state is SplashCompletedWithRole) {
              _navigateToDashboard(context, state.role);
            }
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, Routes.adminDashboard);
        break;
      case UserRole.supervisor:
        Navigator.pushReplacementNamed(context, Routes.supervisorDashboard);
        break;
      case UserRole.inventory:
        Navigator.pushReplacementNamed(context, Routes.inventoryDashboard);
        break;
    }
  }
}
