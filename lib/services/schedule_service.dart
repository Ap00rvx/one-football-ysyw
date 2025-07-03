import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ysyw/global/dio.dart';
import 'package:ysyw/model/schedule.dart';
import 'package:ysyw/services/local_storage_service.dart';
import '../config/debug/debug.dart';

class ScheduleService {
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();

  final DioClient _client = DioClient();
  final String _baseEndpoint = "/app/schedules";

  /// Create a new schedule (coach/admin only)
  Future<Either<String, Schedule>> createSchedule({
    required String title,
    String? description,
    required DateTime date,
    DateTime? endDate,
    required String location,
    required ScheduleType type,
    int? maxAttendees,
    String? notes,
    List<String>? attendees,
  }) async {
    try {
      Debug.api('ScheduleService: Creating new schedule');

      final userId = await LocalStorageService().getUserId();
      if (userId == null || userId.isEmpty) {
        return const Left("User ID not found");
      }
      final token = await LocalStorageService().getAuthToken();
      _client.setHeaders({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      Map<String, dynamic> requestBody = {
        'title': title.trim(),
        'date': date.toIso8601String(),
        'location': location.trim(),
        'type': type.name,
        'createdBy': userId,
      };

      if (description != null && description.trim().isNotEmpty) {
        requestBody['description'] = description.trim();
      }
      if (endDate != null) {
        requestBody['endDate'] = endDate.toIso8601String();
      }
      if (maxAttendees != null && maxAttendees > 0) {
        requestBody['maxAttendees'] = maxAttendees;
      }
      if (notes != null && notes.trim().isNotEmpty) {
        requestBody['notes'] = notes.trim();
      }
      if (attendees != null && attendees.isNotEmpty) {
        requestBody['attendees'] = attendees as String;
      }

      Debug.api('ScheduleService: Request body - $requestBody');

      final response = await _client.post(_baseEndpoint, data: requestBody);
      Debug.api('ScheduleService: Response data - ${response.data}');

      if (response.statusCode == 201) {
        Debug.success('ScheduleService: Schedule created successfully');
        return Right(Schedule.fromJson(response.data));
      } else {
        Debug.error(
            'ScheduleService: Create failed with status ${response.statusCode}');
        return Left("Failed to create schedule: ${response.statusMessage}");
      }
    } on DioException catch (dioError) {
      Debug.error('ScheduleService: Create error - ${dioError.message}');
      if (dioError.response?.statusCode == 400) {
        return Left("Invalid request data: ${dioError.response?.data}");
      } else if (dioError.response?.statusCode == 401) {
        return const Left("Unauthorized: Please log in again");
      } else if (dioError.response?.statusCode == 403) {
        return const Left(
            "Forbidden: You do not have permission to create schedules");
      }
      return Left("Error creating schedule: ${dioError.message}");
    } catch (e) {
      Debug.error('ScheduleService: Create error - $e');
      return Left("Error creating schedule: $e");
    }
  }

  /// Get all schedules (optionally filter by upcoming)
  Future<Either<String, List<Schedule>>> getAllSchedules({
    bool upcomingOnly = false,
  }) async {
    try {
      Debug.api(
          'ScheduleService: Fetching all schedules (upcoming: $upcomingOnly)');

      final queryParams = <String, dynamic>{};
      if (upcomingOnly) {
        queryParams['upcoming'] = 'true';
      }

      final response = await _client.get(
        _baseEndpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        Debug.success('ScheduleService: Schedules fetched successfully');
        final schedulesList = (response.data as List)
            .map((json) => Schedule.fromJson(json))
            .toList();
        return Right(schedulesList);
      } else {
        Debug.error(
            'ScheduleService: Fetch failed with status ${response.statusCode}');
        return Left("Failed to fetch schedules: ${response.statusMessage}");
      }
    } catch (e) {
      Debug.error('ScheduleService: Fetch error - $e');
      return Left("Error fetching schedules: $e");
    }
  }

  /// Get all schedules created by a specific coach
  Future<Either<String, List<Schedule>>> getCoachSchedules(
      String coachId) async {
    try {
      Debug.api('ScheduleService: Fetching schedules for coach: $coachId');

      final response = await _client.get('$_baseEndpoint/coach/$coachId');

      if (response.statusCode == 200) {
        Debug.success('ScheduleService: Coach schedules fetched successfully');
        final schedulesList = (response.data as List)
            .map((json) => Schedule.fromJson(json))
            .toList();
        return Right(schedulesList);
      } else if (response.statusCode == 404) {
        Debug.info('ScheduleService: No schedules found for coach');
        return const Right([]); // Return empty list instead of error
      } else {
        Debug.error(
            'ScheduleService: Coach schedules fetch failed with status ${response.statusCode}');
        return Left(
            "Failed to fetch coach schedules: ${response.statusMessage}");
      }
    } catch (e) {
      Debug.error('ScheduleService: Coach schedules fetch error - $e');
      return Left("Error fetching coach schedules: $e");
    }
  }

  /// Get current coach's schedules
  Future<Either<String, List<Schedule>>> getMySchedules() async {
    try {
      final userId = await LocalStorageService().getUserId();
      if (userId == null || userId.isEmpty) {
        return const Left("User ID not found");
      }

      return getCoachSchedules(userId);
    } catch (e) {
      Debug.error('ScheduleService: My schedules fetch error - $e');
      return Left("Error fetching my schedules: $e");
    }
  }

  /// Get all schedules that a student is attending
  Future<Either<String, List<Schedule>>> getStudentSchedules(
      String studentId) async {
    try {
      Debug.api('ScheduleService: Fetching schedules for student: $studentId');

      final response = await _client.get('$_baseEndpoint/student/$studentId');

      if (response.statusCode == 200) {
        Debug.success(
            'ScheduleService: Student schedules fetched successfully');
        final schedulesList = (response.data as List)
            .map((json) => Schedule.fromJson(json))
            .toList();
        return Right(schedulesList);
      } else if (response.statusCode == 404) {
        Debug.info('ScheduleService: No schedules found for student');
        return const Right([]); // Return empty list instead of error
      } else {
        Debug.error(
            'ScheduleService: Student schedules fetch failed with status ${response.statusCode}');
        return Left(
            "Failed to fetch student schedules: ${response.statusMessage}");
      }
    } catch (e) {
      Debug.error('ScheduleService: Student schedules fetch error - $e');
      return Left("Error fetching student schedules: $e");
    }
  }

  /// Get current user's attending schedules (for students)
  Future<Either<String, List<Schedule>>> getMyAttendingSchedules() async {
    try {
      final userId = await LocalStorageService().getUserId();
      if (userId == null || userId.isEmpty) {
        return const Left("User ID not found");
      }

      return getStudentSchedules(userId);
    } catch (e) {
      Debug.error('ScheduleService: My attending schedules fetch error - $e');
      return Left("Error fetching my attending schedules: $e");
    }
  }

  /// Get a schedule by ID
  Future<Either<String, Schedule>> getScheduleById(String scheduleId) async {
    try {
      Debug.api('ScheduleService: Fetching schedule by ID: $scheduleId');

      final response = await _client.get('$_baseEndpoint/$scheduleId');

      if (response.statusCode == 200) {
        Debug.success('ScheduleService: Schedule fetched successfully');
        return Right(Schedule.fromJson(response.data));
      } else if (response.statusCode == 404) {
        Debug.error('ScheduleService: Schedule not found');
        return const Left("Schedule not found");
      } else {
        Debug.error(
            'ScheduleService: Schedule fetch failed with status ${response.statusCode}');
        return Left("Failed to fetch schedule: ${response.statusMessage}");
      }
    } catch (e) {
      Debug.error('ScheduleService: Schedule fetch error - $e');
      return Left("Error fetching schedule: $e");
    }
  }

  /// Update a schedule by ID (coach/admin only)
  Future<Either<String, Schedule>> updateSchedule({
    required String scheduleId,
    String? title,
    String? description,
    DateTime? date,
    DateTime? endDate,
    String? location,
    ScheduleType? type,
    int? maxAttendees,
    ScheduleStatus? status,
    String? notes,
    List<String>? attendees,
  }) async {
    try {
      Debug.api('ScheduleService: Updating schedule: $scheduleId');

      final requestBody = <String, dynamic>{};

      if (title != null && title.trim().isNotEmpty) {
        requestBody['title'] = title.trim();
      }
      if (description != null) {
        requestBody['description'] =
            description.trim().isEmpty ? null : description.trim();
      }
      if (date != null) {
        requestBody['date'] = date.toIso8601String();
      }
      if (endDate != null) {
        requestBody['endDate'] = endDate.toIso8601String();
      }
      if (location != null && location.trim().isNotEmpty) {
        requestBody['location'] = location.trim();
      }
      if (type != null) {
        requestBody['type'] = type.name;
      }
      if (maxAttendees != null) {
        requestBody['maxAttendees'] = maxAttendees > 0 ? maxAttendees : null;
      }
      if (status != null) {
        requestBody['status'] = status.name;
      }
      if (notes != null) {
        requestBody['notes'] = notes.trim().isEmpty ? null : notes.trim();
      }
      if (attendees != null) {
        requestBody['attendees'] = attendees;
      }

      Debug.api('ScheduleService: Update request body - $requestBody');
      final token = await LocalStorageService().getAuthToken();
      _client.setHeaders({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      final response =
          await _client.put('$_baseEndpoint/$scheduleId', data: requestBody);

      if (response.statusCode == 200) {
        Debug.success('ScheduleService: Schedule updated successfully');
        return Right(Schedule.fromJson(response.data));
      } else if (response.statusCode == 404) {
        Debug.error('ScheduleService: Schedule not found for update');
        return const Left("Schedule not found");
      } else {
        Debug.error(
            'ScheduleService: Update failed with status ${response.statusCode}');
        return Left("Failed to update schedule: ${response.statusMessage}");
      }
    } on DioException catch (dioError) {
      Debug.error('ScheduleService: Update error - ${dioError.message}');
      if (dioError.response?.statusCode == 400) {
        return Left("Invalid request data: ${dioError.response?.data}");
      } else if (dioError.response?.statusCode == 401) {
        return const Left("Unauthorized: Please log in again");
      } else if (dioError.response?.statusCode == 403) {
        return const Left(
            "Forbidden: You do not have permission to update schedules");
      }
      return Left("Error updating schedule: ${dioError.message}");
    } catch (e) {
      Debug.error('ScheduleService: Update error - $e');
      return Left("Error updating schedule: $e");
    }
  }

  /// Delete a schedule by ID (coach/admin only)
  Future<Either<String, String>> deleteSchedule(String scheduleId) async {
    try {
      Debug.api('ScheduleService: Deleting schedule: $scheduleId');

      final response = await _client.delete('$_baseEndpoint/$scheduleId');

      if (response.statusCode == 200) {
        Debug.success('ScheduleService: Schedule deleted successfully');
        return Right(
            response.data['message'] ?? 'Schedule deleted successfully');
      } else if (response.statusCode == 404) {
        Debug.error('ScheduleService: Schedule not found for deletion');
        return const Left("Schedule not found");
      } else {
        Debug.error(
            'ScheduleService: Delete failed with status ${response.statusCode}');
        return Left("Failed to delete schedule: ${response.statusMessage}");
      }
    } catch (e) {
      Debug.error('ScheduleService: Delete error - $e');
      return Left("Error deleting schedule: $e");
    }
  }

  /// Attend a schedule (add current user to attendees)
  Future<Either<String, Schedule>> attendSchedule(String scheduleId) async {
    try {
      Debug.api('ScheduleService: Attending schedule: $scheduleId');

      final userId = await LocalStorageService().getUserId();
      if (userId == null || userId.isEmpty) {
        return const Left("User ID not found");
      }

      return attendScheduleWithUsers(scheduleId, [userId]);
    } catch (e) {
      Debug.error('ScheduleService: Attend error - $e');
      return Left("Error attending schedule: $e");
    }
  }

  /// Attend a schedule with specific users (add users to attendees)
  Future<Either<String, Schedule>> attendScheduleWithUsers(
    String scheduleId,
    List<String> userIds,
  ) async {
    try {
      Debug.api('ScheduleService: Adding users to schedule: $scheduleId');

      if (userIds.isEmpty) {
        return const Left("No users provided");
      }

      final requestBody = {
        'users': userIds,
      };

      Debug.api('ScheduleService: Attend request body - $requestBody');

      final response = await _client.post(
        '$_baseEndpoint/$scheduleId/attend',
        data: requestBody,
      );

      if (response.statusCode == 200) {
        Debug.success('ScheduleService: Users added to schedule successfully');
        return Right(Schedule.fromJson(response.data));
      } else if (response.statusCode == 404) {
        Debug.error('ScheduleService: Schedule not found for attendance');
        return const Left("Schedule not found");
      } else {
        Debug.error(
            'ScheduleService: Attend failed with status ${response.statusCode}');
        return Left("Failed to attend schedule: ${response.statusMessage}");
      }
    } catch (e) {
      Debug.error('ScheduleService: Attend with users error - $e');
      return Left("Error attending schedule: $e");
    }
  }

  /// Remove current user from schedule attendees
  Future<Either<String, Schedule>> leaveSchedule(String scheduleId) async {
    try {
      Debug.api('ScheduleService: Leaving schedule: $scheduleId');

      final userId = await LocalStorageService().getUserId();
      if (userId == null || userId.isEmpty) {
        return const Left("User ID not found");
      }

      // First get the current schedule
      final scheduleResult = await getScheduleById(scheduleId);

      return scheduleResult.fold(
        (error) => Left(error),
        (schedule) async {
          if (!schedule.attendees.contains(userId)) {
            return const Left("You are not attending this schedule");
          }

          // Remove user from attendees list
          final updatedAttendees =
              schedule.attendees.where((id) => id != userId).toList();

          // Update the schedule with new attendees list
          return updateSchedule(
            scheduleId: scheduleId,
            attendees: updatedAttendees,
          );
        },
      );
    } catch (e) {
      Debug.error('ScheduleService: Leave error - $e');
      return Left("Error leaving schedule: $e");
    }
  }

  /// Complete a schedule (mark as completed)
  Future<Either<String, Schedule>> completeSchedule(
    String scheduleId, {
    String? notes,
  }) async {
    return updateSchedule(
      scheduleId: scheduleId,
      
      status: ScheduleStatus.completed,
      notes: notes,
    );
  }

  /// Cancel a schedule
  Future<Either<String, Schedule>> cancelSchedule(
    String scheduleId, {
    String? reason,
  }) async {
    return updateSchedule(
      scheduleId: scheduleId,
      status: ScheduleStatus.cancelled,
      notes: reason,
    );
  }

  /// Reschedule a schedule
  Future<Either<String, Schedule>> rescheduleSchedule({
    required String scheduleId,
    required DateTime newDate,
    DateTime? newEndDate,
    String? newLocation,
  }) async {
    return updateSchedule(
      scheduleId: scheduleId,
      date: newDate,
      endDate: newEndDate,
      location: newLocation,
      status: ScheduleStatus.scheduled, // Reset to scheduled
    );
  }

  /// Get upcoming schedules for current user
  Future<Either<String, List<Schedule>>> getUpcomingSchedules() async {
    try {
      final userId = await LocalStorageService().getUserId();
      if (userId == null || userId.isEmpty) {
        return const Left("User ID not found");
      }

      // Get all upcoming schedules
      final allSchedulesResult = await getAllSchedules(upcomingOnly: true);

      return allSchedulesResult.fold(
        (error) => Left(error),
        (schedules) {
          // Filter schedules where user is either creator or attendee
          final userSchedules = schedules
              .where((schedule) =>
                  schedule.createdBy == userId ||
                  schedule.attendees.contains(userId))
              .toList();

          return Right(userSchedules);
        },
      );
    } catch (e) {
      Debug.error('ScheduleService: Upcoming schedules error - $e');
      return Left("Error fetching upcoming schedules: $e");
    }
  }

  /// Get today's schedules for current user
  Future<Either<String, List<Schedule>>> getTodaySchedules() async {
    try {
      final upcomingResult = await getUpcomingSchedules();

      return upcomingResult.fold(
        (error) => Left(error),
        (schedules) {
          final today = DateTime.now();
          final todaySchedules = schedules
              .where((schedule) =>
                  schedule.date.year == today.year &&
                  schedule.date.month == today.month &&
                  schedule.date.day == today.day)
              .toList();

          return Right(todaySchedules);
        },
      );
    } catch (e) {
      Debug.error('ScheduleService: Today schedules error - $e');
      return Left("Error fetching today's schedules: $e");
    }
  }

  /// Check if current user can edit a schedule
  Future<Either<String, bool>> canEditSchedule(String scheduleId) async {
    try {
      final userId = await LocalStorageService().getUserId();
      if (userId == null || userId.isEmpty) {
        return const Left("User ID not found");
      }

      final scheduleResult = await getScheduleById(scheduleId);

      return scheduleResult.fold(
        (error) => Left(error),
        (schedule) => Right(schedule.createdBy == userId),
      );
    } catch (e) {
      Debug.error('ScheduleService: Can edit check error - $e');
      return Left("Error checking edit permissions: $e");
    }
  }

  /// Check if current user is attending a schedule
  Future<Either<String, bool>> isAttendingSchedule(String scheduleId) async {
    try {
      final userId = await LocalStorageService().getUserId();
      if (userId == null || userId.isEmpty) {
        return const Left("User ID not found");
      }

      final scheduleResult = await getScheduleById(scheduleId);

      return scheduleResult.fold(
        (error) => Left(error),
        (schedule) => Right(schedule.attendees.contains(userId)),
      );
    } catch (e) {
      Debug.error('ScheduleService: Attendance check error - $e');
      return Left("Error checking attendance: $e");
    }
  }
}
