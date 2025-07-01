class Coach {
  final String? id;
  final String name;
  final String userId;
  final String email;
  final String? phone;
  final String? profilePicture;
  final String coachingSpecialty;
  final int experienceYears;
  final List<String> certifications;
  final List<String> students;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Coach({
    this.id,
    required this.name,
    required this.userId,
    required this.email,
    this.phone,
    this.profilePicture,
    required this.coachingSpecialty,
    required this.experienceYears,
    required this.certifications,
    required this.students,
    this.createdAt,
    this.updatedAt,
  });

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      userId: json['userId'],
      email: json['email'],
      phone: json['phone'],
      profilePicture: json['profilePicture'],
      coachingSpecialty: json['coachingSpecialty'],
      experienceYears: json['experienceYears'],
      certifications: List<String>.from(json['certifications'] ?? []),
      students: List<String>.from(json['students'] ?? []),
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
      if (phone != null) 'phone': phone,
      if (profilePicture != null) 'profilePicture': profilePicture,
      'coachingSpecialty': coachingSpecialty,
      'experienceYears': experienceYears,
      'certifications': certifications,
      'students': students,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Coach copyWith({
    String? id,
    String? name,
    String? userId,
    String? email,
    String? phone,
    String? profilePicture,
    String? coachingSpecialty,
    int? experienceYears,
    List<String>? certifications,
    List<String>? students,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Coach(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      coachingSpecialty: coachingSpecialty ?? this.coachingSpecialty,
      experienceYears: experienceYears ?? this.experienceYears,
      certifications: certifications ?? this.certifications,
      students: students ?? this.students,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}