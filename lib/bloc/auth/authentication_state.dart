part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationState {}

final class AuthenticationInitial extends AuthenticationState {}

final class AuthenticationLoading extends AuthenticationState {}

// Registration States
final class RegistrationSuccess extends AuthenticationState {
  final String message;
  final String? info;

  RegistrationSuccess({
    required this.message,
    this.info,
  });
}

// Verification States
final class VerificationSuccess extends AuthenticationState {
  final String message;
  final User user;
  final String token;

  VerificationSuccess({
    required this.message,
    required this.user,
    required this.token,
  });
}

// Login States
final class LoginSuccess extends AuthenticationState {
  final String message;
  final User user;
  final String token;

  LoginSuccess({
    required this.message,
    required this.user,
    required this.token,
  });
}

// Profile States
final class ProfileLoaded extends AuthenticationState {
  final User user;

  ProfileLoaded({required this.user});
}

// General States
final class AuthenticationAuthenticated extends AuthenticationState {
  final User user;
  final String token;

  AuthenticationAuthenticated({
    required this.user,
    required this.token,
  });
}

final class OtpResentSuccess extends AuthenticationState {
  final String message;

  OtpResentSuccess({required this.message});
}
final class AuthenticationUnauthenticated extends AuthenticationState {}

final class AuthenticationError extends AuthenticationState {
  final String message;

  AuthenticationError({required this.message});
}

final class LogoutSuccess extends AuthenticationState {}