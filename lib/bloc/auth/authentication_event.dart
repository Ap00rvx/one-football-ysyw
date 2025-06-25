part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

class RegisterUserEvent extends AuthenticationEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  final String phone;

  RegisterUserEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.phone,
  });
}

class VerifyUserEvent extends AuthenticationEvent {
  final String email;
  final String otp;

  VerifyUserEvent({
    required this.email,
    required this.otp,
  });
}

class LoginUserEvent extends AuthenticationEvent {
  final String email;
  final String password;

  LoginUserEvent({
    required this.email,
    required this.password,
  });
}

class GetUserProfileEvent extends AuthenticationEvent {
  final String userId;

  GetUserProfileEvent({required this.userId});
}

class LogoutEvent extends AuthenticationEvent {}

class CheckAuthStatusEvent extends AuthenticationEvent {}