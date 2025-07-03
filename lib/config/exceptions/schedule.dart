
/// Custom exception for schedule operations
class ScheduleException implements Exception {
  final String message;

  ScheduleException(this.message);

  @override
  String toString() {
    return 'ScheduleException: $message';
  }
}