part of 'student_bloc.dart';

enum StudentStatus { initial, loading, success, failure }

class StudentState extends Equatable {
  final StudentStatus status;
  final List<Student> students;
  final Student? currentStudent;
  final String? errorMessage;

  const StudentState({
    this.status = StudentStatus.initial,
    this.students = const [],
    this.currentStudent,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, students, currentStudent, errorMessage];

  bool get isInitial => status == StudentStatus.initial;
  bool get isLoading => status == StudentStatus.loading;
  bool get isSuccess => status == StudentStatus.success;
  bool get isFailure => status == StudentStatus.failure;

  StudentState copyWith({
    StudentStatus? status,
    List<Student>? students,
    Student? currentStudent,
    String? errorMessage,
    bool clearCurrentStudent = false,
    bool clearError = false,
  }) {
    return StudentState(
      status: status ?? this.status,
      students: students ?? this.students,
      currentStudent: clearCurrentStudent ? null : (currentStudent ?? this.currentStudent),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}