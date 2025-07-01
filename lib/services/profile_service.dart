import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ysyw/global/dio.dart';
import 'package:ysyw/model/profile.dart';
import 'package:ysyw/services/local_storage_service.dart';
import '../config/debug/debug.dart';

class ProfileService {
  final DioClient _client = DioClient();
  String endpoint = "/app/user/profile";
  String updateProfileEndpoint = "/app/user/update-profile";

  Future<Either<String, ProfileResponse>> getProfile() async {
    try {
      final userId = await LocalStorageService().getUserId();
      Debug.api('ProfileService: Fetching user profile for ID: $userId');
      if (userId == "") {
        return const Left("User ID not found");
      }
      Debug.api('ProfileService: Making GET request to $endpoint/$userId');
      final response = await _client.get("$endpoint/$userId");
      Debug.info(
          'ProfileService: Fetching user profile for ID: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        final profileResponse = ProfileResponse.fromJson(data);
        return Right(profileResponse);
      } else {
        return Left("Failed to fetch profile: ${response.statusMessage}");
      }
    } catch (e) {
      return Left("Error fetching profile: $e");
    }
  }

  /// Update user profile with role-specific data
  Future<Either<String, ProfileResponse>> updateProfile({
    // Common user fields
    String? name,
    String? phone,
    String? profilePicture,

    // Coach-specific fields
    String? coachingSpecialty,
    int? experienceYears,
    List<String>? certifications,

    // Student-specific fields
    String? jerseyNumber,
    double? height,
    double? weight,
    DateTime? dob,
    List<String>? highLights,
  }) async {
    try {
      Debug.api('ProfileService: Updating user profile');

      final userId = await LocalStorageService().getUserId();
      if (userId == null) {
        return const Left("User ID not found");
      }

      // Build request body with only non-null values
      Map<String, dynamic> requestBody = {};

      // Common fields
      if (name != null && name.isNotEmpty) requestBody['name'] = name.trim();
      if (phone != null && phone.isNotEmpty)
        requestBody['phone'] = phone.trim();

      // Coach-specific fields
      if (coachingSpecialty != null && coachingSpecialty.isNotEmpty) {
        requestBody['coachingSpecialty'] = coachingSpecialty.trim();
      }
      if (experienceYears != null && experienceYears >= 0) {
        requestBody['experienceYears'] = experienceYears;
      }
      if (certifications != null) {
        requestBody['certifications'] = certifications;
      }

      // Student-specific fields
      if (jerseyNumber != null && jerseyNumber.isNotEmpty) {
        requestBody['jerseyNumber'] = jerseyNumber.trim();
      }
      if (height != null && height > 0) {
        requestBody['height'] = height;
      }
      if (weight != null && weight > 0) {
        requestBody['weight'] = weight;
      }
      if (dob != null) {
        requestBody['dob'] = dob.toIso8601String();
      }
      if (highLights != null) {
        requestBody['highLights'] = highLights;
      }

      Debug.api('ProfileService: Request body - $requestBody');
      Debug.api(
          'ProfileService: Making PUT request to $updateProfileEndpoint/$userId');
      final dio = Dio();
      final response = await dio.put(
          "https://api.yoursportyourworld.com$updateProfileEndpoint/$userId",
          data: requestBody,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ));
      Debug.info(
          'ProfileService: Update response for ID $userId: ${response.data}');

      if (response.statusCode == 200) {
        Debug.success('ProfileService: Profile updated successfully');

        // Fetch the updated profile to return complete data
        final updatedProfile = await getProfile();
        return updatedProfile;
      } else {
        Debug.error(
            'ProfileService: Update failed with status ${response.statusCode}');
        return Left("Failed to update profile: ${response.statusMessage}");
      }
    } catch (e) {
      Debug.error('ProfileService: Update error - $e');
      return Left("Error updating profile: $e");
    }
  }

  /// Delete user profile picture
  /// This method will remove the profile picture from the user's profile
  Future<Either<String, ProfileResponse>> deleteProfilePicture() async {
    try {
      final userId = await LocalStorageService().getUserId();
      if (userId == null) {
        return const Left("User ID not found");
      }

      Debug.api(
          'ProfileService: Deleting profile picture for user ID: $userId');
      final dio = Dio();

      final response = await dio.put(
          "https://api.yoursportyourworld.com$updateProfileEndpoint/$userId",
          data: {
            'profilePicture': null,
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ));
      if (response.statusCode == 200) {
        Debug.success('ProfileService: Profile picture deleted successfully');
        final updatedProfile = await getProfile();
        return updatedProfile;
      }
      Debug.error(
          'ProfileService: Delete profile picture failed with status ${response.statusCode}');
      return Left("Failed to delete profile picture: ${response.statusMessage}");
    } catch (e) {
      return Left("Error deleting profile picture: $e");
    }
  }

  /// Update only basic user information (name, phone, profilePicture)
  Future<Either<String, ProfileResponse>> updateBasicProfile({
    String? name,
    String? phone,
    String? profilePicture,
  }) async {
    return updateProfile(
      name: name,
      phone: phone,
      profilePicture: profilePicture,
    );
  }

  /// Update coach-specific profile information
  Future<Either<String, ProfileResponse>> updateCoachProfile({
    String? name,
    String? phone,
    String? profilePicture,
    String? coachingSpecialty,
    int? experienceYears,
    List<String>? certifications,
  }) async {
    return updateProfile(
      name: name,
      phone: phone,
      profilePicture: profilePicture,
      coachingSpecialty: coachingSpecialty,
      experienceYears: experienceYears,
      certifications: certifications,
    );
  }

  /// Update student-specific profile information
  Future<Either<String, ProfileResponse>> updateStudentProfile({
    String? name,
    String? phone,
    String? profilePicture,
    String? jerseyNumber,
    double? height,
    double? weight,
    DateTime? dob,
    List<String>? highLights,
  }) async {
    return updateProfile(
      name: name,
      phone: phone,
      profilePicture: profilePicture,
      jerseyNumber: jerseyNumber,
      height: height,
      weight: weight,
      dob: dob,
      highLights: highLights,
    );
  }

  /// Add a certification to coach profile
  Future<Either<String, ProfileResponse>> addCertification(
      String certification) async {
    try {
      // First get current profile to get existing certifications
      final currentProfileResult = await getProfile();

      return currentProfileResult.fold(
        (error) => Left(error),
        (profile) async {
          if (profile.roleProfile is CoachProfile) {
            final coachProfile = profile.roleProfile as CoachProfile;
            final updatedCertifications = [...coachProfile.certifications];

            if (!updatedCertifications.contains(certification)) {
              updatedCertifications.add(certification);
              return updateCoachProfile(certifications: updatedCertifications);
            } else {
              return const Left("Certification already exists");
            }
          } else {
            return const Left("User is not a coach");
          }
        },
      );
    } catch (e) {
      return Left("Error adding certification: $e");
    }
  }

  /// Remove a certification from coach profile
  Future<Either<String, ProfileResponse>> removeCertification(
      String certification) async {
    try {
      final currentProfileResult = await getProfile();

      return currentProfileResult.fold(
        (error) => Left(error),
        (profile) async {
          if (profile.roleProfile is CoachProfile) {
            final coachProfile = profile.roleProfile as CoachProfile;
            final updatedCertifications = coachProfile.certifications
                .where((cert) => cert != certification)
                .toList();

            return updateCoachProfile(certifications: updatedCertifications);
          } else {
            return const Left("User is not a coach");
          }
        },
      );
    } catch (e) {
      return Left("Error removing certification: $e");
    }
  }

  /// Add a highlight to student profile
  Future<Either<String, ProfileResponse>> addHighlight(String highlight) async {
    try {
      final currentProfileResult = await getProfile();

      return currentProfileResult.fold(
        (error) => Left(error),
        (profile) async {
          if (profile.roleProfile is StudentProfile) {
            final studentProfile = profile.roleProfile as StudentProfile;
            final updatedHighlights = [...studentProfile.highLights];

            if (!updatedHighlights.contains(highlight)) {
              updatedHighlights.add(highlight);
              return updateStudentProfile(highLights: updatedHighlights);
            } else {
              return const Left("Highlight already exists");
            }
          } else {
            return const Left("User is not a student");
          }
        },
      );
    } catch (e) {
      return Left("Error adding highlight: $e");
    }
  }

  /// Remove a highlight from student profile
  Future<Either<String, ProfileResponse>> removeHighlight(
      String highlight) async {
    try {
      final currentProfileResult = await getProfile();

      return currentProfileResult.fold(
        (error) => Left(error),
        (profile) async {
          if (profile.roleProfile is StudentProfile) {
            final studentProfile = profile.roleProfile as StudentProfile;
            final updatedHighlights = studentProfile.highLights
                .where((hl) => hl != highlight)
                .toList();

            return updateStudentProfile(highLights: updatedHighlights);
          } else {
            return const Left("User is not a student");
          }
        },
      );
    } catch (e) {
      return Left("Error removing highlight: $e");
    }
  }

  /// Check if user has completed their role profile
  Future<Either<String, bool>> hasCompleteRoleProfile() async {
    final profileResult = await getProfile();

    return profileResult.fold(
      (error) => Left(error),
      (profile) {
        if (profile.roleProfile == null) {
          return const Right(false);
        }

        // Check if essential fields are filled based on role
        if (profile.user?.role == 'student') {
          final studentProfile = profile.roleProfile as StudentProfile?;
          if (studentProfile != null) {
            return Right(studentProfile.jerseyNumber.isNotEmpty &&
                studentProfile.height > 0 &&
                studentProfile.weight > 0);
          }
        } else if (profile.user?.role == 'coach') {
          final coachProfile = profile.roleProfile as CoachProfile?;
          if (coachProfile != null) {
            return Right(coachProfile.coachingSpecialty.isNotEmpty &&
                coachProfile.experienceYears >= 0);
          }
        }

        return const Right(false);
      },
    );
  }

  /// Get user role from profile
  Future<Either<String, String>> getUserRole() async {
    final profileResult = await getProfile();

    return profileResult.fold(
      (error) => Left(error),
      (profile) {
        if (profile.user?.role != null) {
          return Right(profile.user!.role);
        } else {
          return const Left("User role not found");
        }
      },
    );
  }
}
