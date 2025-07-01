import 'package:dio/dio.dart';
import '../global/dio.dart';
import '../config/debug/debug.dart';
import '../model/coach.dart';
import '../config/exceptions/coach.dart';

class CoachService {
  static final CoachService _instance = CoachService._internal();
  factory CoachService() => _instance;
  CoachService._internal();

  final DioClient _dioClient = DioClient();

  /// Create a new coach
  Future<Coach> createCoach({
    required String name,
    required String userId,
    required String email,
    required String coachingSpecialty,
    required int experienceYears,
    String? phone,
    String? profilePicture,
    List<String>? certifications,
    List<String>? students,
  }) async {
    try {
      Debug.api('Creating coach for userId: $userId');
      if (name.trim().isEmpty) {
        throw CoachException('Name cannot be empty');
      }
      if (userId.trim().isEmpty) {
        throw CoachException('User ID cannot be empty');
      }
      if (email.trim().isEmpty) {
        throw CoachException('Email cannot be empty');
      }
      if (coachingSpecialty.trim().isEmpty) {
        throw CoachException('Coaching specialty cannot be empty');
      }
      if (experienceYears < 0) {
        throw CoachException('Experience years must be non-negative');
      }

      final Map<String, dynamic> coachData = {
        'name': name,
        'userId': userId,
        'email': email,
        'coachingSpecialty': coachingSpecialty,
        'experienceYears': experienceYears,
        'phone': phone,
        'profilePicture': profilePicture,
        'certifications': certifications ?? [],
        'students': students ?? [],
      };
      Debug.info('Coach data: $coachData');
      final response = await _dioClient.post('/app/c/coaches', data: coachData);

      if (response.statusCode == 201) {
        Debug.success('Coach created successfully');
        return Coach.fromJson(response.data);
      } else {
        Debug.error(
            'Coach creation failed with status: ${response.statusCode}');
        throw CoachException('Failed to create coach');
      }
    } on DioException catch (e) {
      Debug.error('Coach creation API error: ${e.response?.data ?? e.message}');
      throw CoachException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected coach creation error: $e');
      throw CoachException('An unexpected error occurred while creating coach');
    }
  }

  /// Get all coaches
  Future<List<Coach>> getAllCoaches() async {
    try {
      Debug.api('Fetching all coaches');

      final response = await _dioClient.get('/app/c/coaches');

      if (response.statusCode == 200) {
        Debug.success('Coaches retrieved successfully');
        final List<dynamic> coachesData = response.data;
        return coachesData.map((data) => Coach.fromJson(data)).toList();
      } else {
        Debug.error('Get coaches failed with status: ${response.statusCode}');
        throw CoachException('Failed to fetch coaches');
      }
    } on DioException catch (e) {
      Debug.error('Get coaches API error: ${e.response?.data ?? e.message}');
      throw CoachException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected get coaches error: $e');
      throw CoachException(
          'An unexpected error occurred while fetching coaches');
    }
  }

  /// Get coach by ID
  Future<Coach> getCoachById(String coachId) async {
    try {
      Debug.api('Fetching coach by ID: $coachId');

      final response = await _dioClient.get('/app/c/coaches/$coachId');

      if (response.statusCode == 200) {
        Debug.success('Coach retrieved successfully');
        return Coach.fromJson(response.data);
      } else {
        Debug.error('Get coach failed with status: ${response.statusCode}');
        throw CoachException('Coach not found');
      }
    } on DioException catch (e) {
      Debug.error('Get coach API error: ${e.response?.data ?? e.message}');
      throw CoachException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected get coach error: $e');
      throw CoachException('An unexpected error occurred while fetching coach');
    }
  }

  /// Get coach by user ID
  Future<Coach?> getCoachByUserId(String userId) async {
    try {
      Debug.api('Fetching coach by userId: $userId');

      // Get all coaches and filter by userId
      final coaches = await getAllCoaches();
      final coach = coaches.where((c) => c.userId == userId).firstOrNull;

      if (coach != null) {
        Debug.success('Coach found for userId: $userId');
      } else {
        Debug.info('No coach found for userId: $userId');
      }

      return coach;
    } catch (e) {
      Debug.error('Error getting coach by userId: $e');
      throw CoachException('Failed to fetch coach by user ID');
    }
  }

  /// Update coach
  Future<Coach> updateCoach({
    required String coachId,
    String? name,
    String? email,
    String? phone,
    String? profilePicture,
    String? coachingSpecialty,
    int? experienceYears,
    List<String>? certifications,
    List<String>? students,
  }) async {
    try {
      Debug.api('Updating coach: $coachId');

      final Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (profilePicture != null) updateData['profilePicture'] = profilePicture;
      if (coachingSpecialty != null)
        updateData['coachingSpecialty'] = coachingSpecialty;
      if (experienceYears != null)
        updateData['experienceYears'] = experienceYears;
      if (certifications != null) updateData['certifications'] = certifications;
      if (students != null) updateData['students'] = students;

      final response =
          await _dioClient.put('/app/c/coaches/$coachId', data: updateData);

      if (response.statusCode == 200) {
        Debug.success('Coach updated successfully');
        return Coach.fromJson(response.data);
      } else {
        Debug.error('Coach update failed with status: ${response.statusCode}');
        throw CoachException('Failed to update coach');
      }
    } on DioException catch (e) {
      Debug.error('Coach update API error: ${e.response?.data ?? e.message}');
      throw CoachException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected coach update error: $e');
      throw CoachException('An unexpected error occurred while updating coach');
    }
  }

