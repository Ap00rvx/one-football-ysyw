import 'package:ysyw/model/auth.dart';
import 'package:ysyw/model/student.dart';
import 'package:ysyw/model/coach.dart';

class ProfileResponse {
  final String message;
  final User? user;
  final RoleProfile? roleProfile;
  
  ProfileResponse({
    required this.message,
    this.user,
    this.roleProfile,
  });
  
  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    RoleProfile? roleProfile;
    
    if (json['roleProfile'] != null) {
      final roleData = json['roleProfile'];
      final user = json['user'];
      
      if (user != null && user['role'] != null) {
        switch (user['role']) {
          case 'student':
            roleProfile = StudentProfile.fromJson(roleData);
            break;
          case 'coach':
            roleProfile = CoachProfile.fromJson(roleData);
            break;
          default:
            roleProfile = RoleProfile.fromJson(roleData);
        }
      } else {
        roleProfile = RoleProfile.fromJson(roleData);
      }
    }
    
    return ProfileResponse(
      message: json['message'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      roleProfile: roleProfile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user?.toJson(),
      'roleProfile': roleProfile?.toJson(),
    };
  }
}

// Base RoleProfile class
class RoleProfile {
  final String? id;
  final String name;
  final String userId;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoleProfile({
    this.id,
    required this.name,
    required this.userId,
    required this.email,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleProfile.fromJson(Map<String, dynamic> json) {
    return RoleProfile(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'userId': userId,
      'email': email,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

// Student Profile extending RoleProfile
class StudentProfile extends RoleProfile {
  final List<String> highLights;
  final List<PerformanceMetric> metrics;
  final DateTime dob;
  final String jerseyNumber;
  final double height;
  final double weight;

  StudentProfile({
    super.id,
    required super.name,
    required super.userId,
    required super.email,
    super.createdAt,
    super.updatedAt,
    required this.highLights,
    required this.metrics,
    required this.dob,
    required this.jerseyNumber,
    required this.height,
    required this.weight,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      highLights: List<String>.from(json['highLights'] ?? []),
      metrics: (json['metrics'] as List<dynamic>? ?? [])
          .map((metric) => PerformanceMetric.fromJson(metric))
          .toList(),
      dob: DateTime.parse(json['dob']),
      jerseyNumber: json['jerseyNumber'] ?? '',
      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson.addAll({
      'highLights': highLights,
      'metrics': metrics.map((metric) => metric.toJson()).toList(),
      'dob': dob.toIso8601String(),
      'jerseyNumber': jerseyNumber,
      'height': height,
      'weight': weight,
    });
    return baseJson;
  }
}

// Coach Profile extending RoleProfile
class CoachProfile extends RoleProfile {
  final String? phone;
  final String? profilePicture;
  final String coachingSpecialty;
  final int experienceYears;
  final List<String> certifications;
  final List<String> students;

  CoachProfile({
    super.id,
    required super.name,
    required super.userId,
    required super.email,
    super.createdAt,
    super.updatedAt,
    this.phone,
    this.profilePicture,
    required this.coachingSpecialty,
    required this.experienceYears,
    required this.certifications,
    required this.students,
  });

  factory CoachProfile.fromJson(Map<String, dynamic> json) {
    return CoachProfile(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      phone: json['phone'],
      profilePicture: json['profilePicture'],
      coachingSpecialty: json['coachingSpecialty'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      certifications: List<String>.from(json['certifications'] ?? []),
      students: List<String>.from(json['students'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson.addAll({
      if (phone != null) 'phone': phone,
      if (profilePicture != null) 'profilePicture': profilePicture,
      'coachingSpecialty': coachingSpecialty,
      'experienceYears': experienceYears,
      'certifications': certifications,
      'students': students,
    });
    return baseJson;
  }
}

// Performance Metric model for students
class PerformanceMetric {
  final String metricType;
  final double value;
  final DateTime recordedAt;

  PerformanceMetric({
    required this.metricType,
    required this.value,
    required this.recordedAt,
  });

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      metricType: json['metricType'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      recordedAt: json['recordedAt'] != null 
          ? DateTime.parse(json['recordedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metricType': metricType,
      'value': value,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }
}