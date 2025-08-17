import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/services/auth_service.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final AuthService _authService = AuthService();

  SplashCubit() : super(SplashInitial());

  Future<void> initialize() async {
    emit(SplashLoading());

    // Check if user is already logged in
    if (_authService.isLoggedIn) {
      final user = _authService.currentUser;
      if (user != null) {
        try {
          final role = await _authService.getUserRole(user.uid);
          if (role != null) {
            emit(SplashCompletedWithRole(role));
            return;
          }
        } catch (e) {
          log('Error getting user role: $e');
        }
      }
    }

    // If not logged in or role not found, go to login
    await Future.delayed(Duration(seconds: 2));
    emit(SplashCompleted());
  }
}