  /// Delete coach
  Future<void> deleteCoach(String coachId) async {
    try {
      Debug.api('Deleting coach: $coachId');

      final response = await _dioClient.delete('/app/c/coaches/$coachId');

      if (response.statusCode == 200) {
        Debug.success('Coach deleted successfully');
      } else {
        Debug.error(
            'Coach deletion failed with status: ${response.statusCode}');
        throw CoachException('Failed to delete coach');
      }
    } on DioException catch (e) {
      Debug.error('Coach deletion API error: ${e.response?.data ?? e.message}');
      throw CoachException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected coach deletion error: $e');
      throw CoachException('An unexpected error occurred while deleting coach');
    }
  }

  /// Add certification to coach
  Future<Coach> addCertification(String coachId, String certification) async {
    try {
      final coach = await getCoachById(coachId);
      final updatedCertifications = [...coach.certifications, certification];

      return await updateCoach(
        coachId: coachId,
        certifications: updatedCertifications,
      );
    } catch (e) {
      Debug.error('Error adding certification: $e');
      throw CoachException('Failed to add certification');
    }
  }

  /// Remove certification from coach
  Future<Coach> removeCertification(
      String coachId, String certification) async {
    try {
      final coach = await getCoachById(coachId);
      final updatedCertifications =
          coach.certifications.where((c) => c != certification).toList();

      return await updateCoach(
        coachId: coachId,
        certifications: updatedCertifications,
      );
    } catch (e) {
      Debug.error('Error removing certification: $e');
      throw CoachException('Failed to remove certification');
    }
  }

  /// Add student to coach
  Future<Coach> addStudent(String coachId, String studentId) async {
    try {
      final coach = await getCoachById(coachId);
      if (coach.students.contains(studentId)) {
        throw CoachException('Student is already assigned to this coach');
      }

      final updatedStudents = [...coach.students, studentId];

      return await updateCoach(
        coachId: coachId,
        students: updatedStudents,
      );
    } catch (e) {
      Debug.error('Error adding student: $e');
      throw CoachException('Failed to add student');
    }
  }

  /// Remove student from coach
  Future<Coach> removeStudent(String coachId, String studentId) async {
    try {
      final coach = await getCoachById(coachId);
      final updatedStudents =
          coach.students.where((s) => s != studentId).toList();

      return await updateCoach(
        coachId: coachId,
        students: updatedStudents,
      );
    } catch (e) {
      Debug.error('Error removing student: $e');
      throw CoachException('Failed to remove student');
    }
  }

  /// Get coaches by specialty
  Future<List<Coach>> getCoachesBySpecialty(String specialty) async {
    try {
      Debug.api('Fetching coaches by specialty: $specialty');

      final coaches = await getAllCoaches();
      final filteredCoaches = coaches
          .where((coach) => coach.coachingSpecialty
              .toLowerCase()
              .contains(specialty.toLowerCase()))
          .toList();

      Debug.success(
          'Found ${filteredCoaches.length} coaches with specialty: $specialty');
      return filteredCoaches;
    } catch (e) {
      Debug.error('Error getting coaches by specialty: $e');
      throw CoachException('Failed to fetch coaches by specialty');
    }
  }

  /// Get coaches by experience level
  Future<List<Coach>> getCoachesByExperience({
    int? minYears,
    int? maxYears,
  }) async {
    try {
      Debug.api('Fetching coaches by experience: min=$minYears, max=$maxYears');

      final coaches = await getAllCoaches();
      var filteredCoaches = coaches;

      if (minYears != null) {
        filteredCoaches = filteredCoaches
            .where((coach) => coach.experienceYears >= minYears)
            .toList();
      }

      if (maxYears != null) {
        filteredCoaches = filteredCoaches
            .where((coach) => coach.experienceYears <= maxYears)
            .toList();
      }

      Debug.success(
          'Found ${filteredCoaches.length} coaches with specified experience');
      return filteredCoaches;
    } catch (e) {
      Debug.error('Error getting coaches by experience: $e');
      throw CoachException('Failed to fetch coaches by experience');
    }
  }

  /// Get coach statistics
  Future<Map<String, dynamic>> getCoachStats(String coachId) async {
    try {
      final coach = await getCoachById(coachId);

      return {
        'totalStudents': coach.students.length,
        'totalCertifications': coach.certifications.length,
        'experienceYears': coach.experienceYears,
        'specialty': coach.coachingSpecialty,
        'joinDate': coach.createdAt?.toIso8601String(),
      };
    } catch (e) {
      Debug.error('Error getting coach stats: $e');
      throw CoachException('Failed to fetch coach statistics');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final message = e.response?.data['message'] ??
            e.response?.data['errors']?.join(', ') ??
            'Unknown error occurred';
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
