class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? role;
  final int xpTotal;
  final int jewels;
  final int level;
  final String levelTitle;
  final bool onboardingCompleted;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.role,
    this.xpTotal = 0,
    this.jewels = 0,
    this.level = 1,
    this.levelTitle = 'Pemula',
    this.onboardingCompleted = false,
  });

  AuthUser copyWith({bool? onboardingCompleted}) => AuthUser(
    id: id, name: name, email: email, avatar: avatar, role: role,
    xpTotal: xpTotal, jewels: jewels, level: level, levelTitle: levelTitle,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
  );

  factory AuthUser.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    final u = d['user'] ?? d;
    final s = d['stats'] as Map<String, dynamic>?;
    final lvl = s?['level'] as Map<String, dynamic>?;
    return AuthUser(
      id    : (u['id'] ?? '').toString(),
      name  : u['name'] ?? u['username'] ?? '',
      email : u['email'] ?? '',
      avatar: u['avatar'] ?? u['profilePicture'],
      role  : u['role']?.toString(),
      xpTotal: (s?['xp_total'] ?? 0) as int,
      jewels : (s?['jewels'] ?? 0) as int,
      level  : (lvl?['id'] ?? 1) as int,
      levelTitle: lvl?['name']?.toString() ?? 'Pemula',
      onboardingCompleted: u['onboarding_completed'] ?? false,
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