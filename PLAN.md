# PLAN.md — Bloom Mobile App (Flutter)

## 📋 Project Overview

Aplikasi mobile **Bloom** — platform pembelajaran JavaScript tergamifikasi. Dibangun dengan Flutter (Riverpod + GoRouter + Dio), terhubung ke backend Node.js/Hono/PostgreSQL yang sudah di-deploy di Vercel.

---

## 🏗️ Arsitektur Saat Ini

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── router/             # GoRouter (app_router.dart)
│   ├── network/            # Dio ApiClient + interceptor
│   ├── storage/            # FlutterSecureStorage
│   └── constants/          # API endpoint constants
├── shared/
│   ├── themes/             # BloomTheme (9 tema) + theme_provider
│   └── widgets/            # main_screen.dart (5 tab bottom nav)
├── features/
│   ├── auth/               # Login, Register + AuthStateNotifier
│   ├── courses/            # CourseList, Detail, Lesson, Quiz
│   ├── achievement/        # XP, Streak, Badge, LearningReport
│   ├── leaderboard/        # Ranking + podium
│   ├── store/              # Shop, Inventory, Jewel History
│   └── profile/            # Profile + theme picker
```

**Pattern per feature:** `data/datasources/` + `data/models/` + `presentation/screens/` + `presentation/providers/`

**Masalah:** Tidak ada layer `domain/` — entities dan business logic tercampur di model, provider akses datasource langsung tanpa abstraksi.

---

## 🎯 Target Arsitektur — Feature-Driven Architecture (FSD)

```
lib/
├── main.dart                              # Entry point
├── app.dart                               # ProviderScope + MaterialApp.router
├── core/                                  # Cross-cutting concerns
│   ├── router/
│   │   └── app_router.dart
│   ├── network/
│   │   └── api_client.dart                # Dio + AuthInterceptor
│   ├── storage/
│   │   └── secure_storage.dart
│   └── constants/
│       └── api_constants.dart
├── shared/                                # Shared UI
│   ├── themes/
│   │   ├── app_theme.dart
│   │   └── theme_provider.dart
│   └── widgets/
│       ├── main_screen.dart               # Bottom nav (5 tab)
│       ├── celebration_screen.dart
│       └── game_3d_button.dart
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart              # Business entity (tanpa fromJson)
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart   # Abstract interface
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── auth_request_dto.dart  # LoginRequest, RegisterRequest
│   │   │   │   └── auth_response_dto.dart # LoginResponse + mapper → User
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── screens/
│   │           ├── login_screen.dart
│   │           └── register_screen.dart
│   ├── courses/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── course.dart
│   │   │   │   ├── unit.dart
│   │   │   │   ├── lesson.dart
│   │   │   │   ├── quiz.dart
│   │   │   │   └── question.dart
│   │   │   └── repositories/
│   │   │       └── course_repository.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── course_dto.dart
│   │   │   │   ├── unit_dto.dart
│   │   │   │   ├── lesson_dto.dart
│   │   │   │   ├── quiz_detail_dto.dart
│   │   │   │   └── question_dto.dart
│   │   │   ├── datasources/
│   │   │   │   └── course_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── course_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── course_provider.dart
│   │       ├── screens/
│   │       │   ├── course_list_screen.dart
│   │       │   ├── course_detail_screen.dart
│   │       │   ├── lesson_screen.dart
│   │       │   └── quiz_screen.dart
│   │       └── widgets/
│   │           └── quiz/
│   │               ├── question_card.dart
│   │               ├── choice_question.dart
│   │               ├── essay_question.dart
│   │               ├── coding_question.dart
│   │               ├── arrange_question.dart
│   │               ├── quiz_timer.dart
│   │               ├── quiz_feedback_popup.dart
│   │               ├── quiz_result_screen.dart
│   │               ├── quiz_review_dialog.dart
│   │               └── bottom_bar.dart
│   ├── achievement/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── xp.dart
│   │   │   │   ├── streak.dart
│   │   │   │   ├── badge.dart
│   │   │   │   ├── level.dart
│   │   │   │   ├── learning_report.dart
│   │   │   │   ├── xp_history_entry.dart
│   │   │   │   ├── lives.dart
│   │   │   │   └── event.dart
│   │   │   └── repositories/
│   │   │       └── achievement_repository.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── xp_dto.dart
│   │   │   │   ├── streak_dto.dart
│   │   │   │   ├── badge_dto.dart
│   │   │   │   ├── level_dto.dart
│   │   │   │   ├── learning_report_dto.dart
│   │   │   │   ├── xp_history_entry_dto.dart
│   │   │   │   ├── lives_dto.dart
│   │   │   │   └── event_dto.dart
│   │   │   ├── datasources/
│   │   │   │   ├── achievement_remote_datasource.dart
│   │   │   │   └── event_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── achievement_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── achievement_provider.dart
│   │       ├── screens/
│   │       │   └── achievement_screen.dart
│   │       └── widgets/
│   │           ├── level_roadmap.dart
│   │           └── xp_history_list.dart
│   ├── leaderboard/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── leaderboard_entry.dart
│   │   │   └── repositories/
│   │   │       └── leaderboard_repository.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── leaderboard_entry_dto.dart
│   │   │   ├── datasources/
│   │   │   │   └── leaderboard_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── leaderboard_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── leaderboard_provider.dart
│   │       └── screens/
│   │           └── leaderboard_screen.dart
│   ├── store/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── store_item.dart
│   │   │   │   ├── inventory_item.dart
│   │   │   │   ├── jewel_balance.dart
│   │   │   │   └── jewel_transaction.dart
│   │   │   └── repositories/
│   │   │       └── store_repository.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── store_item_dto.dart
│   │   │   │   ├── inventory_item_dto.dart
│   │   │   │   ├── jewel_balance_dto.dart
│   │   │   │   └── jewel_transaction_dto.dart
│   │   │   ├── datasources/
│   │   │   │   └── store_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── store_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── store_provider.dart
│   │       └── screens/
│   │           └── store_screen.dart
│   └── profile/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── profile.dart
│       │   └── repositories/
│       │       └── profile_repository.dart
│       ├── data/
│       │   ├── models/
│       │   │   └── profile_dto.dart
│       │   ├── datasources/
│       │   │   └── profile_remote_datasource.dart
│       │   └── repositories/
│       │       └── profile_repository_impl.dart
│       └── presentation/
│           ├── providers/
│           │   └── profile_provider.dart
│           └── screens/
│               └── profile_screen.dart
└── test/                                 # Unit & widget tests
    ├── auth_provider_test.dart
    ├── quiz_provider_test.dart
    ├── login_screen_test.dart
    └── course_list_test.dart
