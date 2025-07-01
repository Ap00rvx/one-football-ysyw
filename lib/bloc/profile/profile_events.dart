part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class InitialProfileEvent extends ProfileEvent {}

class GetProfileEvent extends ProfileEvent {}

class UpdateBasicProfileEvent extends ProfileEvent {
  final String? name;
  final String? phone;
  final String? profilePicture;

  const UpdateBasicProfileEvent({
    this.name,
    this.phone,
    this.profilePicture,
  });

  @override
  List<Object> get props => [name ?? '', phone ?? '', profilePicture ?? ''];
}

class UpdateCoachProfileEvent extends ProfileEvent {
  final String? name;
  final String? phone;
  final String? profilePicture;
  final String? coachingSpecialty;
  final int? experienceYears;
  final List<String>? certifications;

  const UpdateCoachProfileEvent({
    this.name,
    this.phone,
    this.profilePicture,
    this.coachingSpecialty,
    this.experienceYears,
    this.certifications,
  });

  @override
  List<Object> get props => [
    name ?? '',
    phone ?? '',
    profilePicture ?? '',
    coachingSpecialty ?? '',
    experienceYears ?? 0,
    certifications ?? [],
  ];
}

class UpdateStudentProfileEvent extends ProfileEvent {
  final String? name;
  final String? phone;
  final String? profilePicture;
  final String? jerseyNumber;
  final double? height;
  final double? weight;
  final DateTime? dob;
  final List<String>? highLights;

  const UpdateStudentProfileEvent({
    this.name,
    this.phone,
    this.profilePicture,
    this.jerseyNumber,
    this.height,
    this.weight,
    this.dob,
    this.highLights,
  });

  @override
  List<Object> get props => [
    name ?? '',
    phone ?? '',
    profilePicture ?? '',
    jerseyNumber ?? '',
    height ?? 0.0,
    weight ?? 0.0,
    dob ?? DateTime.now(),
    highLights ?? [],
  ];
}

class AddCertificationEvent extends ProfileEvent {
  final String certification;

  const AddCertificationEvent(this.certification);

  @override
  List<Object> get props => [certification];
}

class RemoveCertificationEvent extends ProfileEvent {
  final String certification;

  const RemoveCertificationEvent(this.certification);

  @override
  List<Object> get props => [certification];
}

class AddHighlightEvent extends ProfileEvent {
  final String highlight;

  const AddHighlightEvent(this.highlight);

  @override
  List<Object> get props => [highlight];
}

class RemoveHighlightEvent extends ProfileEvent {
  final String highlight;

  const RemoveHighlightEvent(this.highlight);

  @override
  List<Object> get props => [highlight];
}

class CheckProfileCompletionEvent extends ProfileEvent {}

class GetUserRoleEvent extends ProfileEvent {}

class RefreshProfileEvent extends ProfileEvent {}

class ClearProfileEvent extends ProfileEvent {}
class DeleteProfilePictureEvent extends ProfileEvent {
  @override
  List<Object> get props => [];
}