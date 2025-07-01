import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/coach_service.dart';
import '../../model/coach.dart';
import '../../config/exceptions/coach.dart';
import '../../config/debug/debug.dart';

part 'coach_events.dart';
part 'coach_state.dart';

class CoachBloc extends Bloc<CoachEvent, CoachState> {
  final CoachService _coachService;

  CoachBloc({CoachService? coachService})
      : _coachService = coachService ?? CoachService(),
        super(const CoachState()) {
    on<InitialCoachEvent>(_onInitialCoachEvent);
    on<CreateCoachEvent>(_onCreateCoachEvent);
    on<GetAllCoachesEvent>(_onGetAllCoachesEvent);
    on<GetCoachByIdEvent>(_onGetCoachByIdEvent);
    on<GetCoachByUserIdEvent>(_onGetCoachByUserIdEvent);
    on<UpdateCoachEvent>(_onUpdateCoachEvent);
    on<DeleteCoachEvent>(_onDeleteCoachEvent);
    on<AddCertificationEvent>(_onAddCertificationEvent);
    on<RemoveCertificationEvent>(_onRemoveCertificationEvent);
    on<AddStudentEvent>(_onAddStudentEvent);
    on<RemoveStudentEvent>(_onRemoveStudentEvent);
    on<GetCoachesBySpecialtyEvent>(_onGetCoachesBySpecialtyEvent);
    on<GetCoachesByExperienceEvent>(_onGetCoachesByExperienceEvent);
    on<GetCoachStatsEvent>(_onGetCoachStatsEvent);
    on<SearchCoachesEvent>(_onSearchCoachesEvent);
    on<ClearCoachFiltersEvent>(_onClearCoachFiltersEvent);
  }

  Future<void> _onInitialCoachEvent(
    InitialCoachEvent event,
    Emitter<CoachState> emit,
  ) async {
    Debug.bloc('CoachBloc: Initial event triggered');
    emit(state.copyWith(
      status: CoachStatus.initial,
      clearCurrentCoach: true,
      clearError: true,
      clearStats: true,
      clearFilters: true,
    ));
  }

