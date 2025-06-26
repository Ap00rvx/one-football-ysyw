part of 'student_bloc.dart';

abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object> get props => [];
}

class InitialStudentEvent extends StudentEvent {}

class CreateStudentEvent extends StudentEvent {
  final String name;
  final String userId;
  final String email;
  final DateTime dob;
  final String jerseyNumber;
  final double height;
  final double weight;
  final List<String>? highLights;
  final List<StudentMetric>? metrics;

  const CreateStudentEvent({
    required this.name,
    required this.userId,
    required this.email,
    required this.dob,
    required this.jerseyNumber,
    required this.height,
    required this.weight,
    this.highLights,
    this.metrics,
  });

  @override
  List<Object> get props => [
    name, userId, email, dob, jerseyNumber, height, weight,
    highLights ?? [], metrics ?? []
  ];
}

class GetAllStudentsEvent extends StudentEvent {}

class GetStudentByIdEvent extends StudentEvent {
  final String studentId;

  const GetStudentByIdEvent(this.studentId);

  @override
  List<Object> get props => [studentId];
}

class GetStudentByUserIdEvent extends StudentEvent {
  final String userId;

  const GetStudentByUserIdEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class UpdateStudentEvent extends StudentEvent {
  final String studentId;
  final String? name;
  final String? email;
  final DateTime? dob;
  final String? jerseyNumber;
  final double? height;
  final double? weight;
  final List<String>? highLights;
  final List<StudentMetric>? metrics;

  const UpdateStudentEvent({
    required this.studentId,
    this.name,
    this.email,
    this.dob,
    this.jerseyNumber,
    this.height,
    this.weight,
    this.highLights,
    this.metrics,
  });

  @override
  List<Object> get props => [
    studentId,
    name ?? '',
    email ?? '',
    dob ?? DateTime.now(),
    jerseyNumber ?? '',
    height ?? 0.0,
    weight ?? 0.0,
    highLights ?? [],
    metrics ?? [],
  ];
}

class DeleteStudentEvent extends StudentEvent {
  final String studentId;

  const DeleteStudentEvent(this.studentId);

  @override
  List<Object> get props => [studentId];
}

class AddHighlightEvent extends StudentEvent {
  final String studentId;
  final String highlight;

  const AddHighlightEvent(this.studentId, this.highlight);

  @override
  List<Object> get props => [studentId, highlight];
}

class RemoveHighlightEvent extends StudentEvent {
  final String studentId;
  final String highlight;

  const RemoveHighlightEvent(this.studentId, this.highlight);

  @override
  List<Object> get props => [studentId, highlight];
}

class AddMetricEvent extends StudentEvent {
  final String studentId;
  final StudentMetric metric;

  const AddMetricEvent(this.studentId, this.metric);

  @override
  List<Object> get props => [studentId, metric];
}

class UpdateMetricEvent extends StudentEvent {
  final String studentId;
  final String metricType;
  final double value;

  const UpdateMetricEvent(this.studentId, this.metricType, this.value);

  @override
  List<Object> get props => [studentId, metricType, value];
}