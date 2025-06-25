import 'package:dio/dio.dart';
import 'package:ysyw/config/exceptions/auth.dart';
import '../global/dio.dart';
import '../config/debug/debug.dart';
import '../model/auth.dart';

class AuthenticationService {
  static final AuthenticationService _instance = AuthenticationService._internal();
  factory AuthenticationService() => _instance;
  AuthenticationService._internal();

  final DioClient _dioClient = DioClient();

  /// Register a new user
  Future<AuthResponse> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    try {
      Debug.api('Attempting user registration for email: $email');
      
      final response = await _dioClient.post('/app/user/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'phone': phone,
      });

      if (response.statusCode == 201) {
        Debug.success('User registration successful');
        return AuthResponse.fromJson(response.data);
      } else {
        Debug.error('Registration failed with status: ${response.statusCode}');
        throw AuthException('Registration failed');
      }
    } on DioException catch (e) {
      Debug.error('Registration API error: ${e.response?.data ?? e.message}');
      throw AuthException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected registration error: $e');
      throw AuthException('An unexpected error occurred during registration');
    }
  }

  /// Verify user with OTP
  Future<AuthResponse> verifyUser({
    required String email,
    required String otp,
  }) async {
    try {
      Debug.api('Attempting user verification for email: $email');
      
      final response = await _dioClient.post('/app/user/verify', data: {
        'email': email,
        'otp': otp,
      });

      if (response.statusCode == 200) {
        Debug.success('User verification successful');
        return AuthResponse.fromJson(response.data);
      } else {
        Debug.error('Verification failed with status: ${response.statusCode}');
        throw AuthException('Verification failed');
      }
    } on DioException catch (e) {
      Debug.error('Verification API error: ${e.response?.data ?? e.message}');
      throw AuthException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected verification error: $e');
      throw AuthException('An unexpected error occurred during verification');
    }
  }

  /// Login user
  Future<AuthResponse> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      Debug.api('Attempting user login for email: $email');
      
      final response = await _dioClient.post('/app/user/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        Debug.success('User login successful');
        final authResponse = AuthResponse.fromJson(response.data);
        
        // Set authorization header for future requests
        if (authResponse.token != null) {
          _dioClient.setAuthorization(authResponse.token!);
        }
        
        return authResponse;
      } else {
        Debug.error('Login failed with status: ${response.statusCode}');
        throw AuthException('Login failed');
      }
    } on DioException catch (e) {
      Debug.error('Login API error: ${e.response?.data ?? e.message}');
      throw AuthException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected login error: $e');
      throw AuthException('An unexpected error occurred during login');
    }
  }

  /// Get user profile by ID
  Future<UserProfileResponse> getUserProfile(String userId) async {
    try {
      Debug.api('Fetching user profile for ID: $userId');
      
      final response = await _dioClient.get('/app/user/profile/$userId');

      if (response.statusCode == 200) {
        Debug.success('User profile retrieved successfully');
        return UserProfileResponse.fromJson(response.data);
      } else {
        Debug.error('Profile fetch failed with status: ${response.statusCode}');
        throw AuthException('Failed to fetch user profile');
      }
    } on DioException catch (e) {
      Debug.error('Profile API error: ${e.response?.data ?? e.message}');
      throw AuthException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected profile fetch error: $e');
      throw AuthException('An unexpected error occurred while fetching profile');
    }
  }

  void logout() {
    Debug.info('User logged out - clearing authorization');
    _dioClient.setAuthorization('');
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final message = e.response?.data['message'] ?? 'Unknown error occurred';
        return message;
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}



