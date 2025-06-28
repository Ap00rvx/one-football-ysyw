part of 'competetion_bloc.dart';

enum CompetetionStatus { initial, loading, success, failure, refreshing }

class CompetetionState extends Equatable {
  final CompetetionStatus status;
  final CompetetionsResponse? competitionsResponse;
  final List<Competition> competitions;
  final List<Competition> filteredCompetitions;
  final String? errorMessage;
  final Type? selectedType;
  final Plan? selectedPlan;
  final String searchQuery;

  const CompetetionState({
    this.status = CompetetionStatus.initial,
    this.competitionsResponse,
    this.competitions = const [],
    this.filteredCompetitions = const [],
    this.errorMessage,
    this.selectedType,
    this.selectedPlan,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
    status,
    competitionsResponse,
    competitions,
    filteredCompetitions,
    errorMessage,
    selectedType,
    selectedPlan,
    searchQuery,
  ];

  bool get isInitial => status == CompetetionStatus.initial;
  bool get isLoading => status == CompetetionStatus.loading;
  bool get isSuccess => status == CompetetionStatus.success;
  bool get isFailure => status == CompetetionStatus.failure;
  bool get isRefreshing => status == CompetetionStatus.refreshing;

  bool get hasFilters => selectedType != null || selectedPlan != null || searchQuery.isNotEmpty;

  CompetetionState copyWith({
    CompetetionStatus? status,
    CompetetionsResponse? competitionsResponse,
    List<Competition>? competitions,
    List<Competition>? filteredCompetitions,
    String? errorMessage,
    Type? selectedType,
    Plan? selectedPlan,
    String? searchQuery,
    bool clearError = false,
    bool clearFilters = false,
  }) {
    return CompetetionState(
      status: status ?? this.status,
      competitionsResponse: competitionsResponse ?? this.competitionsResponse,
      competitions: competitions ?? this.competitions,
      filteredCompetitions: filteredCompetitions ?? this.filteredCompetitions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedType: clearFilters ? null : (selectedType ?? this.selectedType),
      selectedPlan: clearFilters ? null : (selectedPlan ?? this.selectedPlan),
      searchQuery: clearFilters ? '' : (searchQuery ?? this.searchQuery),
    );
  }
}