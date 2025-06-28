import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/match_data_service.dart';
import '../../model/competetion_response_model.dart';
import '../../config/debug/debug.dart';

part 'competetion_events.dart';
part 'competetion_state.dart';

class CompetetionBloc extends Bloc<CompetetionEvent, CompetetionState> {
  final MatchDataService _matchDataService;

  CompetetionBloc({MatchDataService? matchDataService})
      : _matchDataService = matchDataService ?? MatchDataService(),
        super(const CompetetionState()) {
    on<InitialCompetetionEvent>(_onInitialCompetetionEvent);
    on<GetCompetitionsEvent>(_onGetCompetitionsEvent);
    on<RefreshCompetitionsEvent>(_onRefreshCompetitionsEvent);
    on<FilterCompetitionsByTypeEvent>(_onFilterCompetitionsByTypeEvent);
    on<FilterCompetitionsByPlanEvent>(_onFilterCompetitionsByPlanEvent);
    on<SearchCompetitionsEvent>(_onSearchCompetitionsEvent);
    on<ClearFiltersEvent>(_onClearFiltersEvent);
  }

  Future<void> _onInitialCompetetionEvent(
    InitialCompetetionEvent event,
    Emitter<CompetetionState> emit,
  ) async {
    Debug.bloc('CompetetionBloc: Initial event triggered');
    emit(state.copyWith(
      status: CompetetionStatus.initial,
      clearError: true,
      clearFilters: true,
    ));
  }

  Future<void> _onGetCompetitionsEvent(
    GetCompetitionsEvent event,
    Emitter<CompetetionState> emit,
  ) async {
    try {
      Debug.bloc('CompetetionBloc: Fetching competitions');
      emit(state.copyWith(status: CompetetionStatus.loading, clearError: true));

      final result = await _matchDataService.getCompetitions();

      result.fold(
        (error) {
          Debug.error('CompetetionBloc: Failed to fetch competitions - $error');
          emit(state.copyWith(
            status: CompetetionStatus.failure,
            errorMessage: error,
          ));
        },
        (competitionsResponse) {
          Debug.success('CompetetionBloc: ${competitionsResponse.competitions.length} competitions fetched successfully');
          
          emit(state.copyWith(
            status: CompetetionStatus.success,
            competitionsResponse: competitionsResponse,
            competitions: competitionsResponse.competitions,
            filteredCompetitions: competitionsResponse.competitions,
          ));
        },
      );
    } catch (e) {
      Debug.error('CompetetionBloc: Unexpected error during competition fetch - $e');
      emit(state.copyWith(
        status: CompetetionStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching competitions',
      ));
    }
  }

  Future<void> _onRefreshCompetitionsEvent(
    RefreshCompetitionsEvent event,
    Emitter<CompetetionState> emit,
  ) async {
    try {
      Debug.bloc('CompetetionBloc: Refreshing competitions');
      emit(state.copyWith(status: CompetetionStatus.refreshing, clearError: true));

      final result = await _matchDataService.getCompetitions();

      result.fold(
        (error) {
          Debug.error('CompetetionBloc: Failed to refresh competitions - $error');
          emit(state.copyWith(
            status: CompetetionStatus.failure,
            errorMessage: error,
          ));
        },
        (competitionsResponse) {
          Debug.success('CompetetionBloc: Competitions refreshed successfully');
          
          final filteredCompetitions = _applyFilters(
            competitionsResponse.competitions,
            state.selectedType,
            state.selectedPlan,
            state.searchQuery,
          );

          emit(state.copyWith(
            status: CompetetionStatus.success,
            competitionsResponse: competitionsResponse,
            competitions: competitionsResponse.competitions,
            filteredCompetitions: filteredCompetitions,
          ));
        },
      );
    } catch (e) {
      Debug.error('CompetetionBloc: Unexpected error during competition refresh - $e');
      emit(state.copyWith(
        status: CompetetionStatus.failure,
        errorMessage: 'An unexpected error occurred while refreshing competitions',
      ));
    }
  }

  Future<void> _onFilterCompetitionsByTypeEvent(
    FilterCompetitionsByTypeEvent event,
    Emitter<CompetetionState> emit,
  ) async {
    Debug.bloc('CompetetionBloc: Filtering competitions by type - ${event.competitionType}');
    
    final filteredCompetitions = _applyFilters(
      state.competitions,
      event.competitionType,
      state.selectedPlan,
      state.searchQuery,
    );

    emit(state.copyWith(
      selectedType: event.competitionType,
      filteredCompetitions: filteredCompetitions,
    ));
  }

  Future<void> _onFilterCompetitionsByPlanEvent(
    FilterCompetitionsByPlanEvent event,
    Emitter<CompetetionState> emit,
  ) async {
    Debug.bloc('CompetetionBloc: Filtering competitions by plan - ${event.plan}');
    
    final filteredCompetitions = _applyFilters(
      state.competitions,
      state.selectedType,
      event.plan,
      state.searchQuery,
    );

    emit(state.copyWith(
      selectedPlan: event.plan,
      filteredCompetitions: filteredCompetitions,
    ));
  }

  Future<void> _onSearchCompetitionsEvent(
    SearchCompetitionsEvent event,
    Emitter<CompetetionState> emit,
  ) async {
    Debug.bloc('CompetetionBloc: Searching competitions with query - "${event.query}"');
    
    final filteredCompetitions = _applyFilters(
      state.competitions,
      state.selectedType,
      state.selectedPlan,
      event.query,
    );

    emit(state.copyWith(
      searchQuery: event.query,
      filteredCompetitions: filteredCompetitions,
    ));
  }

  Future<void> _onClearFiltersEvent(
    ClearFiltersEvent event,
    Emitter<CompetetionState> emit,
  ) async {
    Debug.bloc('CompetetionBloc: Clearing all filters');
    
    emit(state.copyWith(
      filteredCompetitions: state.competitions,
      clearFilters: true,
    ));
  }

  List<Competition> _applyFilters(
    List<Competition> competitions,
    Type? selectedType,
    Plan? selectedPlan,
    String searchQuery,
  ) {
    var filtered = competitions;

    // Filter by type
    if (selectedType != null) {
      filtered = filtered.where((competition) => competition.type == selectedType).toList();
    }

    // Filter by plan
    if (selectedPlan != null) {
      filtered = filtered.where((competition) => competition.plan == selectedPlan).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((competition) {
        return competition.name.toLowerCase().contains(query) ||
               competition.code.toLowerCase().contains(query) ||
               competition.area.name.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  // Helper methods for UI
  List<Competition> get leagueCompetitions {
    return state.competitions.where((c) => c.type == Type.LEAGUE).toList();
  }

  List<Competition> get cupCompetitions {
    return state.competitions.where((c) => c.type == Type.CUP).toList();
  }

  List<Competition> get tierOneCompetitions {
    return state.competitions.where((c) => c.plan == Plan.TIER_ONE).toList();
  }

  List<Competition> get tierFourCompetitions {
    return state.competitions.where((c) => c.plan == Plan.TIER_FOUR).toList();
  }

  int get totalCompetitionsCount => state.competitions.length;
  int get filteredCompetitionsCount => state.filteredCompetitions.length;
}