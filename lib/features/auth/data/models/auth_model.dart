class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? role;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    final u = d['user'] ?? d;
    return AuthUser(
      id    : (u['id'] ?? '').toString(),
      name  : u['name'] ?? u['username'] ?? '',
      email : u['email'] ?? '',
      avatar: u['avatar'] ?? u['profilePicture'],
      role  : u['role']?.toString(),
    );
  }
}

class LoginResponse {
  final String token;
  final AuthUser user;
  const LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return LoginResponse(
      token: d['token'] ?? d['accessToken'] ?? '',
      user : AuthUser.fromJson(d),
    );
  }
}