  Future<void> _onCreateCoachEvent(
    CreateCoachEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc('CoachBloc: Creating coach');
      Debug.info(
          'CoachBloc: Creating coach with name: ${event.name}, userId: ${event.userId}, email: ${event.email}, specialty: ${event.coachingSpecialty}, experience: ${event.experienceYears}, phone: ${event.phone}');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      final coach = await _coachService.createCoach(
        name: event.name,
        userId: event.userId,
        email: event.email,
        coachingSpecialty: event.coachingSpecialty,
        experienceYears: event.experienceYears,
        phone: event.phone,
        profilePicture: event.profilePicture,
        certifications: event.certifications,
        students: event.students,
      );

      final updatedCoaches = [...state.coaches, coach];
      final filteredCoaches = _applyFilters(updatedCoaches);

      emit(state.copyWith(
        status: CoachStatus.success,
        coaches: updatedCoaches,
        filteredCoaches: filteredCoaches,
        currentCoach: coach,
      ));

      Debug.success('CoachBloc: Coach created successfully');
    } on CoachException catch (e) {
      Debug.error('CoachBloc: Coach creation failed - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('CoachBloc: Unexpected error during coach creation - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: 'An unexpected error occurred while creating coach',
      ));
    }
  }

  Future<void> _onGetAllCoachesEvent(
    GetAllCoachesEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc('CoachBloc: Fetching all coaches');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      final coaches = await _coachService.getAllCoaches();
      final filteredCoaches = _applyFilters(coaches);

      emit(state.copyWith(
        status: CoachStatus.success,
        coaches: coaches,
        filteredCoaches: filteredCoaches,
      ));

      Debug.success(
          'CoachBloc: ${coaches.length} coaches fetched successfully');
    } on CoachException catch (e) {
      Debug.error('CoachBloc: Failed to fetch coaches - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('CoachBloc: Unexpected error during coaches fetch - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching coaches',
      ));
    }
  }

  Future<void> _onGetCoachByIdEvent(
    GetCoachByIdEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc('CoachBloc: Fetching coach by ID - ${event.coachId}');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      final coach = await _coachService.getCoachById(event.coachId);

      emit(state.copyWith(
        status: CoachStatus.success,
        currentCoach: coach,
      ));

      Debug.success('CoachBloc: Coach fetched successfully');
    } on CoachException catch (e) {
      Debug.error('CoachBloc: Failed to fetch coach - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('CoachBloc: Unexpected error during coach fetch - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching coach',
      ));
    }
  }

  Future<void> _onGetCoachByUserIdEvent(
    GetCoachByUserIdEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc('CoachBloc: Fetching coach by user ID - ${event.userId}');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      final coach = await _coachService.getCoachByUserId(event.userId);

      emit(state.copyWith(
        status: CoachStatus.success,
        currentCoach: coach,
      ));

      if (coach != null) {
        Debug.success('CoachBloc: Coach found for user ID');
      } else {
        Debug.info('CoachBloc: No coach found for user ID');
      }
    } on CoachException catch (e) {
      Debug.error('CoachBloc: Failed to fetch coach by user ID - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error(
          'CoachBloc: Unexpected error during coach fetch by user ID - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching coach',
      ));
    }
  }

  Future<void> _onUpdateCoachEvent(
    UpdateCoachEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc('CoachBloc: Updating coach - ${event.coachId}');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      final updatedCoach = await _coachService.updateCoach(
        coachId: event.coachId,
        name: event.name,
        email: event.email,
        phone: event.phone,
        profilePicture: event.profilePicture,
        coachingSpecialty: event.coachingSpecialty,
        experienceYears: event.experienceYears,
        certifications: event.certifications,
        students: event.students,
      );

      final updatedCoaches = state.coaches.map((coach) {
        return coach.id == event.coachId ? updatedCoach : coach;
      }).toList();

      final filteredCoaches = _applyFilters(updatedCoaches);

      emit(state.copyWith(
        status: CoachStatus.success,
        coaches: updatedCoaches,
        filteredCoaches: filteredCoaches,
        currentCoach: updatedCoach,
      ));

      Debug.success('CoachBloc: Coach updated successfully');
    } on CoachException catch (e) {
      Debug.error('CoachBloc: Coach update failed - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('CoachBloc: Unexpected error during coach update - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: 'An unexpected error occurred while updating coach',
      ));
    }
  }

  Future<void> _onDeleteCoachEvent(
    DeleteCoachEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc('CoachBloc: Deleting coach - ${event.coachId}');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      await _coachService.deleteCoach(event.coachId);

      final updatedCoaches =
          state.coaches.where((coach) => coach.id != event.coachId).toList();

      final filteredCoaches = _applyFilters(updatedCoaches);
      final shouldClearCurrent = state.currentCoach?.id == event.coachId;

      emit(state.copyWith(
        status: CoachStatus.success,
        coaches: updatedCoaches,
        filteredCoaches: filteredCoaches,
        clearCurrentCoach: shouldClearCurrent,
      ));

      Debug.success('CoachBloc: Coach deleted successfully');
    } on CoachException catch (e) {
      Debug.error('CoachBloc: Coach deletion failed - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('CoachBloc: Unexpected error during coach deletion - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: 'An unexpected error occurred while deleting coach',
      ));
    }
  }

  Future<void> _onAddCertificationEvent(
    AddCertificationEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc('CoachBloc: Adding certification to coach - ${event.coachId}');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      final updatedCoach = await _coachService.addCertification(
        event.coachId,
        event.certification,
      );

      _updateCoachInState(updatedCoach, emit);

      Debug.success('CoachBloc: Certification added successfully');
    } on CoachException catch (e) {
      Debug.error('CoachBloc: Add certification failed - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('CoachBloc: Unexpected error during add certification - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: 'An unexpected error occurred while adding certification',
      ));
    }
  }

  Future<void> _onRemoveCertificationEvent(
    RemoveCertificationEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc(
          'CoachBloc: Removing certification from coach - ${event.coachId}');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      final updatedCoach = await _coachService.removeCertification(
        event.coachId,
        event.certification,
      );

      _updateCoachInState(updatedCoach, emit);

      Debug.success('CoachBloc: Certification removed successfully');
    } on CoachException catch (e) {
      Debug.error('CoachBloc: Remove certification failed - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error(
          'CoachBloc: Unexpected error during remove certification - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage:
            'An unexpected error occurred while removing certification',
      ));
    }
  }

  Future<void> _onAddStudentEvent(
    AddStudentEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc('CoachBloc: Adding student to coach - ${event.coachId}');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      final updatedCoach = await _coachService.addStudent(
        event.coachId,
        event.studentId,
      );

      _updateCoachInState(updatedCoach, emit);

      Debug.success('CoachBloc: Student added successfully');
    } on CoachException catch (e) {
      Debug.error('CoachBloc: Add student failed - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('CoachBloc: Unexpected error during add student - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: 'An unexpected error occurred while adding student',
      ));
    }
  }

  Future<void> _onRemoveStudentEvent(
    RemoveStudentEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc('CoachBloc: Removing student from coach - ${event.coachId}');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      final updatedCoach = await _coachService.removeStudent(
        event.coachId,
        event.studentId,
      );

      _updateCoachInState(updatedCoach, emit);

      Debug.success('CoachBloc: Student removed successfully');
    } on CoachException catch (e) {
      Debug.error('CoachBloc: Remove student failed - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('CoachBloc: Unexpected error during remove student - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: 'An unexpected error occurred while removing student',
      ));
    }
  }

  Future<void> _onGetCoachesBySpecialtyEvent(
    GetCoachesBySpecialtyEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc(
          'CoachBloc: Fetching coaches by specialty - ${event.specialty}');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      final coaches =
          await _coachService.getCoachesBySpecialty(event.specialty);

      emit(state.copyWith(
        status: CoachStatus.success,
        coaches: coaches,
        filteredCoaches: coaches,
        selectedSpecialty: event.specialty,
      ));

      Debug.success('CoachBloc: Coaches by specialty fetched successfully');
    } on CoachException catch (e) {
      Debug.error(
          'CoachBloc: Failed to fetch coaches by specialty - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error(
          'CoachBloc: Unexpected error during coaches by specialty fetch - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage:
            'An unexpected error occurred while fetching coaches by specialty',
      ));
    }
  }

  Future<void> _onGetCoachesByExperienceEvent(
    GetCoachesByExperienceEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc(
          'CoachBloc: Fetching coaches by experience - min:${event.minYears}, max:${event.maxYears}');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      final coaches = await _coachService.getCoachesByExperience(
        minYears: event.minYears,
        maxYears: event.maxYears,
      );

      emit(state.copyWith(
        status: CoachStatus.success,
        coaches: coaches,
        filteredCoaches: coaches,
        minExperience: event.minYears,
        maxExperience: event.maxYears,
      ));

      Debug.success('CoachBloc: Coaches by experience fetched successfully');
    } on CoachException catch (e) {
      Debug.error(
          'CoachBloc: Failed to fetch coaches by experience - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error(
          'CoachBloc: Unexpected error during coaches by experience fetch - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage:
            'An unexpected error occurred while fetching coaches by experience',
      ));
    }
  }

  Future<void> _onGetCoachStatsEvent(
    GetCoachStatsEvent event,
    Emitter<CoachState> emit,
  ) async {
    try {
      Debug.bloc('CoachBloc: Fetching coach stats - ${event.coachId}');
      emit(state.copyWith(status: CoachStatus.loading, clearError: true));

      final stats = await _coachService.getCoachStats(event.coachId);

      emit(state.copyWith(
        status: CoachStatus.success,
        coachStats: stats,
      ));

      Debug.success('CoachBloc: Coach stats fetched successfully');
    } on CoachException catch (e) {
      Debug.error('CoachBloc: Failed to fetch coach stats - ${e.message}');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Debug.error('CoachBloc: Unexpected error during coach stats fetch - $e');
      emit(state.copyWith(
        status: CoachStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching coach stats',
      ));
    }
  }

  Future<void> _onSearchCoachesEvent(
    SearchCoachesEvent event,
    Emitter<CoachState> emit,
  ) async {
    Debug.bloc('CoachBloc: Searching coaches with query - "${event.query}"');

    final filteredCoaches = _applyFilters(
      state.coaches,
      searchQuery: event.query,
    );

    emit(state.copyWith(
      searchQuery: event.query,
      filteredCoaches: filteredCoaches,
    ));
  }

  Future<void> _onClearCoachFiltersEvent(
    ClearCoachFiltersEvent event,
    Emitter<CoachState> emit,
  ) async {
    Debug.bloc('CoachBloc: Clearing all filters');

    emit(state.copyWith(
      filteredCoaches: state.coaches,
      clearFilters: true,
    ));
  }

  void _updateCoachInState(Coach updatedCoach, Emitter<CoachState> emit) {
    final updatedCoaches = state.coaches.map((coach) {
      return coach.id == updatedCoach.id ? updatedCoach : coach;
    }).toList();

    final filteredCoaches = _applyFilters(updatedCoaches);

    emit(state.copyWith(
      status: CoachStatus.success,
      coaches: updatedCoaches,
      filteredCoaches: filteredCoaches,
      currentCoach: updatedCoach,
    ));
  }

  List<Coach> _applyFilters(
    List<Coach> coaches, {
    String? searchQuery,
    String? selectedSpecialty,
    int? minExperience,
    int? maxExperience,
  }) {
    var filtered = coaches;

    final query = searchQuery ?? state.searchQuery;
    final specialty = selectedSpecialty ?? state.selectedSpecialty;
    final minExp = minExperience ?? state.minExperience;
    final maxExp = maxExperience ?? state.maxExperience;

    // Apply search filter
    if (query.isNotEmpty) {
      filtered = filtered.where((coach) {
        final queryLower = query.toLowerCase();
        return coach.name.toLowerCase().contains(queryLower) ||
            coach.email.toLowerCase().contains(queryLower) ||
            coach.coachingSpecialty.toLowerCase().contains(queryLower);
      }).toList();
    }

    // Apply specialty filter
    if (specialty != null) {
      filtered = filtered
          .where((coach) => coach.coachingSpecialty
              .toLowerCase()
              .contains(specialty.toLowerCase()))
          .toList();
    }

    // Apply experience filters
    if (minExp != null) {
      filtered =
          filtered.where((coach) => coach.experienceYears >= minExp).toList();
    }

    if (maxExp != null) {
      filtered =
          filtered.where((coach) => coach.experienceYears <= maxExp).toList();
    }

    return filtered;
  }

  // Helper getters for UI
  int get totalCoachesCount => state.coaches.length;
  int get filteredCoachesCount => state.filteredCoaches.length;
  List<String> get availableSpecialties =>
      state.coaches.map((c) => c.coachingSpecialty).toSet().toList();
}
