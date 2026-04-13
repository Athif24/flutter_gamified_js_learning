class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? role;
  final String? joinedAt;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.role,
    this.joinedAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory ProfileModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return ProfileModel(
      id      : (d['id'] ?? '').toString(),
      name    : d['name'] ?? d['username'] ?? '',
      email   : d['email'] ?? '',
      avatar  : d['avatar'] ?? d['profilePicture'],
      role    : d['role']?.toString(),
      joinedAt: d['createdAt']?.toString() ?? d['joinedAt']?.toString(),
    );
  }
}