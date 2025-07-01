import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ysyw/services/local_storage_service.dart';
import '../../services/profile_service.dart';
import '../../model/profile.dart';
import '../../config/debug/debug.dart';

part 'profile_events.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService _profileService;

  ProfileBloc({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService(),
        super(const ProfileState()) {
    on<InitialProfileEvent>(_onInitialProfileEvent);
    on<GetProfileEvent>(_onGetProfileEvent);
    on<UpdateBasicProfileEvent>(_onUpdateBasicProfileEvent);
    on<UpdateCoachProfileEvent>(_onUpdateCoachProfileEvent);
    on<UpdateStudentProfileEvent>(_onUpdateStudentProfileEvent);
    on<AddCertificationEvent>(_onAddCertificationEvent);
    on<RemoveCertificationEvent>(_onRemoveCertificationEvent);
    on<AddHighlightEvent>(_onAddHighlightEvent);
    on<RemoveHighlightEvent>(_onRemoveHighlightEvent);
    on<CheckProfileCompletionEvent>(_onCheckProfileCompletionEvent);
    on<GetUserRoleEvent>(_onGetUserRoleEvent);
    on<RefreshProfileEvent>(_onRefreshProfileEvent);
    on<ClearProfileEvent>(_onClearProfileEvent);
    on<DeleteProfilePictureEvent>((event, emit) async {
      Debug.bloc('ProfileBloc: Deleting profile picture');
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
      try {
        final result = await _profileService.deleteProfilePicture(); 
        result.fold(
          (error) {
            Debug.error('ProfileBloc: Failed to delete profile picture - $error');
            emit(state.copyWith(
              status: ProfileStatus.failure,
              errorMessage: error,
            ));
          },
          (profile) {
            Debug.success('ProfileBloc: Profile picture deleted successfully');
            emit(state.copyWith(
              status: ProfileStatus.success,
              profile: profile,
            ));
          },
        );
      } catch (e) {
        Debug.error('ProfileBloc: Unexpected error during profile picture deletion - $e');
        emit(state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'An unexpected error occurred while deleting profile picture',
        ));
      }
    });
  }

  Future<void> _onInitialProfileEvent(
    InitialProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    Debug.bloc('ProfileBloc: Initial event triggered');
    emit(state.copyWith(
      status: ProfileStatus.initial,
      clearError: true,
      clearProfile: true,
      isProfileComplete: null,
      userRole: null,
    ));
  }

  Future<void> _onGetProfileEvent(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Debug.bloc('ProfileBloc: Fetching user profile');
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

      final result = await _profileService.getProfile();

      result.fold(
        (error) {
          Debug.error('ProfileBloc: Failed to fetch profile - $error');
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error,
          ));
        },
        (profile) {
          Debug.success('ProfileBloc: Profile fetched successfully');
          emit(state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
            userRole: profile.user?.role,
          ));
        },
      );
    } catch (e) {
      Debug.error('ProfileBloc: Unexpected error during profile fetch - $e');
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching profile',
      ));
    }
  }

  Future<void> _onUpdateBasicProfileEvent(
    UpdateBasicProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Debug.bloc('ProfileBloc: Updating basic profile');
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

      final result = await _profileService.updateBasicProfile(
        name: event.name,
        phone: event.phone,
        profilePicture: event.profilePicture,
      );

      result.fold(
        (error) {
          Debug.error('ProfileBloc: Failed to update basic profile - $error');
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error,
          ));
        },
        (profile) {
          Debug.success('ProfileBloc: Basic profile updated successfully');
          emit(state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
          ));
        },
      );
    } catch (e) {
      Debug.error('ProfileBloc: Unexpected error during basic profile update - $e');
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'An unexpected error occurred while updating profile',
      ));
    }
  }

  Future<void> _onUpdateCoachProfileEvent(
    UpdateCoachProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Debug.bloc('ProfileBloc: Updating coach profile');
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

      final result = await _profileService.updateCoachProfile(
        name: event.name,
        phone: event.phone,
        profilePicture: event.profilePicture,
        coachingSpecialty: event.coachingSpecialty,
        experienceYears: event.experienceYears,
        certifications: event.certifications,
      );

      result.fold(
        (error) {
          Debug.error('ProfileBloc: Failed to update coach profile - $error');
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error,
          ));
        },
        (profile) {
          Debug.success('ProfileBloc: Coach profile updated successfully');
          emit(state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
          ));
        },
      );
    } catch (e) {
      Debug.error('ProfileBloc: Unexpected error during coach profile update - $e');
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'An unexpected error occurred while updating coach profile',
      ));
    }
  }

  Future<void> _onUpdateStudentProfileEvent(
    UpdateStudentProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Debug.bloc('ProfileBloc: Updating student profile');
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

      final result = await _profileService.updateStudentProfile(
        name: event.name,
        phone: event.phone,
        profilePicture: event.profilePicture,
        jerseyNumber: event.jerseyNumber,
        height: event.height,
        weight: event.weight,
        dob: event.dob,
        highLights: event.highLights,
      );

      result.fold(
        (error) {
          Debug.error('ProfileBloc: Failed to update student profile - $error');
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error,
          ));
        },
        (profile) {
          Debug.success('ProfileBloc: Student profile updated successfully');
          emit(state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
          ));
        },
      );
    } catch (e) {
      Debug.error('ProfileBloc: Unexpected error during student profile update - $e');
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'An unexpected error occurred while updating student profile',
      ));
    }
  }

  Future<void> _onAddCertificationEvent(
    AddCertificationEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Debug.bloc('ProfileBloc: Adding certification - ${event.certification}');
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

      final result = await _profileService.addCertification(event.certification);

      result.fold(
        (error) {
          Debug.error('ProfileBloc: Failed to add certification - $error');
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error,
          ));
        },
        (profile) {
          Debug.success('ProfileBloc: Certification added successfully');
          emit(state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
          ));
        },
      );
    } catch (e) {
      Debug.error('ProfileBloc: Unexpected error during certification add - $e');
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'An unexpected error occurred while adding certification',
      ));
    }
  }

  Future<void> _onRemoveCertificationEvent(
    RemoveCertificationEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Debug.bloc('ProfileBloc: Removing certification - ${event.certification}');
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

      final result = await _profileService.removeCertification(event.certification);

      result.fold(
        (error) {
          Debug.error('ProfileBloc: Failed to remove certification - $error');
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error,
          ));
        },
        (profile) {
          Debug.success('ProfileBloc: Certification removed successfully');
          emit(state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
          ));
        },
      );
    } catch (e) {
      Debug.error('ProfileBloc: Unexpected error during certification removal - $e');
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'An unexpected error occurred while removing certification',
      ));
    }
  }

  Future<void> _onAddHighlightEvent(
    AddHighlightEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Debug.bloc('ProfileBloc: Adding highlight - ${event.highlight}');
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

      final result = await _profileService.addHighlight(event.highlight);

      result.fold(
        (error) {
          Debug.error('ProfileBloc: Failed to add highlight - $error');
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error,
          ));
        },
        (profile) {
          Debug.success('ProfileBloc: Highlight added successfully');
          emit(state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
          ));
        },
      );
    } catch (e) {
      Debug.error('ProfileBloc: Unexpected error during highlight add - $e');
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'An unexpected error occurred while adding highlight',
      ));
    }
  }

  Future<void> _onRemoveHighlightEvent(
    RemoveHighlightEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Debug.bloc('ProfileBloc: Removing highlight - ${event.highlight}');
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

      final result = await _profileService.removeHighlight(event.highlight);

      result.fold(
        (error) {
          Debug.error('ProfileBloc: Failed to remove highlight - $error');
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error,
          ));
        },
        (profile) {
          Debug.success('ProfileBloc: Highlight removed successfully');
          emit(state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
          ));
        },
      );
    } catch (e) {
      Debug.error('ProfileBloc: Unexpected error during highlight removal - $e');
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'An unexpected error occurred while removing highlight',
      ));
    }
  }

  Future<void> _onCheckProfileCompletionEvent(
    CheckProfileCompletionEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Debug.bloc('ProfileBloc: Checking profile completion');
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

      final result = await _profileService.hasCompleteRoleProfile();

      result.fold(
        (error) {
          Debug.error('ProfileBloc: Failed to check profile completion - $error');
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error,
          ));
        },
        (isComplete) {
          Debug.success('ProfileBloc: Profile completion checked - $isComplete');
          emit(state.copyWith(
            status: ProfileStatus.success,
            isProfileComplete: isComplete,
          ));
        },
      );
    } catch (e) {
      Debug.error('ProfileBloc: Unexpected error during profile completion check - $e');
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'An unexpected error occurred while checking profile completion',
      ));
    }
  }

  Future<void> _onGetUserRoleEvent(
    GetUserRoleEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Debug.bloc('ProfileBloc: Getting user role');
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

      final result = await _profileService.getUserRole();

      result.fold(
        (error) {
          Debug.error('ProfileBloc: Failed to get user role - $error');
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error,
          ));
        },
        (role) {
          Debug.success('ProfileBloc: User role retrieved - $role');
          emit(state.copyWith(
            status: ProfileStatus.success,
            userRole: role,
          ));
        },
      );
    } catch (e) {
      Debug.error('ProfileBloc: Unexpected error during user role fetch - $e');
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching user role',
      ));
    }
  }

  Future<void> _onRefreshProfileEvent(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    Debug.bloc('ProfileBloc: Refreshing profile');
    add(GetProfileEvent());
  }

  Future<void> _onClearProfileEvent(
    ClearProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    Debug.bloc('ProfileBloc: Clearing profile data');
    await LocalStorageService().deleteAuthToken(); 
    emit(state.copyWith(
      status: ProfileStatus.initial,
      clearProfile: true,
      clearError: true,
      isProfileComplete: null,
      userRole: null,
    ));
  }

  // Helper methods for easy access
  bool get isCurrentUserStudent => state.isStudent;
  bool get isCurrentUserCoach => state.isCoach;
  bool get hasCompleteProfile => state.isProfileComplete == true;
  String get currentUserRole => state.userRole ?? '';
  String get currentUserName => state.userName;
  String get currentUserEmail => state.userEmail;
}