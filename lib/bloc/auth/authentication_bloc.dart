import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../services/authentication_service.dart';
import '../../config/debug/debug.dart';
import '../../model/auth.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationService _authService;

  AuthenticationBloc({AuthenticationService? authService})
      : _authService = authService ?? AuthenticationService(),
        super(AuthenticationInitial()) {
    
    on<RegisterUserEvent>(_onRegisterUser);
    on<VerifyUserEvent>(_onVerifyUser);
    on<LoginUserEvent>(_onLoginUser);
    on<GetUserProfileEvent>(_onGetUserProfile);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<ResendOtpEvent>(_onResendOtp); 
  }

  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    
    try {
      Debug.info('Resending OTP to ${event.email}');
      
      final response = await _authService.resendOtp(email: event.email);
      
      Debug.success('OTP resent successfully');
      emit(OtpResentSuccess(
        message: response.message,
      ));
    } catch (e) {
      Debug.error('Failed to resend OTP: $e');
      emit(AuthenticationError(message: e.toString()));
    }
  }
  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    
    try {
      Debug.info('Starting user registration process');
      
      final response = await _authService.registerUser(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
        phone: event.phone,
      );

      Debug.success('Registration successful');
      emit(RegistrationSuccess(
        message: response.message,
        info: response.info,
      ));
    } catch (e) {
      Debug.error('Registration failed: $e');
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onVerifyUser(
    VerifyUserEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    
    try {
      Debug.info('Starting user verification process');
      
      final response = await _authService.verifyUser(
        email: event.email,
        otp: event.otp,
      );

      if (response.user != null && response.token != null) {
        Debug.success('Verification successful - user authenticated');
        emit(VerificationSuccess(
          message: response.message,
          user: response.user!,
          token: response.token!,
        ));
        
        // Update to authenticated state
        emit(AuthenticationAuthenticated(
          user: response.user!,
          token: response.token!,
        ));
      } else {
        Debug.warning('Verification successful but missing user data or token');
        emit(AuthenticationError(message: 'Verification incomplete'));
      }
    } catch (e) {
      Debug.error('Verification failed: $e');
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    
    try {
      Debug.info('Starting user login process');
      
      final response = await _authService.loginUser(
        email: event.email,
        password: event.password,
      );

      if (response.user != null && response.token != null) {
        Debug.success('Login successful');
        emit(LoginSuccess(
          message: response.message,
          user: response.user!,
          token: response.token!,
        ));
        
        if (response.user!.isVerified) {
          Debug.info('User is verified, updating authentication state');
          emit(AuthenticationAuthenticated(
          user: response.user!,
          token: response.token!,
        ));
        } else {
          Debug.warning('User is not verified, prompting for verification');
          emit(LoginSuccess(
            message: response.message,
            user: response.user!,
            token: response.token!,
          ));
        }  
      } else {
        Debug.warning('Login successful but missing user data or token');
        emit(AuthenticationError(message: 'Login incomplete'));
      }
    } catch (e) {
      Debug.error('Login failed: $e');
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onGetUserProfile(
    GetUserProfileEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    
    try {
      Debug.info('Fetching user profile');
      
      final response = await _authService.getUserProfile();
      
      Debug.success('Profile loaded successfully');
      emit(ProfileLoaded(user: response.user));
    } catch (e) {
      Debug.error('Failed to load profile: $e');
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      Debug.info('Logging out user');
      
      _authService.logout();
      
      Debug.success('Logout successful');
      emit(LogoutSuccess());
      emit(AuthenticationUnauthenticated());
    } catch (e) {
      Debug.error('Logout failed: $e');
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    Debug.info('Checking authentication status');
    
    // Here you would typically check stored tokens/credentials
    // For now, we'll emit unauthenticated
    emit(AuthenticationUnauthenticated());
  }
}