class CoachException implements Exception {
  final String message;
  
  CoachException(this.message);
  
  @override
  String toString() => 'CoachException: $message';
}