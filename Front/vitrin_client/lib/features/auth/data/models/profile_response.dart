class ProfileResponse {
  final int id;
  final bool isActive;
  final String username;
  final String name;
  final String role;
  final String location;
  final String section;

  const ProfileResponse({
    required this.id,
    required this.isActive,
    required this.username,
    required this.name,
    required this.role,
    required this.location,
    required this.section,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      isActive: json['status'] as bool? ?? false,
      username: (json['username'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      section: (json['section'] ?? '').toString(),
    );
  }
}
