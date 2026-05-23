// ============================================================================
// APP STRINGS
// Centralized UI strings for consistency across the app.
// Strings with interpolation (e.g. 'Gagal: $e') are NOT included.
// ============================================================================

class AppStrings {
  AppStrings._();

  // ── Button Labels ──────────────────────────────────────────────────────
  static const retry = 'Coba Lagi';
  static const retryLabel = 'Retry';
  static const buyNow = 'Beli Sekarang';
  static const markComplete = 'Tandai Selesai';
  static const process = 'Memproses...';
  static const insufficientBalance = 'Saldo Tidak Cukup';

  // ── Section Labels ─────────────────────────────────────────────────────
  static const possibleRewards = 'Kemungkinan Hadiah';

  // ── Error: Course ──────────────────────────────────────────────────────
  static const errLoadCourses = 'Gagal memuat kursus';
  static const errLoadCourseDetail = 'Gagal memuat detail kursus';
  static const errLoadCourseProgress = 'Gagal memuat progress';
  static const errLoadLesson = 'Gagal memuat materi';

  // ── Error: Quiz ────────────────────────────────────────────────────────
  static const errLoadQuiz = 'Gagal memuat kuis';
  static const errLoadQuizStatus = 'Gagal memuat status kuis';
  static const errLoadQuizResult = 'Gagal memuat hasil kuis';
  static const errStartQuiz = 'Gagal memulai kuis';
  static const errSubmitQuiz = 'Gagal mengumpulkan jawaban';

  // ── Error: Store ───────────────────────────────────────────────────────
  static const errLoadStoreItems = 'Gagal memuat item';
  static const errLoadInventory = 'Gagal memuat inventori';
  static const errLoadJewelBalance = 'Gagal memuat saldo Jewel';
  static const errLoadJewelHistory = 'Gagal memuat riwayat Jewel';
  static const errLoadRewardPools = 'Gagal memuat reward pools';

  // ── Error: Leaderboard ─────────────────────────────────────────────────
  static const errLoadLeaderboard = 'Gagal memuat leaderboard';
  static const errLoadLeaderboardDetail = 'Gagal memuat leaderboard. Silakan coba lagi.';

  // ── Error: Profile/Auth ────────────────────────────────────────────────
  static const errLoadProfile = 'Gagal memuat profil';

  // ── Error: Achievement ─────────────────────────────────────────────────
  static const errLoadAchievement = 'Gagal memuat achievement';
  static const errLoadAchievementDetail = 'Gagal memuat detail achievement';
  static const errLoadLevels = 'Gagal memuat level';
  static const errLoadXpHistory = 'Gagal memuat riwayat XP';
  static const errLoadLives = 'Gagal memuat lives';
  static const errLoadXp = 'Gagal memuat XP';
  static const errLoadBadges = 'Gagal memuat badge';
  static const errLoadLearningReport = 'Gagal memuat laporan';

  // ── Error: Events ──────────────────────────────────────────────────────
  static const errLoadEvents = 'Gagal memuat events';

  // ── Error: Misc ────────────────────────────────────────────────────────
  static const errLoadImage = 'Gagal memuat gambar';
}
