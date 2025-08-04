import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> initialize() async {
    emit(SplashLoading());
    // Simulate a delay for the splash screen (e.g., 3 seconds)
    await Future.delayed(Duration(seconds: 3));
    emit(SplashCompleted());
  }
}
