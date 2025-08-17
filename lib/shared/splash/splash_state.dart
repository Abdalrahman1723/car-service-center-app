import 'package:equatable/equatable.dart';
import 'package:m_world/core/services/auth_service.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashCompleted extends SplashState {}

class SplashCompletedWithRole extends SplashState {
  final UserRole role;

  const SplashCompletedWithRole(this.role);

  @override
  List<Object?> get props => [role];
}
