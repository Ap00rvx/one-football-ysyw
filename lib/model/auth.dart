class AuthResponse {
  final String message;
  final String? info;
  final User? user;
  final String? token;

  AuthResponse({
    required this.message,
    this.info,
    this.user,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? '',
      info: json['info'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['token'],
    );
  }
}

/// User profile response model
class UserProfileResponse {
  final String message;
  final User user;

  UserProfileResponse({
    required this.message,
    required this.user,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      message: json['message'] ?? '',
      user: User.fromJson(json['user']),
    );
  }
}

/// User model
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final bool isVerified;
  String profilePicture; 

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.isVerified,
    this.profilePicture = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      isVerified: json['isVerified'] ?? false,
      profilePicture: json['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'isVerified': isVerified,
      'profilePicture': profilePicture,
    };
  }
}