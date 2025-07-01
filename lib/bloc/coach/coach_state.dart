part of 'coach_bloc.dart';

enum CoachStatus { initial, loading, success, failure }

class CoachState extends Equatable {
  final CoachStatus status;
  final List<Coach> coaches;
  final List<Coach> filteredCoaches;
  final Coach? currentCoach;
  final String? errorMessage;
  final Map<String, dynamic>? coachStats;
  final String searchQuery;
  final String? selectedSpecialty;
  final int? minExperience;
  final int? maxExperience;

  const CoachState({
    this.status = CoachStatus.initial,
    this.coaches = const [],
    this.filteredCoaches = const [],
    this.currentCoach,
    this.errorMessage,
    this.coachStats,
    this.searchQuery = '',
    this.selectedSpecialty,
    this.minExperience,
    this.maxExperience,
  });

  @override
  List<Object?> get props => [
    status,
    coaches,
    filteredCoaches,
    currentCoach,
    errorMessage,
    coachStats,
    searchQuery,
    selectedSpecialty,
    minExperience,
    maxExperience,
  ];

  bool get isInitial => status == CoachStatus.initial;
  bool get isLoading => status == CoachStatus.loading;
  bool get isSuccess => status == CoachStatus.success;
  bool get isFailure => status == CoachStatus.failure;

  bool get hasFilters => 
      searchQuery.isNotEmpty || 
      selectedSpecialty != null || 
      minExperience != null || 
      maxExperience != null;

  CoachState copyWith({
    CoachStatus? status,
    List<Coach>? coaches,
    List<Coach>? filteredCoaches,
    Coach? currentCoach,
    String? errorMessage,
    Map<String, dynamic>? coachStats,
    String? searchQuery,
    String? selectedSpecialty,
    int? minExperience,
    int? maxExperience,
    bool clearCurrentCoach = false,
    bool clearError = false,
    bool clearStats = false,
    bool clearFilters = false,
  }) {
    return CoachState(
      status: status ?? this.status,
      coaches: coaches ?? this.coaches,
      filteredCoaches: filteredCoaches ?? this.filteredCoaches,
      currentCoach: clearCurrentCoach ? null : (currentCoach ?? this.currentCoach),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      coachStats: clearStats ? null : (coachStats ?? this.coachStats),
      searchQuery: clearFilters ? '' : (searchQuery ?? this.searchQuery),
      selectedSpecialty: clearFilters ? null : (selectedSpecialty ?? this.selectedSpecialty),
      minExperience: clearFilters ? null : (minExperience ?? this.minExperience),
      maxExperience: clearFilters ? null : (maxExperience ?? this.maxExperience),
    );
  }
}