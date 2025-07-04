import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ysyw/bloc/profile/profile_bloc.dart';
import 'package:ysyw/widgets/create_schdeule_dialog.dart';

import '../../../bloc/schedule/schedule_bloc.dart';
import '../../../model/schedule.dart';
import '../../../services/local_storage_service.dart';
import '../../../widgets/edit_schdule_dialog.dart';
import '../../../widgets/create_complete_schedule_dialog.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentFilter = 'all';
  bool _isCoach = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkUserRole();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkUserRole() async {
    final role = await LocalStorageService().getUserRole();
    setState(() {
      _isCoach = role == 'coach';
    });

    // Load appropriate schedules based on role
    if (_isCoach) {
      context.read<ScheduleBloc>().add(GetMySchedulesEvent());
    } else {
      context.read<ScheduleBloc>().add(GetMyAttendingSchedulesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(state.errorMessage ?? 'An error occurred'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state.lastAction == 'create_success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.lastAction == 'update_success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.lastAction == 'delete_success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.lastAction == 'attend_success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully joined schedule'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.lastAction == 'leave_success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully left schedule'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        builder: (context, state) {
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: false,
                  pinned: true,
                  centerTitle: false,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  actions: [
                    if (_isCoach)
                      IconButton(
                        icon: const Icon(Iconsax.add),
                        onPressed: () => _showCreateScheduleDialog(context),
                      ),
                    BlocBuilder<ScheduleBloc, ScheduleState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 1,
                              ),
                            ),
                          );
                        }
                        return IconButton(
                          icon: const Icon(Iconsax.refresh),
                          onPressed: () {
                            context
                                .read<ScheduleBloc>()
                                .add(RefreshSchedulesEvent());
                          },
                        );
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Iconsax.filter),
                      onSelected: (value) {
                        setState(() {
                          _currentFilter = value;
                        });
                        _loadSchedulesByFilter(value);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'all',
                          child: Text('All Schedules'),
                        ),
                        const PopupMenuItem(
                          value: 'upcoming',
                          child: Text('Upcoming'),
                        ),
                        const PopupMenuItem(
                          value: 'today',
                          child: Text('Today'),
                        ),
                        if (_isCoach) ...[
                          const PopupMenuItem(
                            value: 'my',
                            child: Text('My Schedules'),
                          ),
                        ] else ...[
                          const PopupMenuItem(
                            value: 'attending',
                            child: Text('My Schedules'),
                          ),
                        ],
                      ],
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Row(
                      children: [
                        Icon(
                          _isCoach ? Iconsax.teacher : Iconsax.user,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isCoach ? 'Coach Dashboard' : 'Student View',
                          style: TextStyle(
                            color: Colors.white.withOpacity(1),
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Upcoming'),
                        Tab(text: 'Past'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildScheduleList(state, 'all'),
                _buildScheduleList(state, 'upcoming'),
                _buildScheduleList(state, 'past'),
              ],
            ),
          );
        },
      ),
    );
  }

  void _loadSchedulesByFilter(String filter) {
    switch (filter) {
      case 'all':
        context.read<ScheduleBloc>().add(const GetAllSchedulesEvent());
        break;
      case 'upcoming':
        context.read<ScheduleBloc>().add(GetUpcomingSchedulesEvent());
        break;
      case 'today':
        context.read<ScheduleBloc>().add(GetTodaySchedulesEvent());
        break;
      case 'my':
        context.read<ScheduleBloc>().add(GetMySchedulesEvent());
        break;
      case 'attending':
        context.read<ScheduleBloc>().add(GetMyAttendingSchedulesEvent());
        break;
    }
  }

  Widget _buildScheduleList(ScheduleState state, String filter) {
    if (state.isLoading && !state.hasSchedules) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Schedule> schedules;
    switch (filter) {
      case 'upcoming':
        schedules = state.upcomingSchedules;
        break;
      case 'past':
        schedules = state.pastSchedules;
        break;
      default:
        schedules = state.schedules;
    }

    if (schedules.isEmpty) {
      return _buildEmptyState(filter);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ScheduleBloc>().add(RefreshSchedulesEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          schedules.sort((b, a) => a.createdAt!.compareTo(b.createdAt!));
          final schedule = schedules[index];
          return ScheduleCard(
            schedule: schedule,
            isCoach: _isCoach,
            onTap: () => _showScheduleDetails(context, schedule),
            onEdit: _isCoach
                ? () => _showEditScheduleDialog(context, schedule)
                : null,
            onDelete: _isCoach
                ? () => _showDeleteConfirmation(context, schedule)
                : null,
            onAttend: !_isCoach
                ? () => _handleAttendSchedule(context, schedule)
                : null,
            onLeave: !_isCoach
                ? () => _handleLeaveSchedule(context, schedule)
                : null,
            onComplete: _isCoach
                ? () => _handleCompleteSchedule(context, schedule)
                : null,
            onCancel: _isCoach
                ? () => _handleCancelSchedule(context, schedule)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    String message;
    IconData icon;

    switch (filter) {
      case 'upcoming':
        message = 'No upcoming schedules';
        icon = Iconsax.calendar;
        break;
      case 'past':
        message = 'No past schedules';
        icon = Iconsax.archive;
        break;
      default:
        message =
            _isCoach ? 'No schedules created yet' : 'No schedules to attend';
        icon = Iconsax.calendar_add;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _isCoach
                ? 'Create your first schedule to get started'
                : 'Check back later for new schedules',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          if (_isCoach) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateScheduleDialog(context),
              icon: const Icon(Iconsax.add),
              label: const Text('Create Schedule'),
            ),
          ],
        ],
      ),
    );
  }

  void _showScheduleDetails(BuildContext context, Schedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleDetailsSheet(
        schedule: schedule,
        isCoach: _isCoach,
        onEdit: _isCoach
            ? () {
                Navigator.pop(context);
                _showEditScheduleDialog(context, schedule);
              }
            : null,
        onDelete: _isCoach
            ? () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, schedule);
              }
            : null,
        onAttend: !_isCoach
            ? () {
                Navigator.pop(context);
                _handleAttendSchedule(context, schedule);
              }
            : null,
        onLeave: !_isCoach
            ? () {
                Navigator.pop(context);
                _handleLeaveSchedule(context, schedule);
              }
            : null,
      ),
    );
  }

  void _showCreateScheduleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateScheduleDialog(
          onCreateSchedule: (
            String title,
            String? description,
            DateTime date,
            DateTime? endDate,
            String location,
            ScheduleType type,
            int? maxAttendees,
            String? notes,
          ) {
            context.read<ScheduleBloc>().add(CreateScheduleEvent(
                  title: title,
                  description: description,
                  date: date,
                  endDate: endDate,
                  location: location,
                  type: type,
                  maxAttendees: maxAttendees,
                  notes: notes,
                ));
          },
        ),
      ),
    );
  }

  void _showEditScheduleDialog(BuildContext context, Schedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditScheduleDialog(
          schedule: schedule,
          onUpdateSchedule: (
            String title,
            String? description,
            DateTime date,
            DateTime? endDate,
            String location,
            ScheduleType type,
            int? maxAttendees,
            String? notes,
          ) {
            context.read<ScheduleBloc>().add(UpdateScheduleEvent(
                  scheduleId: schedule.id!,
                  title: title,
                  description: description,
                  date: date,
                  endDate: endDate,
                  location: location,
                  type: type,
                  maxAttendees: maxAttendees,
                  notes: notes,
                ));
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text('Are you sure you want to delete "${schedule.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<ScheduleBloc>()
                  .add(DeleteScheduleEvent(schedule.id!));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleAttendSchedule(BuildContext context, Schedule schedule) {
    context.read<ScheduleBloc>().add(AttendScheduleEvent(schedule.id!));
  }

  void _handleLeaveSchedule(BuildContext context, Schedule schedule) {
    context.read<ScheduleBloc>().add(LeaveScheduleEvent(schedule.id!));
  }

  void _handleCompleteSchedule(BuildContext context, Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => CompleteScheduleDialog(
        schedule: schedule,
        onComplete: (String? notes) {
          context.read<ScheduleBloc>().add(CompleteScheduleEvent(
                schedule.id!,
                notes: notes,
              ));
        },
      ),
    );
  }

  void _handleCancelSchedule(BuildContext context, Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => CancelScheduleDialog(
        schedule: schedule,
        onCancel: (String? reason) {
          context.read<ScheduleBloc>().add(CancelScheduleEvent(
                schedule.id!,
                reason: reason,
              ));
        },
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final bool isCoach;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAttend;
  final VoidCallback? onLeave;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.isCoach,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAttend,
    this.onLeave,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusColor;
    IconData statusIcon;
    switch (schedule.status) {
      case ScheduleStatus.scheduled:
        statusColor = Colors.green;
        statusIcon = Iconsax.calendar_tick;
        break;
      case ScheduleStatus.completed:
        statusColor = Colors.blue;
        statusIcon = Iconsax.tick_circle;
        break;
      case ScheduleStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Iconsax.close_circle;
        break;
    }

    Color typeColor;
    IconData typeIcon;
    switch (schedule.type) {
      case ScheduleType.session:
        typeColor = Colors.purple;
        typeIcon = Iconsax.activity;
        break;
      case ScheduleType.game:
        typeColor = Colors.orange;
        typeIcon = Iconsax.game;
        break;
      case ScheduleType.practice:
        typeColor = Colors.green;
        typeIcon = Iconsax.medal;
        break;
      case ScheduleType.meeting:
        typeColor = Colors.blue;
        typeIcon = Iconsax.people;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          typeIcon,
                          color: typeColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              schedule.type.displayName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              size: 12,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              schedule.status.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar_1,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm')
                            .format(schedule.date),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (schedule.duration != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Iconsax.clock,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${schedule.duration!.inHours}h ${schedule.duration!.inMinutes % 60}m',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.location,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          schedule.location,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Icon(
                        Iconsax.people,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${schedule.attendeeCount}${schedule.hasMaxAttendees ? '/${schedule.maxAttendees}' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (schedule.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      schedule.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (isCoach || (!isCoach && schedule.isScheduled))
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (isCoach) ...[
                      if (schedule.isScheduled) ...[
                        _ActionButton(
                          icon: Iconsax.edit,
                          label: 'Edit',
                          onPressed: onEdit,
                        ),
                        _ActionButton(
                          icon: Iconsax.tick_circle,
                          label: 'Complete',
                          onPressed: onComplete,
                        ),
                        _ActionButton(
                          icon: Iconsax.close_circle,
                          label: 'Cancel',
                          onPressed: onCancel,
                          isDestructive: true,
                        ),
                      ],
                      _ActionButton(
                        icon: Iconsax.trash,
                        label: 'Delete',
                        onPressed: onDelete,
                        isDestructive: true,
                      ),
                    ] else ...[
                      // Student actions
                      BlocBuilder<ScheduleBloc, ScheduleState>(
                        builder: (context, state) {
                          // Check if user is attending this schedule
                          final isAttending = schedule.isUserAttending(
                            context
                                    .read<ProfileBloc>()
                                    .state
                                    .studentProfile
                                    ?.userId ??
                                '',
                          );
                          if (isAttending) {
                            return _ActionButton(
                              icon: Iconsax.logout,
                              label: 'Leave',
                              onPressed: onLeave,
                              isDestructive: true,
                            );
                          } else if (!schedule.isAtCapacity) {
                            return _ActionButton(
                              icon: Iconsax.login,
                              label: 'Join',
                              onPressed: onAttend,
                            );
                          } else {
                            return const _ActionButton(
                              icon: Iconsax.close_circle,
                              label: 'Full',
                              onPressed: null,
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive
        ? Colors.red
        : onPressed != null
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduleDetailsSheet extends StatelessWidget {
  final Schedule schedule;
  final bool isCoach;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAttend;
  final VoidCallback? onLeave;

  const ScheduleDetailsSheet({
    super.key,
    required this.schedule,
    required this.isCoach,
    this.onEdit,
    this.onDelete,
    this.onAttend,
    this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getTypeColor(schedule.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTypeIcon(schedule.type),
                          color: _getTypeColor(schedule.type),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              schedule.type.displayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _getTypeColor(schedule.type),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _getStatusColor(schedule.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(schedule.status),
                              size: 14,
                              color: _getStatusColor(schedule.status),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              schedule.status.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(schedule.status),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (schedule.description != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      schedule.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 20),
                  _DetailRow(
                    icon: Iconsax.calendar_1,
                    title: 'Date & Time',
                    content: DateFormat('EEEE, MMM dd, yyyy • HH:mm')
                        .format(schedule.date),
                  ),
                  if (schedule.endDate != null)
                    _DetailRow(
                      icon: Iconsax.clock,
                      title: 'Duration',
                      content:
                          '${schedule.duration!.inHours}h ${schedule.duration!.inMinutes % 60}m',
                    ),
                  _DetailRow(
                    icon: Iconsax.location,
                    title: 'Location',
                    content: schedule.location,
                  ),
                  _DetailRow(
                    icon: Iconsax.people,
                    title: 'Attendees',
                    content:
                        '${schedule.attendeeCount}${schedule.hasMaxAttendees ? '/${schedule.maxAttendees}' : ''} people',
                  ),
                  if (schedule.notes != null) ...[
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Iconsax.note,
                      title: 'Notes',
                      content: schedule.notes!,
                    ),
                  ],
                  const SizedBox(height: 32),
                  if (isCoach && schedule.isScheduled) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Iconsax.edit),
                            label: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Iconsax.trash),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (!isCoach && schedule.isScheduled) ...[
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<ScheduleBloc, ScheduleState>(
                        builder: (context, state) {
                          print('Schedule: ${schedule.attendees}');
                          // Check if user is attending this schedule
                          final isAttending = schedule.isUserAttending(
                            context
                                    .read<ProfileBloc>()
                                    .state
                                    .studentProfile
                                    ?.id ??
                                '',
                          );

                          if (isAttending) {
                            return ElevatedButton.icon(
                              onPressed: onLeave,
                              icon: const Icon(Iconsax.logout),
                              label: const Text('Leave Schedule'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            );
                          } else if (!schedule.isAtCapacity) {
                            return ElevatedButton.icon(
                              onPressed: onAttend,
                              icon: const Icon(Iconsax.login),
                              label: const Text('Join Schedule'),
                            );
                          } else {
                            return ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Iconsax.close_circle),
                              label: const Text('Schedule Full'),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(ScheduleType type) {
    switch (type) {
      case ScheduleType.session:
        return Colors.purple;
      case ScheduleType.game:
        return Colors.orange;
      case ScheduleType.practice:
        return Colors.green;
      case ScheduleType.meeting:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(ScheduleType type) {
    switch (type) {
      case ScheduleType.session:
        return Iconsax.activity;
      case ScheduleType.game:
        return Iconsax.game;
      case ScheduleType.practice:
        return Iconsax.medal;
      case ScheduleType.meeting:
        return Iconsax.people;
    }
  }

  Color _getStatusColor(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.scheduled:
        return Colors.green;
      case ScheduleStatus.completed:
        return Colors.blue;
      case ScheduleStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.scheduled:
        return Iconsax.calendar_tick;
      case ScheduleStatus.completed:
        return Iconsax.tick_circle;
      case ScheduleStatus.cancelled:
        return Iconsax.close_circle;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
