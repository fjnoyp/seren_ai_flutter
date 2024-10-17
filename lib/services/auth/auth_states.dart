import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

sealed class AppAuthState {}

class InitialAuthState extends AppAuthState {}

class LoadingAuthState extends AppAuthState {}

class LoggedInAuthState extends AppAuthState {
  final UserModel user;

  LoggedInAuthState(this.user);
}

class LoggedOutAuthState extends AppAuthState {}

class ErrorAuthState extends AppAuthState {
  final String error;

  ErrorAuthState({required this.error});
}
