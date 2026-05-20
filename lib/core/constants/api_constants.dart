class Api {
  static const base = 'https://bloom-be.vercel.app';

  // ── Auth ──────────────────────────────────────────────────────
  static const login          = '/api/v1/auth/login';
  static const register       = '/api/v1/auth/register';
  static const logout         = '/api/v1/auth/logout';
  static const authMe         = '/api/v1/auth/me';
  static const authProfile    = '/api/v1/auth/profile';
  static const authChangePassword = '/api/v1/auth/password';

  // ── Courses ───────────────────────────────────────────────────
  static const courses                           = '/api/v1/courses';
  static String courseById(String id)            => '/api/v1/courses/$id';
  static String courseEnroll(String id)          => '/api/v1/courses/$id/enroll';
  static String courseProgress(String id)        => '/api/v1/courses/$id/progress';

  // ── Units ─────────────────────────────────────────────────────
  static const units                             = '/api/v1/units';
  static String unitById(String id)              => '/api/v1/units/$id';
  static String unitProgress(String id)          => '/api/v1/units/$id/progress';
  static String lessonsByUnit(String unitId)     => '/api/v1/lessons?unit_id=$unitId';

  // ── Lessons ───────────────────────────────────────────────────
  static const lessons                           = '/api/v1/lessons';
  static String lessonById(String id)            => '/api/v1/lessons/$id';
  static String lessonComplete(String id)        => '/api/v1/lessons/$id/complete';

  // ── Quizzes ───────────────────────────────────────────────────
  static const quizzes                           = '/api/v1/quizzes';
  static String quizById(String id)              => '/api/v1/quizzes/$id';
  static String quizStart(String id)             => '/api/v1/quizzes/$id/start';
  static String quizAttempt(String id)           => '/api/v1/quizzes/$id/attempt';
  static String quizSubmit(String id)            => '/api/v1/quizzes/$id/submit';
  static String quizMyResult(String id)          => '/api/v1/quizzes/$id/my-result';
  static const quizzesByUnit = '/api/v1/quizzes';
  static const submitAnswer                      = '/api/v1/user-questions/submit';

  // ── Leaderboard ───────────────────────────────────────────────
  static const leaderboard                       = '/api/v1/leaderboard';

  // ── Store ─────────────────────────────────────────────────────
  static const storeItems                        = '/api/v1/store/items';
  static const storeInventory                    = '/api/v1/store/inventory';
  static const storeBuy                          = '/api/v1/store/buy';
  static const storeUse                          = '/api/v1/store/use';
  static const jewelsBalance                     = '/api/v1/store/jewels/balance';
  static const jewelsHistory                     = '/api/v1/store/jewels/history';

  // ── Achievement ───────────────────────────────────────────────
  static const xps                               = '/api/v1/xps';
  static const badges                            = '/api/v1/badges';
  static const userBadges                        = '/api/v1/user-badges';
  static String userBadgesByUser(String uid)     => '/api/v1/user-badges/user/$uid';
  static const userStreaks                       = '/api/v1/user-streaks';
  static String userStreakByUser(String uid)     => '/api/v1/user-streaks/user/$uid';

  // ── Levels ───────────────────────────────────────────────────
  static const levels                            = '/api/v1/levels';

  // ── Events ───────────────────────────────────────────────────
  static const events                            = '/api/v1/events';
  static String eventById(String id)             => '/api/v1/events/$id';

  // ── Reports ───────────────────────────────────────────────────
  static const reportsLearning                   = '/api/v1/reports/learning';
  static const reportsDashboard                  = '/api/v1/reports/dashboard';

  // ── Users ─────────────────────────────────────────────────────
  static const users                             = '/api/v1/users';
  static const usersLives                        = '/api/v1/users/lives';
  static String userById(String id)              => '/api/v1/users/$id';

  // ── User-Courses (Enrollments) ──────────────────────────────
  static const userCourses                       = '/api/v1/user-courses';

  // ── Reward Pools (Mystery Box) ──────────────────────────────────
  static const rewardPools                       = '/api/v1/reward-pools';
  static String rewardPoolById(int id)           => '/api/v1/reward-pools/$id';
  static String buyRewardPool(int id)            => '/api/v1/reward-pools/$id/buy';
  static String openRewardPool(int id)           => '/api/v1/reward-pools/$id/open';

  // ── Notifications ─────────────────────────────────────────────
  static const registerFcmToken                  = '/api/v1/notifications/register';
  static const unregisterFcmToken                = '/api/v1/notifications/unregister';
}
