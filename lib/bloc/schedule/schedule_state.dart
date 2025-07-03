part of 'schedule_bloc.dart';

enum ScheduleBlocStatus { initial, loading, success, failure }

class ScheduleState extends Equatable {
  final ScheduleBlocStatus status;
  final List<Schedule> schedules;
  final Schedule? selectedSchedule;
  final String? errorMessage;
  final bool? canEdit;
  final bool? isAttending;
  final String? lastAction;

  const ScheduleState({
    this.status = ScheduleBlocStatus.initial,
    this.schedules = const [],
    this.selectedSchedule,
    this.errorMessage,
    this.canEdit,
    this.isAttending,
    this.lastAction,
  });

  @override
  List<Object?> get props => [
    status,
    schedules,
    selectedSchedule,
    errorMessage,
    canEdit,
    isAttending,
    lastAction,
  ];

  bool get isInitial => status == ScheduleBlocStatus.initial;
  bool get isLoading => status == ScheduleBlocStatus.loading;
  bool get isSuccess => status == ScheduleBlocStatus.success;
  bool get isFailure => status == ScheduleBlocStatus.failure;

  // Helper getters
  bool get hasSchedules => schedules.isNotEmpty;
  bool get hasSelectedSchedule => selectedSchedule != null;
  int get schedulesCount => schedules.length;

  // Filter helpers
  List<Schedule> get upcomingSchedules {
    final now = DateTime.now();
    return schedules.where((s) => s.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Schedule> get todaySchedules {
    final now = DateTime.now();
    return schedules.where((s) => 
      s.date.year == now.year &&
      s.date.month == now.month &&
      s.date.day == now.day
    ).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Schedule> get pastSchedules {
    final now = DateTime.now();
    return schedules.where((s) => s.date.isBefore(now)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Schedule> get scheduledSchedules =>
      schedules.where((s) => s.status == ScheduleStatus.scheduled).toList();

  List<Schedule> get completedSchedules =>
      schedules.where((s) => s.status == ScheduleStatus.completed).toList();

  List<Schedule> get cancelledSchedules =>
      schedules.where((s) => s.status == ScheduleStatus.cancelled).toList();

  // Schedule type filters
  List<Schedule> get sessions =>
      schedules.where((s) => s.type == ScheduleType.session).toList();

  List<Schedule> get games =>
      schedules.where((s) => s.type == ScheduleType.game).toList();

  List<Schedule> get practices =>
      schedules.where((s) => s.type == ScheduleType.practice).toList();

  List<Schedule> get meetings =>
      schedules.where((s) => s.type == ScheduleType.meeting).toList();

  ScheduleState copyWith({
    ScheduleBlocStatus? status,
    List<Schedule>? schedules,
    Schedule? selectedSchedule,
    String? errorMessage,
    bool? canEdit,
    bool? isAttending,
    String? lastAction,
    bool clearError = false,
    bool clearSelected = false,
    bool clearSchedules = false,
    bool clearCanEdit = false,
    bool clearIsAttending = false,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      schedules: clearSchedules ? [] : (schedules ?? this.schedules),
      selectedSchedule: clearSelected ? null : (selectedSchedule ?? this.selectedSchedule),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      canEdit: clearCanEdit ? null : (canEdit ?? this.canEdit),
      isAttending: clearIsAttending ? null : (isAttending ?? this.isAttending),
      lastAction: lastAction ?? this.lastAction,
    );
  }
}