import 'package:m_world/modules/auth/login/presentation/pages/login_screen.dart';
import 'package:m_world/modules/manager/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:m_world/shared/splash/splash_screen.dart';

class Routes {
  static const String splash = "/"; //?initial route
  static const String login = '/LoginScreen';
  static const String adminDashboard = '/DashboardScreen';
}

final routes = {
  Routes.splash: (context) => const SplashScreen(),
  Routes.login: (context) => const LoginScreen(),
  Routes.adminDashboard: (context) => const DashboardScreen(),
};
