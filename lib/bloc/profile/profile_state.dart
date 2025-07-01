part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileResponse? profile;
  final String? errorMessage;
  final bool? isProfileComplete;
  final String? userRole;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.isProfileComplete,
    this.userRole,
  });

  @override
  List<Object?> get props => [
    status,
    profile,
    errorMessage,
    isProfileComplete,
    userRole,
  ];

  bool get isInitial => status == ProfileStatus.initial;
  bool get isLoading => status == ProfileStatus.loading;
  bool get isSuccess => status == ProfileStatus.success;
  bool get isFailure => status == ProfileStatus.failure;

  // Helper getters
  bool get hasProfile => profile != null;
  bool get hasRoleProfile => profile?.roleProfile != null;
  bool get isStudent => profile?.user?.role == 'student';
  bool get isCoach => profile?.user?.role == 'coach';
  
  StudentProfile? get studentProfile => 
      isStudent ? profile?.roleProfile as StudentProfile? : null;
  
  CoachProfile? get coachProfile => 
      isCoach ? profile?.roleProfile as CoachProfile? : null;
  
  String get userName => profile?.user?.name ?? '';
  String get userEmail => profile?.user?.email ?? '';
  String? get userPhone => profile?.user?.phone;
  String? get userProfilePicture => profile?.user?.profilePicture;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileResponse? profile,
    String? errorMessage,
    bool? isProfileComplete,
    String? userRole,
    bool clearError = false,
    bool clearProfile = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: clearProfile ? null : (profile ?? this.profile),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      userRole: userRole ?? this.userRole,
    );
  }
}