class Student {
  final String? id;
  final String name;
  final String userId;
  final String email;
  final List<String> highLights;
  final List<StudentMetric> metrics;
  final DateTime dob;
  final String jerseyNumber;
  final double height;
  final double weight;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Student({
    this.id,
    required this.name,
    required this.userId,
    required this.email,
    required this.highLights,
    required this.metrics,
    required this.dob,
    required this.jerseyNumber,
    required this.height,
    required this.weight,
    this.createdAt,
    this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      userId: json['userId'],
      email: json['email'],
      highLights: List<String>.from(json['highLights'] ?? []),
      metrics: (json['metrics'] as List<dynamic>?)
          ?.map((metric) => StudentMetric.fromJson(metric))
          .toList() ?? [],
      dob: DateTime.parse(json['dob']),
      jerseyNumber: json['jerseyNumber'],
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'userId': userId,
      'email': email,
      'highLights': highLights,
      'metrics': metrics.map((metric) => metric.toJson()).toList(),
      'dob': dob.toIso8601String(),
      'jerseyNumber': jerseyNumber,
      'height': height,
      'weight': weight,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class StudentMetric {
  final String metricType;
  final double value;

  StudentMetric({
    required this.metricType,
    required this.value,
  });

  factory StudentMetric.fromJson(Map<String, dynamic> json) {
    return StudentMetric(
      metricType: json['metricType'],
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metricType': metricType,
      'value': value,
    };
  }
}