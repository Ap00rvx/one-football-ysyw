import 'package:dio/dio.dart';
import '../global/dio.dart';
import '../config/debug/debug.dart';
import '../model/student.dart';
import '../config/exceptions/student.dart';

class StudentService {
  static final StudentService _instance = StudentService._internal();
  factory StudentService() => _instance;
  StudentService._internal();

  final DioClient _dioClient = DioClient();

  /// Create a new student
  Future<Student> createStudent({
    required String name,
    required String userId,
    required String email,
    required DateTime dob,
    required String jerseyNumber,
    required double height,
    required double weight,
    List<String>? highLights,
    List<StudentMetric>? metrics,
  }) async {
    try {
      Debug.api('Creating student for userId: $userId');
      
      final response = await _dioClient.post('/app/s/students', data: {
        'name': name,
        'userId': userId,
        'email': email,
        'dob': dob.toIso8601String(),
        'jerseyNumber': jerseyNumber,
        'height': height,
        'weight': weight,
        'highLights': highLights ?? [],
        'metrics': metrics?.map((metric) => metric.toJson()).toList() ?? [],
      });

      if (response.statusCode == 201) {
        Debug.success('Student created successfully');
        return Student.fromJson(response.data);
      } else {
        Debug.error('Student creation failed with status: ${response.statusCode}');
        throw StudentException('Failed to create student');
      }
    } on DioException catch (e) {
      Debug.error('Student creation API error: ${e.response?.data ?? e.message}');
      throw StudentException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected student creation error: $e');
      throw StudentException('An unexpected error occurred while creating student');
    }
  }

  /// Get all students
  Future<List<Student>> getAllStudents() async {
    try {
      Debug.api('Fetching all students');
      
      final response = await _dioClient.get('/app/s/students');

      if (response.statusCode == 200) {
        Debug.success('Students retrieved successfully');
        final List<dynamic> studentsData = response.data;
        return studentsData.map((data) => Student.fromJson(data)).toList();
      } else {
        Debug.error('Get students failed with status: ${response.statusCode}');
        throw StudentException('Failed to fetch students');
      }
    } on DioException catch (e) {
      Debug.error('Get students API error: ${e.response?.data ?? e.message}');
      throw StudentException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected get students error: $e');
      throw StudentException('An unexpected error occurred while fetching students');
    }
  }

  /// Get student by ID
  Future<Student> getStudentById(String studentId) async {
    try {
      Debug.api('Fetching student by ID: $studentId');
      
      final response = await _dioClient.get('/app/s/students/$studentId');

      if (response.statusCode == 200) {
        Debug.success('Student retrieved successfully');
        return Student.fromJson(response.data);
      } else {
        Debug.error('Get student failed with status: ${response.statusCode}');
        throw StudentException('Student not found');
      }
    } on DioException catch (e) {
      Debug.error('Get student API error: ${e.response?.data ?? e.message}');
      throw StudentException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected get student error: $e');
      throw StudentException('An unexpected error occurred while fetching student');
    }
  }

  /// Get student by user ID
  Future<Student?> getStudentByUserId(String userId) async {
    try {
      Debug.api('Fetching student by userId: $userId');
      final students = await getAllStudents();
      final student = students.where((s) => s.userId == userId).firstOrNull;
      
      if (student != null) {
        Debug.success('Student found for userId: $userId');
      } else {
        Debug.info('No student found for userId: $userId');
      }
      
      return student;
    } catch (e) {
      Debug.error('Error getting student by userId: $e');
      throw StudentException('Failed to fetch student by user ID');
    }
  }

  /// Update student
  Future<Student> updateStudent({
    required String studentId,
    String? name,
    String? email,
    DateTime? dob,
    String? jerseyNumber,
    double? height,
    double? weight,
    List<String>? highLights,
    List<StudentMetric>? metrics,
  }) async {
    try {
      Debug.api('Updating student: $studentId');
      
      final Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (dob != null) updateData['dob'] = dob.toIso8601String();
      if (jerseyNumber != null) updateData['jerseyNumber'] = jerseyNumber;
      if (height != null) updateData['height'] = height;
      if (weight != null) updateData['weight'] = weight;
      if (highLights != null) updateData['highLights'] = highLights;
      if (metrics != null) {
        updateData['metrics'] = metrics.map((metric) => metric.toJson()).toList();
      }
      
      final response = await _dioClient.put('/app/s/students/$studentId', data: updateData);

      if (response.statusCode == 200) {
        Debug.success('Student updated successfully');
        return Student.fromJson(response.data);
      } else {
        Debug.error('Student update failed with status: ${response.statusCode}');
        throw StudentException('Failed to update student');
      }
    } on DioException catch (e) {
      Debug.error('Student update API error: ${e.response?.data ?? e.message}');
      throw StudentException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected student update error: $e');
      throw StudentException('An unexpected error occurred while updating student');
    }
  }

  /// Delete student
  Future<void> deleteStudent(String studentId) async {
    try {
      Debug.api('Deleting student: $studentId');
      
      final response = await _dioClient.delete('/app/s/students/$studentId');

      if (response.statusCode == 200) {
        Debug.success('Student deleted successfully');
      } else {
        Debug.error('Student deletion failed with status: ${response.statusCode}');
        throw StudentException('Failed to delete student');
      }
    } on DioException catch (e) {
      Debug.error('Student deletion API error: ${e.response?.data ?? e.message}');
      throw StudentException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected student deletion error: $e');
      throw StudentException('An unexpected error occurred while deleting student');
    }
  }

  /// Add highlight to student
  Future<Student> addHighlight(String studentId, String highlight) async {
    try {
      final student = await getStudentById(studentId);
      final updatedHighlights = [...student.highLights, highlight];
      
      return await updateStudent(
        studentId: studentId,
        highLights: updatedHighlights,
      );
    } catch (e) {
      Debug.error('Error adding highlight: $e');
      throw StudentException('Failed to add highlight');
    }
  }

  /// Remove highlight from student
  Future<Student> removeHighlight(String studentId, String highlight) async {
    try {
      final student = await getStudentById(studentId);
      final updatedHighlights = student.highLights.where((h) => h != highlight).toList();
      
      return await updateStudent(
        studentId: studentId,
        highLights: updatedHighlights,
      );
    } catch (e) {
      Debug.error('Error removing highlight: $e');
      throw StudentException('Failed to remove highlight');
    }
  }

  /// Add metric to student
  Future<Student> addMetric(String studentId, StudentMetric metric) async {
    try {
      final student = await getStudentById(studentId);
      final updatedMetrics = [...student.metrics, metric];
      
      return await updateStudent(
        studentId: studentId,
        metrics: updatedMetrics,
      );
    } catch (e) {
      Debug.error('Error adding metric: $e');
      throw StudentException('Failed to add metric');
    }
  }

  /// Update specific metric
  Future<Student> updateMetric(String studentId, String metricType, double value) async {
    try {
      final student = await getStudentById(studentId);
      final updatedMetrics = student.metrics.map((metric) {
        if (metric.metricType == metricType) {
          return StudentMetric(metricType: metricType, value: value);
        }
        return metric;
      }).toList();
      
      return await updateStudent(
        studentId: studentId,
        metrics: updatedMetrics,
      );
    } catch (e) {
      Debug.error('Error updating metric: $e');
      throw StudentException('Failed to update metric');
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