```

**Pattern FSD per feature:**
- `domain/entities/` → Business objects murni (tanpa `fromJson`/`toJson`, tanpa framework dependency)
- `domain/repositories/` → Abstract interface kontrak data
- `data/models/` → DTO dengan `fromJson` + mapper ke entity
- `data/datasources/` → Panggilan API actual
- `data/repositories/` → Implementasi konkrit dari repository interface
- `presentation/providers/` → Riverpod state management
- `presentation/screens/` → Halaman penuh
- `presentation/widgets/` → Widget pendukung fitur

---

## ✅ Sudah Berfungsi

| Fitur | Status |
|---|---|
| Auth (login/register/logout/restore) | ✅ |
| Course List + Search + Filter | ✅ |
| Course Detail (units tree + progress) | ✅ |
| Lesson Content (ProseMirror renderer) | ✅ |
| Quiz Engine (Choice, Essay, Coding, Arrange + timer) | ✅ |
| Quiz Submit + Result + Review | ✅ |
| Leaderboard (podium + rank list + my position) | ✅ |
| Store (shop buy + jewel history) | ✅ |
| Achievement (XP, streak, badges, stats) | ✅ |
| Profile (view + theme picker + logout) | ✅ |
| 9 Theme Colors | ✅ |
| Animasi (flutter_animate + Bounceable) | ✅ |
| Offline enrollment cache (SharedPreferences) | ✅ |

---

## 🔥 Phase 1 — Fix Stubs & Bugs

### 1.1 Store — Implementasi `useItem`

**File:** `lib/features/store/data/datasources/store_remote_datasource.dart`
- [ ] Tambah method `useItem(String itemId)` → `POST /api/v1/store/use` body `{ itemId }`
- [ ] Konstanta `Api.storeUse` sudah ada di `api_constants.dart`

**File:** `lib/features/store/presentation/screens/store_screen.dart`
- [ ] `_InventoryTile.onTap` (line 282): ganti `() {}` dengan panggil `ref.read(storeDsProvider).useItem(item.id)`
- [ ] Setelah sukses: `ref.invalidate(inventoryProvider)` + `ref.invalidate(jewelBalanceProvider)`
- [ ] Snackbar feedback sukses (hijau) / gagal (merah)

### 1.2 Profile — Edit Profile Dialog

**File:** `lib/features/profile/presentation/screens/profile_screen.dart`
- [ ] Line 88: `Bounceable(onTap: () {})` → buka dialog edit profil
- [ ] Buat `_EditProfileDialog` dengan 2 field: nama (required) & email (validasi format)
- [ ] Panggil `ProfileRemoteDatasource.updateProfile(data)`
- [ ] Setelah sukses: `ref.invalidate(authProvider)` + `ref.invalidate(profileProvider)`
- [ ] Loading state & error handling

### 1.3 Profile — Change Password

**File:** `lib/features/profile/presentation/screens/profile_screen.dart`
- [ ] Line 383: `Bounceable(onTap: () {})` → buka dialog ganti password
- [ ] Buat `_ChangePasswordDialog` dengan field: password_lama, password_baru, konfirmasi
- [ ] Validasi: min 6 karakter, password_baru == konfirmasi
- [ ] Tambah method `changePassword(oldPassword, newPassword)` di `AuthRemoteDatasource` → `PUT /api/v1/auth/password`
- [ ] Loading state & error handling

### 1.4 Profile — Gunakan `profileProvider`

**File:** `lib/features/profile/presentation/screens/profile_screen.dart`
- [ ] Ganti `auth.user?.name` dan `auth.user?.email` (line 23-24) dengan `profileProvider`
- [ ] `profileProvider` sudah ada di `lib/features/profile/presentation/providers/profile_provider.dart` tapi tidak dipakai
- [ ] Tambah loading shimmer & error state untuk profile data

### 1.5 Leaderboard — Search Filter

**File:** `lib/features/leaderboard/presentation/screens/leaderboard_screen.dart`
- [ ] Line 134: `TextField` tidak punya `onChanged` handler
- [ ] Buat `StateProvider<String>` untuk search query
- [ ] Filter entries: `where((e) => e.name.toLowerCase().contains(query))`
- [ ] Hasil filter ditampilkan, bukan full list

### 1.6 Achievement — Fix Stat Card Labels

**File:** `lib/features/achievement/presentation/screens/achievement_screen.dart`
- [ ] **Bug 1** — Line 56: `value: '${r.quizAttempts}'` dengan label `TOTAL XP` → ganti dengan `xpAsync.data.totalXp`
- [ ] **Bug 2** — Line 66: `value: '${r.quizAttempts}/${r.quizAttempts}'` dengan label `BADGE DIRAIH` (100% terus) → ganti dengan jumlah badge earned dari `userBadgesProvider` / total dari `allBadgesProvider`
- [ ] `allBadgesProvider` sudah ada di provider tapi tidak dipakai di UI

### 1.7 Achievement — Lives System

**File:** `lib/features/achievement/presentation/screens/achievement_screen.dart`
- [ ] Line 203: `'0/5 Lives'` masih hardcoded
- [ ] Tambah endpoint `/api/v1/users/lives` di `ApiConstants`
- [ ] Tambah method `getLives()` di `AchievementRemoteDatasource`
- [ ] Buat model `LivesModel` { current, max, lastLifeUpdate, regenTimeRemaining }
- [ ] Tampilkan lives real + countdown timer regen jika lives < max

---

## 🆕 Phase 2 — Fitur Baru

### 2.1 Celebration Overlay

- [ ] Buat screen baru: `lib/shared/widgets/celebration_screen.dart`
- [ ] Parameter: xpEarned, jewelsEarned, streak, levelUp, badgesAwarded
- [ ] Full-screen overlay setelah menyelesaikan lesson atau quiz
- [ ] Animasi: counter XP (TweenAnimationBuilder), particle confetti, level up popup, badge unlock
- [ ] Tombol "Lanjut Belajar" → dismiss & navigasi ke course detail

**Integrasi:** `lesson_screen.dart` (line 184-198) — ganti `showDialog` jadi push `CelebrationScreen`
**Integrasi:** `quiz_screen.dart` — setelah submit quiz & tampil result, jika ada reward → `CelebrationScreen`

### 2.2 Events — Tampilkan Events

- [ ] Tambah endpoint events di `ApiConstants` (backend sudah punya `GET /api/v1/events`)
- [ ] Buat `EventModel` (id, name, description, eventType, xpReward, jewelReward, startDate, endDate)
- [ ] Buat `EventRemoteDatasource` + `eventProvider` (FutureProvider)
- [ ] Tampilkan di tab **Achievement** sebagai section "Event Aktif"
- [ ] Card: nama event, deadline countdown, reward XP/Jewel
- [ ] Jika tidak ada event: sembunyikan section

### 2.3 Level Roadmap

**File:** `lib/features/achievement/presentation/screens/achievement_screen.dart`
- [ ] Tambah section "Progres Level" di bawah badge collection
- [ ] Ambil data dari `GET /api/v1/levels`
- [ ] Buat widget `_LevelRoadmap`: visual timeline semua level
- [ ] Level saat ini: highlight dengan accent color
- [ ] Level terkunci: opacity 0.3
- [ ] Level sudah dilewati: centang hijau

### 2.4 XP History Timeline

**File:** `lib/features/achievement/presentation/screens/achievement_screen.dart`
- [ ] Tambah section "Riwayat XP" di bagian bawah
- [ ] Endpoint: `GET /api/v1/xps` (history list — berbeda dengan XP summary)
- [ ] Buat model `XpHistoryEntry` (id, earnedXp, sourceType, sourceId, createdAt)
- [ ] Tampilkan sebagai timeline: "Menyelesaikan Quiz A → +50 XP"
- [ ] Group by tanggal

---

## 🔧 Phase 3 — Polish & Refactor

### 3.1 Pull-to-Refresh

- [ ] **Leaderboard:** `RefreshIndicator` di `CustomScrollView`
- [ ] **Store:** Shop tab + Inventory tab + Jewel History tab
- [ ] **Achievement:** `RefreshIndicator` di `SingleChildScrollView`

### 3.3 Code Cleanup

- [ ] Hapus semua `debugPrint` (kecuali error logging penting)
- [ ] Standardisasi format error: konsisten `Exception:` stripping
- [ ] Tambah `const` constructor di semua widget

---

## 🧪 Phase 4 — Testing

### 4.1 Unit Tests

| Test | File | Coverage |
|---|---|---|
| AuthNotifier | `test/auth_provider_test.dart` | login(), register(), logout(), _restore() — sukses & gagal |
| QuizNotifier | `test/quiz_provider_test.dart` | load(), answer(), next(), prev(), submit(), submitCurrentAnswer() |
| Models | `test/models_test.dart` | fromJson parsing untuk semua model |

### 4.2 Widget Tests

| Test | File | Coverage |
|---|---|---|
| LoginScreen | `test/login_screen_test.dart` | form validation, loading, error snackbar |
| CourseList | `test/course_list_test.dart` | shimmer loading, error retry, empty state, data |
| Quiz Choice | `test/choice_question_test.dart` | tap option, feedback display |

---

## 🏛️ Phase 6 — FSD Refactor (Domain Layer + Repository Pattern)

### 6.1 Pindahkan model → DTO + Entity

Setiap `data/models/*_model.dart` dipecah jadi 2:
- `data/models/*_dto.dart` — class dengan `fromJson` + method `.toEntity()`
- `domain/entities/*.dart` — class murni tanpa dependency eksternal

### 6.2 Buat Repository Interface

Setiap feature dapat interface di `domain/repositories/`:
```dart
abstract class CourseRepository {
  Future<List<Course>> getCourses();
  Future<Course> getCourseById(String id);
  Future<Lesson> getLessonById(String id);
  Future<LessonCompleteResponse> completeLesson(String id);
  // ...
}
```

### 6.3 Implementasi Repository

`data/repositories/*_impl.dart` → panggil datasource, mapping DTO → Entity.

### 6.4 Update Provider

Provider tidak akses datasource langsung, tapi melalui repository interface.

### 6.5 Daftar File Baru

| Feature | Entity | DTO | Repository Interface | Repository Impl |
|---------|--------|-----|---------------------|----------------|
| auth | `user.dart` | `auth_request_dto.dart`, `auth_response_dto.dart` | `auth_repository.dart` | `auth_repository_impl.dart` |
| courses | `course.dart`, `unit.dart`, `lesson.dart`, `quiz.dart`, `question.dart` | `course_dto.dart`, `unit_dto.dart`, `lesson_dto.dart`, `quiz_detail_dto.dart`, `question_dto.dart` | `course_repository.dart` | `course_repository_impl.dart` |
| achievement | `xp.dart`, `streak.dart`, `badge.dart`, `level.dart`, `learning_report.dart`, `xp_history_entry.dart`, `lives.dart`, `event.dart` | per entity 1 DTO | `achievement_repository.dart` | `achievement_repository_impl.dart` |
| leaderboard | `leaderboard_entry.dart` | `leaderboard_entry_dto.dart` | `leaderboard_repository.dart` | `leaderboard_repository_impl.dart` |
| store | `store_item.dart`, `inventory_item.dart`, `jewel_balance.dart`, `jewel_transaction.dart` | per entity 1 DTO | `store_repository.dart` | `store_repository_impl.dart` |
| profile | `profile.dart` | `profile_dto.dart` | `profile_repository.dart` | `profile_repository_impl.dart` |

### 6.6 Langkah Eksekusi

1. Buat `domain/entities/` — pindah field dari model existing, buang `fromJson`
2. Rename `*_model.dart` → `*_dto.dart`, tambah method `.toEntity()`
3. Buat `domain/repositories/*_repository.dart` (abstract class)
4. Buat `data/repositories/*_repository_impl.dart` (panggil datasource, return entity)
5. Update provider: inject repository, bukan datasource
6. Update screen: import entity, bukan DTO

---

## 🚀 Phase 5 — Deployment

### 5.1 Build APK

```bash
flutter build apk --release
flutter build appbundle --release
```

### 5.2 CI/CD (Opsional)

- [ ] GitHub Actions: test → lint → build
- [ ] Firebase App Distribution untuk internal testing

---

## 📊 Estimasi Waktu

| Item | Hari |
|---|---|
| Store useItem | 0.5 |
| Edit Profile | 1 |
| Change Password | 1 |
| Profile Provider | 0.5 |
| Leaderboard Search | 0.5 |
| Fix Stat Labels | 0.5 |
| Lives System | 1 |
| Celebration Overlay | 2 |
| Events | 1 |
| Level Roadmap | 1 |
| XP History | 0.5 |
| Pull-to-Refresh | 0.5 |
| Code Cleanup | 0.5 |
| FSD — Buat domain/entities (6 fitur) | 1 |
| FSD — Buat DTO + mapper (6 fitur) | 1 |
| FSD — Buat repository interface (6 fitur) | 0.5 |
| FSD — Buat repository impl (6 fitur) | 1 |
| FSD — Update provider & screens | 1 |
| Testing | 2 |
| Deployment | 0.5 |
| **Total** | **~15 hari** |

---

## 📁 File Baru (di luar FSD refactor)

```
lib/shared/widgets/
├── celebration_screen.dart          # [2.1]
└── game_3d_button.dart              # [3.1] pindah dari quiz_screen

lib/features/courses/presentation/widgets/quiz/
├── choice_question.dart             # [sudah ada]
├── essay_question.dart              # [sudah ada]
├── coding_question.dart             # [sudah ada]
├── arrange_question.dart            # [sudah ada]
├── quiz_timer.dart                  # [sudah ada]
├── quiz_feedback_popup.dart         # [sudah ada]
├── quiz_result_screen.dart          # [sudah ada]
├── quiz_review_dialog.dart          # [sudah ada]
└── bottom_bar.dart                  # [sudah ada]

lib/features/achievement/presentation/widgets/
├── level_roadmap.dart               # [2.3]
└── xp_history_list.dart             # [2.4]

test/
├── auth_provider_test.dart          # [4]
├── quiz_provider_test.dart          # [4]
├── login_screen_test.dart           # [4]
└── course_list_test.dart            # [4]
```

### 📁 File Baru FSD (Phase 6)

```
# domain/entities/ (6 fitur × ~3 file = 18 file)
features/auth/domain/entities/user.dart
features/courses/domain/entities/course.dart
features/courses/domain/entities/unit.dart
features/courses/domain/entities/lesson.dart
features/courses/domain/entities/quiz.dart
features/courses/domain/entities/question.dart
features/achievement/domain/entities/xp.dart
features/achievement/domain/entities/streak.dart
features/achievement/domain/entities/badge.dart
features/achievement/domain/entities/level.dart
features/achievement/domain/entities/learning_report.dart
features/achievement/domain/entities/xp_history_entry.dart
features/achievement/domain/entities/lives.dart
features/achievement/domain/entities/event.dart
features/leaderboard/domain/entities/leaderboard_entry.dart
features/store/domain/entities/store_item.dart
features/store/domain/entities/inventory_item.dart
features/store/domain/entities/jewel_balance.dart
features/store/domain/entities/jewel_transaction.dart
features/profile/domain/entities/profile.dart

# domain/repositories/ (6 file)
features/auth/domain/repositories/auth_repository.dart
features/courses/domain/repositories/course_repository.dart
features/achievement/domain/repositories/achievement_repository.dart
features/leaderboard/domain/repositories/leaderboard_repository.dart
features/store/domain/repositories/store_repository.dart
features/profile/domain/repositories/profile_repository.dart

# data/models/ — rename *model.dart → *dto.dart + tambah toEntity() (20 file)
# data/repositories/ — baru (6 file)
features/auth/data/repositories/auth_repository_impl.dart
features/courses/data/repositories/course_repository_impl.dart
features/achievement/data/repositories/achievement_repository_impl.dart
features/leaderboard/data/repositories/leaderboard_repository_impl.dart
features/store/data/repositories/store_repository_impl.dart
features/profile/data/repositories/profile_repository_impl.dart
```

**~50 file baru FSD | ~30 file dimodifikasi | Total ~15 hari kerja**
