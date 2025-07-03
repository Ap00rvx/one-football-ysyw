part of 'schedule_bloc.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class InitialScheduleEvent extends ScheduleEvent {}

class CreateScheduleEvent extends ScheduleEvent {
  final String title;
  final String? description;
  final DateTime date;
  final DateTime? endDate;
  final String location;
  final ScheduleType type;
  final int? maxAttendees;
  final String? notes;
  final List<String>? attendees;

  const CreateScheduleEvent({
    required this.title,
    this.description,
    required this.date,
    this.endDate,
    required this.location,
    required this.type,
    this.maxAttendees,
    this.notes,
    this.attendees,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    date,
    endDate,
    location,
    type,
    maxAttendees,
    notes,
    attendees,
  ];
}

class GetAllSchedulesEvent extends ScheduleEvent {
  final bool upcomingOnly;

  const GetAllSchedulesEvent({this.upcomingOnly = false});

  @override
  List<Object?> get props => [upcomingOnly];
}

class GetMySchedulesEvent extends ScheduleEvent {}

class GetMyAttendingSchedulesEvent extends ScheduleEvent {}

class GetCoachSchedulesEvent extends ScheduleEvent {
  final String coachId;

  const GetCoachSchedulesEvent(this.coachId);

  @override
  List<Object?> get props => [coachId];
}

class GetStudentSchedulesEvent extends ScheduleEvent {
  final String studentId;

  const GetStudentSchedulesEvent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class GetScheduleByIdEvent extends ScheduleEvent {
  final String scheduleId;

  const GetScheduleByIdEvent(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

class UpdateScheduleEvent extends ScheduleEvent {
  final String scheduleId;
  final String? title;
  final String? description;
  final DateTime? date;
  final DateTime? endDate;
  final String? location;
  final ScheduleType? type;
  final int? maxAttendees;
  final ScheduleStatus? status;
  final String? notes;
  final List<String>? attendees;

  const UpdateScheduleEvent({
    required this.scheduleId,
    this.title,
    this.description,
    this.date,
    this.endDate,
    this.location,
    this.type,
    this.maxAttendees,
    this.status,
    this.notes,
    this.attendees,
  });

  @override
  List<Object?> get props => [
    scheduleId,
    title,
    description,
    date,
    endDate,
    location,
    type,
    maxAttendees,
    status,
    notes,
    attendees,
  ];
}

class DeleteScheduleEvent extends ScheduleEvent {
  final String scheduleId;

  const DeleteScheduleEvent(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

class AttendScheduleEvent extends ScheduleEvent {
  final String scheduleId;

  const AttendScheduleEvent(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

class AttendScheduleWithUsersEvent extends ScheduleEvent {
  final String scheduleId;
  final List<String> userIds;

  const AttendScheduleWithUsersEvent(this.scheduleId, this.userIds);

  @override
  List<Object?> get props => [scheduleId, userIds];
}

class LeaveScheduleEvent extends ScheduleEvent {
  final String scheduleId;

  const LeaveScheduleEvent(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

class CompleteScheduleEvent extends ScheduleEvent {
  final String scheduleId;
  final String? notes;

  const CompleteScheduleEvent(this.scheduleId, {this.notes});

  @override
  List<Object?> get props => [scheduleId, notes];
}

class CancelScheduleEvent extends ScheduleEvent {
  final String scheduleId;
  final String? reason;

  const CancelScheduleEvent(this.scheduleId, {this.reason});

  @override
  List<Object?> get props => [scheduleId, reason];
}

class RescheduleScheduleEvent extends ScheduleEvent {
  final String scheduleId;
  final DateTime newDate;
  final DateTime? newEndDate;
  final String? newLocation;

  const RescheduleScheduleEvent({
    required this.scheduleId,
    required this.newDate,
    this.newEndDate,
    this.newLocation,
  });

  @override
  List<Object?> get props => [scheduleId, newDate, newEndDate, newLocation];
}

class GetUpcomingSchedulesEvent extends ScheduleEvent {}

class GetTodaySchedulesEvent extends ScheduleEvent {}

class CheckCanEditScheduleEvent extends ScheduleEvent {
  final String scheduleId;

  const CheckCanEditScheduleEvent(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

class CheckIsAttendingScheduleEvent extends ScheduleEvent {
  final String scheduleId;

  const CheckIsAttendingScheduleEvent(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

class RefreshSchedulesEvent extends ScheduleEvent {}

class ClearScheduleEvent extends ScheduleEvent {}

class ClearScheduleErrorEvent extends ScheduleEvent {}