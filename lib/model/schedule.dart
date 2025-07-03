import 'package:equatable/equatable.dart';
import 'package:ysyw/config/exceptions/schedule.dart';
enum ScheduleType { session, game, practice, meeting }

enum ScheduleStatus { scheduled, completed, cancelled }

class Schedule extends Equatable {
  final String? id;
  final String title;
  final String? description;
  final DateTime date;
  final DateTime? endDate;
  final String location;
  final ScheduleType type;
  final String createdBy;
  final List<String> attendees;
  final int? maxAttendees;
  final ScheduleStatus status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Schedule({
    this.id,
    required this.title,
    this.description,
    required this.date,
    this.endDate,
    required this.location,
    required this.type,
    required this.createdBy,
    required this.attendees,
    this.maxAttendees,
    this.status = ScheduleStatus.scheduled,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        endDate,
        location,
        type,
        createdBy,
        attendees,
        maxAttendees,
        status,
        notes,
        createdAt,
        updatedAt,
      ];

  // Helper getters
  bool get isScheduled => status == ScheduleStatus.scheduled;
  bool get isCompleted => status == ScheduleStatus.completed;
  bool get isCancelled => status == ScheduleStatus.cancelled;

  bool get hasMaxAttendees => maxAttendees != null;
  bool get isAtCapacity => hasMaxAttendees && attendees.length >= maxAttendees!;
  int get availableSpots =>
      hasMaxAttendees ? maxAttendees! - attendees.length : -1;

  bool get isUpcoming => date.isAfter(DateTime.now());
  bool get isPast => date.isBefore(DateTime.now());
  bool get isToday => _isSameDay(date, DateTime.now());

  Duration? get duration => endDate != null ? endDate!.difference(date) : null;

  bool get hasAttendees => attendees.isNotEmpty;
  int get attendeeCount => attendees.length;

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      date: DateTime.parse(json['date']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      location: json['location'] ?? '',
      type: _parseScheduleType(json['type']),
      createdBy: json['createdBy'] ?? '',
      attendees: List<String>.from(json['attendees'] ?? []),
      maxAttendees: json['maxAttendees'],
      status: _parseScheduleStatus(json['status']),
      notes: json['notes'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,
      'date': date.toIso8601String(),
      'location': location,
      'type': type.name,
      'createdBy': createdBy,
      'attendees': attendees,
      'status': status.name,
    };

    if (id != null) json['_id'] = id;
    if (description != null) json['description'] = description;
    if (endDate != null) json['endDate'] = endDate!.toIso8601String();
    if (maxAttendees != null) json['maxAttendees'] = maxAttendees;
    if (notes != null) json['notes'] = notes;
    if (createdAt != null) json['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) json['updatedAt'] = updatedAt!.toIso8601String();

    return json;
  }

  /// Create a copy with updated fields
  Schedule copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? endDate,
    String? location,
    ScheduleType? type,
    String? createdBy,
    List<String>? attendees,
    int? maxAttendees,
    ScheduleStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDescription = false,
    bool clearEndDate = false,
    bool clearMaxAttendees = false,
    bool clearNotes = false,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      date: date ?? this.date,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      location: location ?? this.location,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      attendees: attendees ?? this.attendees,
      maxAttendees:
          clearMaxAttendees ? null : (maxAttendees ?? this.maxAttendees),
      status: status ?? this.status,
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Add an attendee to the schedule
  Schedule addAttendee(String userId) {
    if (attendees.contains(userId)) {
      return this; // Already attending
    }

    if (isAtCapacity) {
      throw ScheduleException('Schedule is at maximum capacity');
    }

    return copyWith(
      attendees: [...attendees, userId],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove an attendee from the schedule
  Schedule removeAttendee(String userId) {
    if (!attendees.contains(userId)) {
      return this; // Not attending
    }

    return copyWith(
      attendees: attendees.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Check if a user is attending this schedule
  bool isUserAttending(String userId) {
    
    return attendees.contains(userId);
  }

  /// Mark schedule as completed
  Schedule markAsCompleted({String? notes}) {
    return copyWith(
      status: ScheduleStatus.completed,
      notes: notes ?? this.notes,
      updatedAt: DateTime.now(),
    );
  }

  /// Cancel the schedule
  Schedule cancel({String? reason}) {
    return copyWith(
      status: ScheduleStatus.cancelled,
      notes: reason ?? this.notes,
      updatedAt: DateTime.now(),
    );
  }

  /// Reschedule to a new date/time
  Schedule reschedule({
    required DateTime newDate,
    DateTime? newEndDate,
    String? newLocation,
  }) {
    return copyWith(
      date: newDate,
      endDate: newEndDate ?? endDate,
      location: newLocation ?? location,
      status:
          ScheduleStatus.scheduled, // Reset to scheduled if it was cancelled
      updatedAt: DateTime.now(),
    );
  }

  static ScheduleType _parseScheduleType(String? type) {
    switch (type?.toLowerCase()) {
      case 'session':
        return ScheduleType.session;
      case 'game':
        return ScheduleType.game;
      case 'practice':
        return ScheduleType.practice;
      case 'meeting':
        return ScheduleType.meeting;
      default:
        return ScheduleType.session;
    }
  }

  static ScheduleStatus _parseScheduleStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'scheduled':
        return ScheduleStatus.scheduled;
      case 'completed':
        return ScheduleStatus.completed;
      case 'cancelled':
        return ScheduleStatus.cancelled;
      default:
        return ScheduleStatus.scheduled;
    }
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  String toString() {
    return 'Schedule(id: $id, title: $title, date: $date, type: $type, status: $status)';
  }
}

/// Extension methods for ScheduleType
extension ScheduleTypeExtension on ScheduleType {
  String get displayName {
    switch (this) {
      case ScheduleType.session:
        return 'Training Session';
      case ScheduleType.game:
        return 'Game';
      case ScheduleType.practice:
        return 'Practice';
      case ScheduleType.meeting:
        return 'Meeting';
    }
  }

  String get shortName {
    switch (this) {
      case ScheduleType.session:
        return 'Session';
      case ScheduleType.game:
        return 'Game';
      case ScheduleType.practice:
        return 'Practice';
      case ScheduleType.meeting:
        return 'Meeting';
    }
  }
}

/// Extension methods for ScheduleStatus
extension ScheduleStatusExtension on ScheduleStatus {
  String get displayName {
    switch (this) {
      case ScheduleStatus.scheduled:
        return 'Scheduled';
      case ScheduleStatus.completed:
        return 'Completed';
      case ScheduleStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive => this == ScheduleStatus.scheduled;
  bool get isInactive =>
      this == ScheduleStatus.cancelled || this == ScheduleStatus.completed;
}

