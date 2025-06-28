import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/student_service.dart';
import '../../model/student.dart';
import '../../config/exceptions/student.dart';
import '../../config/debug/debug.dart';

part 'student_events.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentService _studentService;

  StudentBloc({StudentService? studentService})
      : _studentService = studentService ?? StudentService(),
        super(const StudentState()) {
    on<InitialStudentEvent>(_onInitialStudentEvent);
    on<CreateStudentEvent>(_onCreateStudentEvent);
    on<GetAllStudentsEvent>(_onGetAllStudentsEvent);
    on<GetStudentByIdEvent>(_onGetStudentByIdEvent);
    on<GetStudentByUserIdEvent>(_onGetStudentByUserIdEvent);
    on<UpdateStudentEvent>(_onUpdateStudentEvent);
    on<DeleteStudentEvent>(_onDeleteStudentEvent);
    on<AddHighlightEvent>(_onAddHighlightEvent);
    on<RemoveHighlightEvent>(_onRemoveHighlightEvent);
    on<AddMetricEvent>(_onAddMetricEvent);
    on<UpdateMetricEvent>(_onUpdateMetricEvent);
  }

  Future<void> _onInitialStudentEvent(
    InitialStudentEvent event,
    Emitter<StudentState> emit,
  ) async {
    Debug.bloc('StudentBloc: Initial event triggered');
    emit(state.copyWith(
      status: StudentStatus.initial,
      clearCurrentStudent: true,
      clearError: true,
    ));
  }

  Future<void> _onCreateStudentEvent(
    CreateStudentEvent event,
    Emitter<StudentState> emit,
  ) async {
    try {
      Debug.bloc('StudentBloc: Creating student');
      emit(state.copyWith(status: StudentStatus.loading, clearError: true));

      final student = await _studentService.createStudent(
        name: event.name,
        userId: event.userId,
        email: event.email,
        dob: event.dob,
        jerseyNumber: event.jerseyNumber,
        height: event.height,
        weight: event.weight,
        highLights: event.highLights,
        metrics: event.metrics,
      );

      final updatedStudents = [...state.students, student];

      emit(state.copyWith(
        status: StudentStatus.success,
        students: updatedStudents,
        currentStudent: student,
      ));

      Debug.success('StudentBloc: Student created successfully');
    } on StudentException catch (e) {
      Debug.error('StudentBloc: Student creation failed - ${e.message}');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('StudentBloc: Unexpected error during student creation - $e');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: 'An unexpected error occurred while creating student',
      ));
    }
  }

  Future<void> _onGetAllStudentsEvent(
    GetAllStudentsEvent event,
    Emitter<StudentState> emit,
  ) async {
    try {
      Debug.bloc('StudentBloc: Fetching all students');
      emit(state.copyWith(status: StudentStatus.loading, clearError: true));

      final students = await _studentService.getAllStudents();

      emit(state.copyWith(
        status: StudentStatus.success,
        students: students,
      ));

      Debug.success('StudentBloc: ${students.length} students fetched successfully');
    } on StudentException catch (e) {
      Debug.error('StudentBloc: Failed to fetch students - ${e.message}');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('StudentBloc: Unexpected error during students fetch - $e');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching students',
      ));
    }
  }

  Future<void> _onGetStudentByIdEvent(
    GetStudentByIdEvent event,
    Emitter<StudentState> emit,
  ) async {
    try {
      Debug.bloc('StudentBloc: Fetching student by ID - ${event.studentId}');
      emit(state.copyWith(status: StudentStatus.loading, clearError: true));

      final student = await _studentService.getStudentById(event.studentId);

      emit(state.copyWith(
        status: StudentStatus.success,
        currentStudent: student,
      ));

      Debug.success('StudentBloc: Student fetched successfully');
    } on StudentException catch (e) {
      Debug.error('StudentBloc: Failed to fetch student - ${e.message}');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('StudentBloc: Unexpected error during student fetch - $e');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching student',
      ));
    }
  }

  Future<void> _onGetStudentByUserIdEvent(
    GetStudentByUserIdEvent event,
    Emitter<StudentState> emit,
  ) async {
    try {
      Debug.bloc('StudentBloc: Fetching student by user ID - ${event.userId}');
      emit(state.copyWith(status: StudentStatus.loading, clearError: true));

      final student = await _studentService.getStudentByUserId(event.userId);

      emit(state.copyWith(
        status: StudentStatus.success,
        currentStudent: student,
      ));

      if (student != null) {
        Debug.success('StudentBloc: Student found for user ID');
      } else {
        Debug.info('StudentBloc: No student found for user ID');
      }
    } on StudentException catch (e) {
      Debug.error('StudentBloc: Failed to fetch student by user ID - ${e.message}');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('StudentBloc: Unexpected error during student fetch by user ID - $e');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching student',
      ));
    }
  }

  Future<void> _onUpdateStudentEvent(
    UpdateStudentEvent event,
    Emitter<StudentState> emit,
  ) async {
    try {
      Debug.bloc('StudentBloc: Updating student - ${event.studentId}');
      emit(state.copyWith(status: StudentStatus.loading, clearError: true));

      final updatedStudent = await _studentService.updateStudent(
        studentId: event.studentId,
        name: event.name,
        email: event.email,
        dob: event.dob,
        jerseyNumber: event.jerseyNumber,
        height: event.height,
        weight: event.weight,
        highLights: event.highLights,
        metrics: event.metrics,
      );

      // Update the student in the list
      final updatedStudents = state.students.map((student) {
        return student.id == event.studentId ? updatedStudent : student;
      }).toList();

      emit(state.copyWith(
        status: StudentStatus.success,
        students: updatedStudents,
        currentStudent: updatedStudent,
      ));

      Debug.success('StudentBloc: Student updated successfully');
    } on StudentException catch (e) {
      Debug.error('StudentBloc: Student update failed - ${e.message}');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('StudentBloc: Unexpected error during student update - $e');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: 'An unexpected error occurred while updating student',
      ));
    }
  }

  Future<void> _onDeleteStudentEvent(
    DeleteStudentEvent event,
    Emitter<StudentState> emit,
  ) async {
    try {
      Debug.bloc('StudentBloc: Deleting student - ${event.studentId}');
      emit(state.copyWith(status: StudentStatus.loading, clearError: true));

      await _studentService.deleteStudent(event.studentId);

      // Remove the student from the list
      final updatedStudents = state.students
          .where((student) => student.id != event.studentId)
          .toList();

      // Clear current student if it's the deleted one
      final shouldClearCurrent = state.currentStudent?.id == event.studentId;

      emit(state.copyWith(
        status: StudentStatus.success,
        students: updatedStudents,
        clearCurrentStudent: shouldClearCurrent,
      ));

      Debug.success('StudentBloc: Student deleted successfully');
    } on StudentException catch (e) {
      Debug.error('StudentBloc: Student deletion failed - ${e.message}');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('StudentBloc: Unexpected error during student deletion - $e');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: 'An unexpected error occurred while deleting student',
      ));
    }
  }

  Future<void> _onAddHighlightEvent(
    AddHighlightEvent event,
    Emitter<StudentState> emit,
  ) async {
    try {
      Debug.bloc('StudentBloc: Adding highlight to student - ${event.studentId}');
      emit(state.copyWith(status: StudentStatus.loading, clearError: true));

      final updatedStudent = await _studentService.addHighlight(
        event.studentId,
        event.highlight,
      );

      _updateStudentInState(updatedStudent, emit);

      Debug.success('StudentBloc: Highlight added successfully');
    } on StudentException catch (e) {
      Debug.error('StudentBloc: Add highlight failed - ${e.message}');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('StudentBloc: Unexpected error during add highlight - $e');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: 'An unexpected error occurred while adding highlight',
      ));
    }
  }

  Future<void> _onRemoveHighlightEvent(
    RemoveHighlightEvent event,
    Emitter<StudentState> emit,
  ) async {
    try {
      Debug.bloc('StudentBloc: Removing highlight from student - ${event.studentId}');
      emit(state.copyWith(status: StudentStatus.loading, clearError: true));

      final updatedStudent = await _studentService.removeHighlight(
        event.studentId,
        event.highlight,
      );

      _updateStudentInState(updatedStudent, emit);

      Debug.success('StudentBloc: Highlight removed successfully');
    } on StudentException catch (e) {
      Debug.error('StudentBloc: Remove highlight failed - ${e.message}');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('StudentBloc: Unexpected error during remove highlight - $e');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: 'An unexpected error occurred while removing highlight',
      ));
    }
  }

  Future<void> _onAddMetricEvent(
    AddMetricEvent event,
    Emitter<StudentState> emit,
  ) async {
    try {
      Debug.bloc('StudentBloc: Adding metric to student - ${event.studentId}');
      emit(state.copyWith(status: StudentStatus.loading, clearError: true));

      final updatedStudent = await _studentService.addMetric(
        event.studentId,
        event.metric,
      );

      _updateStudentInState(updatedStudent, emit);

      Debug.success('StudentBloc: Metric added successfully');
    } on StudentException catch (e) {
      Debug.error('StudentBloc: Add metric failed - ${e.message}');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('StudentBloc: Unexpected error during add metric - $e');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: 'An unexpected error occurred while adding metric',
      ));
    }
  }

  Future<void> _onUpdateMetricEvent(
    UpdateMetricEvent event,
    Emitter<StudentState> emit,
  ) async {
    try {
      Debug.bloc('StudentBloc: Updating metric for student - ${event.studentId}');
      emit(state.copyWith(status: StudentStatus.loading, clearError: true));

      final updatedStudent = await _studentService.updateMetric(
        event.studentId,
        event.metricType,
        event.value,
      );

      _updateStudentInState(updatedStudent, emit);

      Debug.success('StudentBloc: Metric updated successfully');
    } on StudentException catch (e) {
      Debug.error('StudentBloc: Update metric failed - ${e.message}');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('StudentBloc: Unexpected error during update metric - $e');
      emit(state.copyWith(
        status: StudentStatus.failure,
        errorMessage: 'An unexpected error occurred while updating metric',
      ));
    }
  }

  void _updateStudentInState(Student updatedStudent, Emitter<StudentState> emit) {
    final updatedStudents = state.students.map((student) {
      return student.id == updatedStudent.id ? updatedStudent : student;
    }).toList();

    emit(state.copyWith(
      status: StudentStatus.success,
      students: updatedStudents,
      currentStudent: updatedStudent,
    ));
  }
}