part of 'coach_bloc.dart';

abstract class CoachEvent extends Equatable {
  const CoachEvent();

  @override
  List<Object> get props => [];
}

class InitialCoachEvent extends CoachEvent {}

class CreateCoachEvent extends CoachEvent {
  final String name;
  final String userId;
  final String email;
  final String coachingSpecialty;
  final int experienceYears;
  final String? phone;
  final String? profilePicture;
  final List<String>? certifications;
  final List<String>? students;

  const CreateCoachEvent({
    required this.name,
    required this.userId,
    required this.email,
    required this.coachingSpecialty,
    required this.experienceYears,
    this.phone,
    this.profilePicture,
    this.certifications,
    this.students,
  });

  @override
  List<Object> get props => [
    name,
    userId,
    email,
    coachingSpecialty,
    experienceYears,
    phone ?? '',
    profilePicture ?? '',
    certifications ?? [],
    students ?? [],
  ];
}

class GetAllCoachesEvent extends CoachEvent {}

class GetCoachByIdEvent extends CoachEvent {
  final String coachId;

  const GetCoachByIdEvent(this.coachId);

  @override
  List<Object> get props => [coachId];
}

class GetCoachByUserIdEvent extends CoachEvent {
  final String userId;

  const GetCoachByUserIdEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class UpdateCoachEvent extends CoachEvent {
  final String coachId;
  final String? name;
  final String? email;
  final String? phone;
  final String? profilePicture;
  final String? coachingSpecialty;
  final int? experienceYears;
  final List<String>? certifications;
  final List<String>? students;

  const UpdateCoachEvent({
    required this.coachId,
    this.name,
    this.email,
    this.phone,
    this.profilePicture,
    this.coachingSpecialty,
    this.experienceYears,
    this.certifications,
    this.students,
  });

  @override
  List<Object> get props => [
    coachId,
    name ?? '',
    email ?? '',
    phone ?? '',
    profilePicture ?? '',
    coachingSpecialty ?? '',
    experienceYears ?? 0,
    certifications ?? [],
    students ?? [],
  ];
}

class DeleteCoachEvent extends CoachEvent {
  final String coachId;

  const DeleteCoachEvent(this.coachId);

  @override
  List<Object> get props => [coachId];
}

class AddCertificationEvent extends CoachEvent {
  final String coachId;
  final String certification;

  const AddCertificationEvent(this.coachId, this.certification);

  @override
  List<Object> get props => [coachId, certification];
}

class RemoveCertificationEvent extends CoachEvent {
  final String coachId;
  final String certification;

  const RemoveCertificationEvent(this.coachId, this.certification);

  @override
  List<Object> get props => [coachId, certification];
}

class AddStudentEvent extends CoachEvent {
  final String coachId;
  final String studentId;

  const AddStudentEvent(this.coachId, this.studentId);

  @override
  List<Object> get props => [coachId, studentId];
}

class RemoveStudentEvent extends CoachEvent {
  final String coachId;
  final String studentId;

  const RemoveStudentEvent(this.coachId, this.studentId);

  @override
  List<Object> get props => [coachId, studentId];
}

class GetCoachesBySpecialtyEvent extends CoachEvent {
  final String specialty;

  const GetCoachesBySpecialtyEvent(this.specialty);

  @override
  List<Object> get props => [specialty];
}

class GetCoachesByExperienceEvent extends CoachEvent {
  final int? minYears;
  final int? maxYears;

  const GetCoachesByExperienceEvent({this.minYears, this.maxYears});

  @override
  List<Object> get props => [minYears ?? 0, maxYears ?? 0];
}

class GetCoachStatsEvent extends CoachEvent {
  final String coachId;

  const GetCoachStatsEvent(this.coachId);

  @override
  List<Object> get props => [coachId];
}

class SearchCoachesEvent extends CoachEvent {
  final String query;

  const SearchCoachesEvent(this.query);

  @override
  List<Object> get props => [query];
}

class ClearCoachFiltersEvent extends CoachEvent {}