part of 'competetion_bloc.dart';

abstract class CompetetionEvent extends Equatable {
  const CompetetionEvent();

  @override
  List<Object> get props => [];
}

class InitialCompetetionEvent extends CompetetionEvent {}

class GetCompetitionsEvent extends CompetetionEvent {}

class RefreshCompetitionsEvent extends CompetetionEvent {}

class FilterCompetitionsByTypeEvent extends CompetetionEvent {
  final Type? competitionType;

  const FilterCompetitionsByTypeEvent(this.competitionType);

  @override
  List<Object> get props => [competitionType ?? ''];
}

class FilterCompetitionsByPlanEvent extends CompetetionEvent {
  final Plan? plan;

  const FilterCompetitionsByPlanEvent(this.plan);

  @override
  List<Object> get props => [plan ?? ''];
}

class SearchCompetitionsEvent extends CompetetionEvent {
  final String query;

  const SearchCompetitionsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class ClearFiltersEvent extends CompetetionEvent {}