import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/schedule_service.dart';
import '../../model/schedule.dart';
import '../../config/debug/debug.dart';

part 'schedule_events.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleService _scheduleService;

  ScheduleBloc({ScheduleService? scheduleService})
      : _scheduleService = scheduleService ?? ScheduleService(),
        super(const ScheduleState()) {
    on<InitialScheduleEvent>(_onInitialScheduleEvent);
    on<CreateScheduleEvent>(_onCreateScheduleEvent);
    on<GetAllSchedulesEvent>(_onGetAllSchedulesEvent);
    on<GetMySchedulesEvent>(_onGetMySchedulesEvent);
    on<GetMyAttendingSchedulesEvent>(_onGetMyAttendingSchedulesEvent);
    on<GetCoachSchedulesEvent>(_onGetCoachSchedulesEvent);
    on<GetStudentSchedulesEvent>(_onGetStudentSchedulesEvent);
    on<GetScheduleByIdEvent>(_onGetScheduleByIdEvent);
    on<UpdateScheduleEvent>(_onUpdateScheduleEvent);
    on<DeleteScheduleEvent>(_onDeleteScheduleEvent);
    on<AttendScheduleEvent>(_onAttendScheduleEvent);
    on<AttendScheduleWithUsersEvent>(_onAttendScheduleWithUsersEvent);
    on<LeaveScheduleEvent>(_onLeaveScheduleEvent);
    on<CompleteScheduleEvent>(_onCompleteScheduleEvent);
    on<CancelScheduleEvent>(_onCancelScheduleEvent);
    on<RescheduleScheduleEvent>(_onRescheduleScheduleEvent);
    on<GetUpcomingSchedulesEvent>(_onGetUpcomingSchedulesEvent);
    on<GetTodaySchedulesEvent>(_onGetTodaySchedulesEvent);
    on<CheckCanEditScheduleEvent>(_onCheckCanEditScheduleEvent);
    on<CheckIsAttendingScheduleEvent>(_onCheckIsAttendingScheduleEvent);
    on<RefreshSchedulesEvent>(_onRefreshSchedulesEvent);
    on<ClearScheduleEvent>(_onClearScheduleEvent);
    on<ClearScheduleErrorEvent>(_onClearScheduleErrorEvent);
  }

  Future<void> _onInitialScheduleEvent(
    InitialScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    Debug.bloc('ScheduleBloc: Initial event triggered');
    emit(state.copyWith(
      status: ScheduleBlocStatus.initial,
      clearError: true,
      clearSchedules: true,
      clearSelected: true,
      clearCanEdit: true,
      clearIsAttending: true,
    ));
  }

  Future<void> _onCreateScheduleEvent(
    CreateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Creating schedule - ${event.title}');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.createSchedule(
        title: event.title,
        description: event.description,
        date: event.date,
        endDate: event.endDate,
        location: event.location,
        type: event.type,
        maxAttendees: event.maxAttendees,
        notes: event.notes,
        attendees: event.attendees,
      );

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to create schedule - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'create_failed',
          ));
        },
        (schedule) {
          Debug.success('ScheduleBloc: Schedule created successfully');
          final updatedSchedules = [...state.schedules, schedule];
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: updatedSchedules,
            selectedSchedule: schedule,
            lastAction: 'create_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during schedule creation - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while creating schedule',
        lastAction: 'create_error',
      ));
    }
  }

  Future<void> _onGetAllSchedulesEvent(
    GetAllSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Fetching all schedules (upcoming: ${event.upcomingOnly})');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.getAllSchedules(
        upcomingOnly: event.upcomingOnly,
      );

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to fetch schedules - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'fetch_all_failed',
          ));
        },
        (schedules) {
          Debug.success('ScheduleBloc: Schedules fetched successfully (${schedules.length})');
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: schedules,
            lastAction: 'fetch_all_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during schedules fetch - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching schedules',
        lastAction: 'fetch_all_error',
      ));
    }
  }

  Future<void> _onGetMySchedulesEvent(
    GetMySchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Fetching my schedules');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.getMySchedules();

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to fetch my schedules - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'fetch_my_failed',
          ));
        },
        (schedules) {
          Debug.success('ScheduleBloc: My schedules fetched successfully (${schedules.length})');
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: schedules,
            lastAction: 'fetch_my_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during my schedules fetch - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching my schedules',
        lastAction: 'fetch_my_error',
      ));
    }
  }

  Future<void> _onGetMyAttendingSchedulesEvent(
    GetMyAttendingSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Fetching my attending schedules');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.getMyAttendingSchedules();

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to fetch attending schedules - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'fetch_attending_failed',
          ));
        },
        (schedules) {
          Debug.success('ScheduleBloc: Attending schedules fetched successfully (${schedules.length})');
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: schedules,
            lastAction: 'fetch_attending_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during attending schedules fetch - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching attending schedules',
        lastAction: 'fetch_attending_error',
      ));
    }
  }

  Future<void> _onGetCoachSchedulesEvent(
    GetCoachSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Fetching coach schedules - ${event.coachId}');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.getCoachSchedules(event.coachId);

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to fetch coach schedules - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'fetch_coach_failed',
          ));
        },
        (schedules) {
          Debug.success('ScheduleBloc: Coach schedules fetched successfully (${schedules.length})');
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: schedules,
            lastAction: 'fetch_coach_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during coach schedules fetch - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching coach schedules',
        lastAction: 'fetch_coach_error',
      ));
    }
  }

  Future<void> _onGetStudentSchedulesEvent(
    GetStudentSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Fetching student schedules - ${event.studentId}');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.getStudentSchedules(event.studentId);

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to fetch student schedules - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'fetch_student_failed',
          ));
        },
        (schedules) {
          Debug.success('ScheduleBloc: Student schedules fetched successfully (${schedules.length})');
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: schedules,
            lastAction: 'fetch_student_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during student schedules fetch - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching student schedules',
        lastAction: 'fetch_student_error',
      ));
    }
  }

  Future<void> _onGetScheduleByIdEvent(
    GetScheduleByIdEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Fetching schedule by ID - ${event.scheduleId}');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.getScheduleById(event.scheduleId);

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to fetch schedule - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'fetch_by_id_failed',
          ));
        },
        (schedule) {
          Debug.success('ScheduleBloc: Schedule fetched successfully');
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            selectedSchedule: schedule,
            lastAction: 'fetch_by_id_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during schedule fetch - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching schedule',
        lastAction: 'fetch_by_id_error',
      ));
    }
  }

  Future<void> _onUpdateScheduleEvent(
    UpdateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Updating schedule - ${event.scheduleId}');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.updateSchedule(
        scheduleId: event.scheduleId,
        title: event.title,
        description: event.description,
        date: event.date,
        endDate: event.endDate,
        location: event.location,
        type: event.type,
        status: event.status,
        maxAttendees: event.maxAttendees,
        notes: event.notes,
        attendees: event.attendees,
      );

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to update schedule - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'update_failed',
          ));
        },
        (schedule) {
          Debug.success('ScheduleBloc: Schedule updated successfully');
          // Update the schedule in the list
          final updatedSchedules = state.schedules.map((s) =>
              s.id == schedule.id ? schedule : s).toList();
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: updatedSchedules,
            selectedSchedule: schedule,
            lastAction: 'update_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during schedule update - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while updating schedule',
        lastAction: 'update_error',
      ));
    }
  }

  Future<void> _onDeleteScheduleEvent(
    DeleteScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Deleting schedule - ${event.scheduleId}');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.deleteSchedule(event.scheduleId);

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to delete schedule - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'delete_failed',
          ));
        },
        (message) {
          Debug.success('ScheduleBloc: Schedule deleted successfully');
          // Remove the schedule from the list
          final updatedSchedules = state.schedules
              .where((s) => s.id != event.scheduleId)
              .toList();
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: updatedSchedules,
            clearSelected: true,
            lastAction: 'delete_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during schedule deletion - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while deleting schedule',
        lastAction: 'delete_error',
      ));
    }
  }

  Future<void> _onAttendScheduleEvent(
    AttendScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Attending schedule - ${event.scheduleId}');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.attendSchedule(event.scheduleId);

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to attend schedule - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'attend_failed',
          ));
        },
        (schedule) {
          Debug.success('ScheduleBloc: Schedule attended successfully');
          // Update the schedule in the list
          final updatedSchedules = state.schedules.map((s) =>
              s.id == schedule.id ? schedule : s).toList();
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: updatedSchedules,
            selectedSchedule: schedule,
            isAttending: true,
            lastAction: 'attend_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during schedule attendance - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while attending schedule',
        lastAction: 'attend_error',
      ));
    }
  }

  Future<void> _onAttendScheduleWithUsersEvent(
    AttendScheduleWithUsersEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Adding users to schedule - ${event.scheduleId}');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.attendScheduleWithUsers(
        event.scheduleId,
        event.userIds,
      );

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to add users to schedule - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'attend_users_failed',
          ));
        },
        (schedule) {
          Debug.success('ScheduleBloc: Users added to schedule successfully');
          // Update the schedule in the list
          final updatedSchedules = state.schedules.map((s) =>
              s.id == schedule.id ? schedule : s).toList();
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: updatedSchedules,
            selectedSchedule: schedule,
            lastAction: 'attend_users_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during users attendance - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while adding users to schedule',
        lastAction: 'attend_users_error',
      ));
    }
  }

  Future<void> _onLeaveScheduleEvent(
    LeaveScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Leaving schedule - ${event.scheduleId}');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.leaveSchedule(event.scheduleId);

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to leave schedule - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'leave_failed',
          ));
        },
        (schedule) {
          Debug.success('ScheduleBloc: Left schedule successfully');
          // Update the schedule in the list
          final updatedSchedules = state.schedules.map((s) =>
              s.id == schedule.id ? schedule : s).toList();
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: updatedSchedules,
            selectedSchedule: schedule,
            isAttending: false,
            lastAction: 'leave_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during leaving schedule - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while leaving schedule',
        lastAction: 'leave_error',
      ));
    }
  }

  Future<void> _onCompleteScheduleEvent(
    CompleteScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Completing schedule - ${event.scheduleId}');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.completeSchedule(
        
        event.scheduleId,
        notes: event.notes,
      );

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to complete schedule - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'complete_failed',
          ));
        },
        (schedule) {
          Debug.success('ScheduleBloc: Schedule completed successfully');
          // Update the schedule in the list
          final updatedSchedules = state.schedules.map((s) =>
              s.id == schedule.id ? schedule : s).toList();
          emit(state.copyWith(

            status: ScheduleBlocStatus.success,
            schedules: updatedSchedules,
            selectedSchedule: schedule,
            lastAction: 'complete_success',
          
          ));
        },
      );
    } 
    
    
    catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during schedule completion - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while completing schedule',
        lastAction: 'complete_error',
      ));
    }
  }

  Future<void> _onCancelScheduleEvent(
    CancelScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Cancelling schedule - ${event.scheduleId}');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.cancelSchedule(
        event.scheduleId,
        reason: event.reason,
      );

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to cancel schedule - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'cancel_failed',
          ));
        },
        (schedule) {
          Debug.success('ScheduleBloc: Schedule cancelled successfully');
          // Update the schedule in the list
          final updatedSchedules = state.schedules.map((s) =>
              s.id == schedule.id ? schedule : s).toList();
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: updatedSchedules,
            selectedSchedule: schedule,
            lastAction: 'cancel_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during schedule cancellation - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while cancelling schedule',
        lastAction: 'cancel_error',
      ));
    }
  }

  Future<void> _onRescheduleScheduleEvent(
    RescheduleScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Rescheduling schedule - ${event.scheduleId}');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.rescheduleSchedule(
        scheduleId: event.scheduleId,
        newDate: event.newDate,
        newEndDate: event.newEndDate,
        newLocation: event.newLocation,
      );

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to reschedule schedule - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'reschedule_failed',
          ));
        },
        (schedule) {
          Debug.success('ScheduleBloc: Schedule rescheduled successfully');
          // Update the schedule in the list
          final updatedSchedules = state.schedules.map((s) =>
              s.id == schedule.id ? schedule : s).toList();
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: updatedSchedules,
            selectedSchedule: schedule,
            lastAction: 'reschedule_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during schedule rescheduling - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while rescheduling schedule',
        lastAction: 'reschedule_error',
      ));
    }
  }

  Future<void> _onGetUpcomingSchedulesEvent(
    GetUpcomingSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Fetching upcoming schedules');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.getUpcomingSchedules();

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to fetch upcoming schedules - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'fetch_upcoming_failed',
          ));
        },
        (schedules) {
          Debug.success('ScheduleBloc: Upcoming schedules fetched successfully (${schedules.length})');
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: schedules,
            lastAction: 'fetch_upcoming_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during upcoming schedules fetch - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching upcoming schedules',
        lastAction: 'fetch_upcoming_error',
      ));
    }
  }

  Future<void> _onGetTodaySchedulesEvent(
    GetTodaySchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Fetching today\'s schedules');
      emit(state.copyWith(status: ScheduleBlocStatus.loading, clearError: true));

      final result = await _scheduleService.getTodaySchedules();

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to fetch today\'s schedules - $error');
          emit(state.copyWith(
            status: ScheduleBlocStatus.failure,
            errorMessage: error,
            lastAction: 'fetch_today_failed',
          ));
        },
        (schedules) {
          Debug.success('ScheduleBloc: Today\'s schedules fetched successfully (${schedules.length})');
          emit(state.copyWith(
            status: ScheduleBlocStatus.success,
            schedules: schedules,
            lastAction: 'fetch_today_success',
          ));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during today\'s schedules fetch - $e');
      emit(state.copyWith(
        status: ScheduleBlocStatus.failure,
        errorMessage: 'An unexpected error occurred while fetching today\'s schedules',
        lastAction: 'fetch_today_error',
      ));
    }
  }

  Future<void> _onCheckCanEditScheduleEvent(
    CheckCanEditScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Checking edit permissions - ${event.scheduleId}');

      final result = await _scheduleService.canEditSchedule(event.scheduleId);

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to check edit permissions - $error');
          emit(state.copyWith(
            canEdit: false,
            errorMessage: error,
          ));
        },
        (canEdit) {
          Debug.success('ScheduleBloc: Edit permissions checked - $canEdit');
          emit(state.copyWith(canEdit: canEdit));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during edit permission check - $e');
      emit(state.copyWith(
        canEdit: false,
        errorMessage: 'An unexpected error occurred while checking edit permissions',
      ));
    }
  }

  Future<void> _onCheckIsAttendingScheduleEvent(
    CheckIsAttendingScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Debug.bloc('ScheduleBloc: Checking attendance - ${event.scheduleId}');

      final result = await _scheduleService.isAttendingSchedule(event.scheduleId);

      result.fold(
        (error) {
          Debug.error('ScheduleBloc: Failed to check attendance - $error');
          emit(state.copyWith(
            isAttending: false,
            errorMessage: error,
          ));
        },
        (isAttending) {
          Debug.success('ScheduleBloc: Attendance checked - $isAttending');
          emit(state.copyWith(isAttending: isAttending));
        },
      );
    } catch (e) {
      Debug.error('ScheduleBloc: Unexpected error during attendance check - $e');
      emit(state.copyWith(
        isAttending: false,
        errorMessage: 'An unexpected error occurred while checking attendance',
      ));
    }
  }

  Future<void> _onRefreshSchedulesEvent(
    RefreshSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    Debug.bloc('ScheduleBloc: Refreshing schedules');
    // Refresh based on last successful action
    switch (state.lastAction) {
      case 'fetch_all_success':
        add(const GetAllSchedulesEvent());
        break;
      case 'fetch_my_success':
        add(GetMySchedulesEvent());
        break;
      case 'fetch_attending_success':
        add(GetMyAttendingSchedulesEvent());
        break;
      case 'fetch_upcoming_success':
        add(GetUpcomingSchedulesEvent());
        break;
      case 'fetch_today_success':
        add(GetTodaySchedulesEvent());
        break;
      default:
        add(const GetAllSchedulesEvent());
    }
  }

  Future<void> _onClearScheduleEvent(
    ClearScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    Debug.bloc('ScheduleBloc: Clearing schedule data');
    emit(state.copyWith(
      status: ScheduleBlocStatus.initial,
      clearSchedules: true,
      clearSelected: true,
      clearError: true,
      clearCanEdit: true,
      clearIsAttending: true,
    ));
  }

  Future<void> _onClearScheduleErrorEvent(
    ClearScheduleErrorEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    Debug.bloc('ScheduleBloc: Clearing error');
    emit(state.copyWith(clearError: true));
  }

  // Helper methods for easy access
  bool get hasSchedules => state.hasSchedules;
  bool get hasSelectedSchedule => state.hasSelectedSchedule;
  int get schedulesCount => state.schedulesCount;
  List<Schedule> get upcomingSchedules => state.upcomingSchedules;
  List<Schedule> get todaySchedules => state.todaySchedules;
  List<Schedule> get pastSchedules => state.pastSchedules;
}