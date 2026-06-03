# LAPORAN AUDIT KODE MENYELURUH
**Tanggal:** 31 Mei 2026  
**Tools:** Static pattern audit 9 kategori, `dart analyze`  
**Scope:** `lib/` — 7 modul, ~130 file

---

## Ringkasan

| Modul | HIGH | MEDIUM | LOW | Total |
|-------|:----:|:------:|:---:|:-----:|
| Courses | 5 | 7 | 7 | 19 |
| Achievement (+Celebration) | 1 | 16 | 15 | 32 |
| Profile | 1 | 9 | 10 | 20 |
| Auth | 5 | 15 | 7 | 27 |
| Store | 2 | 7 | 10 | 19 |
| Leaderboard | 0 | 6 | 6 | 12 |
| Shared/Core | 1 | 14 | 11 | 26 |
| **TOTAL** | **14** | **74** | **67** | **155** |

### Per Kategori

| # | Kategori | HIGH | MEDIUM | LOW | Total |
|---|----------|:----:|:------:|:---:|:-----:|
| 1 | Responsive scaling | 8 | 11 | 9 | 28 |
| 2 | Data fetching / API | 2 | 7 | 10 | 19 |
| 3 | Audio | 0 | 0 | 1 | 1 |
| 4 | State management | 0 | 8 | 5 | 13 |
| 5 | Memory leak | 0 | 0 | 2 | 2 |
| 6 | Performance | 0 | 8 | 6 | 14 |
| 7 | Accessibility | 1 | 30 | 10 | 41 |
| 8 | Navigation | 0 | 4 | 3 | 7 |
| 9 | Code quality | 3 | 6 | 21 | 30 |

---

## Courses (19)

| # | File | Line | Sev | Cat | Temuan |
|---|------|:----:|:---:|:---:|--------|
| 1 | `course_remote_datasource.dart` | 28-52 | H | 2 | `getMyEnrollments()` tanpa try-catch |
| 2 | `course_remote_datasource.dart` | 150-158 | H | 2 | `getQuizByLessonId()` tanpa try-catch |
| 3 | `course_detail_screen.dart` | 59,68,82,86 | H | 1 | Scroll calc `192`,`152`,`72`,`48` mismatch S.scale |
| 4 | `quiz_result_screen.dart` | 147 | H | 1 | `Border.all(width: 2)` tanpa S.scale |
| 5 | `quiz_result_screen.dart` | 199 | H | 1 | `Border.all(width: 3)` tanpa S.scale |
| 6 | `quiz_result_screen.dart` | 266 | M | 1 | ScoreRing `112`/`160` tanpa S.scale |
| 7 | `quiz_result_screen.dart` | 446-447 | M | 1 | Confetti `w/h: 6` tanpa S.scale |
| 8 | `peta_belajar_painter.dart` | 35 | M | 1 | Bezier `+40` tanpa S.scale |
| 9 | `prose_mirror_renderer.dart` | 511 | M | 1 | Syntax `fontSize: 13` default |
| 10 | `quiz_screen.dart` | 229 | M | 4 | `setState` tanpa `mounted` |
| 11 | `quiz_timer.dart` | 86 | M | 4 | `setState` tanpa `mounted` di Timer |
| 12 | `quiz_result_screen.dart` | 84 | M | 4 | `setState` tanpa `mounted` di listener |
| 13 | `course_card.dart` | 111 | M | 6 | `NetworkImage` tanpa cache |
| 14 | All course icons | - | M | 7 | 0 ExcludeSemantics |
| 15 | `quiz_result_screen.dart` | 442 | L | 1 | `top: -10` hardcoded |
| 16 | `lesson_screen.dart` | 508 | L | 8 | `Navigator.of(context).push()` |
| 17 | `quiz_screen.dart` | 73-78 | L | 9 | `debugPrint` production |
| 18 | `quiz_feedback_popup.dart` | 74 | L | 9 | `DateTime.now().millisecond` |
| 19 | `build_single_button.dart` | 38,44 | L | 9 | Hardcoded `Color(0xFF666666)` |

---

## Achievement (+Celebration) (32)

| # | File | Line | Sev | Cat | Temuan |
|---|------|:----:|:---:|:---:|--------|
| 1 | `level_roadmap.dart` | 89-91 | H | 1 | `Positioned(26,16,16)` tanpa S.scale |
| 2 | `achievement_screen.dart` | 217-218 | M | 1 | `spacing:12` di Wrap |
| 3 | `achievement_screen.dart` | 212 | M | 1 | `gutter = 12` magic |
| 4 | `badge_collection.dart` | 278-279 | M | 1 | `spacing:12` di Wrap |
| 5 | `badge_collection.dart` | 273 | M | 1 | `gutter = 12` magic |
| 6 | `badge_collection.dart` | 476-477 | M | 1 | `Positioned(-8,-8)` |
| 7 | `level_roadmap.dart` | 115 | M | 1 | `EdgeInsets.only(bottom:12`) |
| 8 | `level_roadmap.dart` | 203 | M | 1 | `spacing:8, runSpacing:4` |
| 9 | `xp_history_list.dart` | 196 | M | 1 | `EdgeInsets.only(top:8`) |
| 10 | `xp_history_list.dart` | 226 | M | 1 | `EdgeInsets.only(top:20`) |
| 11 | `xp_history_list.dart` | 234,254 | L | 1 | `Divider(height:1`) |
| 12 | `celebration_screen.dart` | 213,265 | M | 1 | Confetti emojiSize hardcoded |
| 13 | `celebration_screen.dart` | 357-601 | M | 1 | `Offset(0.8,0.8)` animation |
| 14 | `celebration_screen.dart` | 123-126 | M | 6 | 232 AnimatedBuilder overload |
| 15 | `badge_collection.dart` | 167 | L | 6 | `ListView(children:)` 3 item |
| 16 | `xp_history_list.dart` | 109-117 | L | 6 | Sort/group tiap rebuild |
| 17 | `celebration_screen.dart` | 206-308 | M | 9 | Duplikasi confetti code |
| 18 | `celebration_screen.dart` | 673-676 | L | 9 | Ternary dead branch |
| 19 | `celebration_screen.dart` | 747-789 | M | 7 | Bounceable tanpa Semantics |
| 20 | `hero_card.dart` | 83,124,163 | M | 7 | 3 icon dekoratif |
| 21 | `level_roadmap.dart` | 176-191 | M | 7 | Status icon tanpa Semantics |
| 22 | `celebration_screen.dart` | 349-353 | L | 7 | Hero icon |
| 23 | `achievement_provider.dart` | 113,130 | L | 9 | Indentasi method |
| 24 | `achievement_remote_datasource.dart` | 19-100 | L | 2 | Rethrow generic Exception |
| 25 | `achievement_model.dart` | 236 | L | 9 | `is Map` too broad |
| 26 | `achievement_screen.dart` | 71 | L | 4 | Unawaited `_silentRefresh()` |
| 27 | `achievement_screen.dart` | 182 | L | 7 | `Colors.orange` |
| 28 | `achievement_screen.dart` | 219-226 | L | 6 | `map().toList()` |
| 29 | `stat_card.dart` | 70 | L | 7 | Contrast depends theme |
| 30 | `achievement_remote_datasource.dart` | 13-94 | L | 2 | No per-call timeout |
| 31 | `badge_collection.dart` | 165-166 | L | 1 | `S.scale(34)` — ok |
| 32 | `celebration_screen.dart` | 246,299 | L | 1 | `emojiSize/2` BorderRadius |

---

## Profile (20)

| # | File | Line | Sev | Cat | Temuan |
|---|------|:----:|:---:|:---:|--------|
| 1 | `profile_dialogs.dart` | 128 | H | 1 | `right:-4, top:-4` tanpa S.scale |
| 2 | `profile_hero_card.dart` | 63 | M | 6 | `NetworkImage` avatar |
| 3 | `profile_dialogs.dart` | 112 | M | 6 | `NetworkImage(avatarUrl)` |
| 4 | `profile_notification_section.dart` | 48-52 | M | 2 | FCM tanpa await — race |
| 5 | `profile_dialogs.dart` | 929 | M | 8 | `context.go()` tanpa mounted |
| 6 | `crop_screen.dart` | 102 | M | 4 | `setState` tanpa mounted |
| 7-12 | Profile icon files | 6 file | M | 7 | ~6 icon dekoratif |
| 13 | `profile_hero_card.dart` | 249-270 | L | 7 | Tap target ~36px |
| 14 | `profile_dialogs.dart` | 141 | L | 7 | Delete button ~28px |
| 15 | `profile_dialogs.dart` | 679 | L | 7 | Checkbox compact |
| 16 | `profile_remote_datasource.dart` | 21-28 | L | 9 | Catch-only-rethrow |
| 17 | `profile_learning_summary.dart` | 42-48 | L | 1 | `letterSpacing` scaled |
| 18 | `profile_dialogs.dart` | 362-364 | L | 2 | Upload error swallowed |
| 19 | `profile_dialogs.dart` | 872-879 | L | 9 | Redundant ref.invalidate |
| 20 | `crop_screen.dart` | 36,38,100 | L | 9 | Campur mounted/context.mounted |

---

## Auth (27)

| # | File | Line | Sev | Cat | Temuan |
|---|------|:----:|:---:|:---:|--------|
| 1 | `login_screen.dart` | 308,319 | H | 1 | `fontSize:r(14)` bukan S.font |
| 2 | `welcome_step.dart` | 135,143 | H | 1 | `fontSize:rs(14/12)` bukan S.font |
| 3 | `notification_step.dart` | 64-209 | H | 1 | Semua `fontSize:rs()` bukan S.font |
| 4 | `position_step.dart` | 26-147 | H | 1 | Semua `fontSize:rs()` bukan S.font |
| 5 | `sound_step.dart` | 36-219 | H | 1 | Semua `fontSize:rs()` bukan S.font |
| 6 | `auth_provider.dart` | 163-166 | M | 2 | `updateProfile()` tanpa try-catch |
| 7 | `auth_remote_datasource.dart` | 46-49 | M | 2 | `logout()` tanpa try-catch |
| 8 | `onboarding/screen.dart` | 68 | M | 4 | `setState` tanpa mounted |
| 9-27 | Auth icon files | 19 line | M | 7 | 19 icon dekoratif tanpa ExcludeSemantics |

---

## Store (19)

| # | File | Line | Sev | Cat | Temuan |
|---|------|:----:|:---:|:---:|--------|
| 1 | `store_dialogs.dart` | 842 | H | 1 | `border.width:1.5` tanpa S.scale |
| 2 | `store_shop_tab.dart` | 125 | H | 1 | Card width `280/240` tanpa S.scale |
| 3-11 | Store icon files | 9 line | M | 7 | 9 icon dekoratif + tap target 30px |
| 12 | `store_dialogs.dart` | 201-204,966-969 | L | 7 | Diamond InfoRow |
| 13 | `store_skeleton.dart` | 51 | M | 6 | `ListView(children:)` |
| 14 | `store_shop_tab.dart` | 100 | M | 6 | `ListView(children:)` |
| 15 | `store_inventory_tab.dart` | 79-80 | M | 8 | Navigator pop tanpa mounted |
| 16-17 | store files | 140,187 | L | 9 | Magic `0.78` |
| 18 | `store_dialogs.dart` | 37,416,796 | L | 5 | ValueNotifier tidak dispose |
| 19 | `reward_pool_provider.dart` | 14-22 | L | 9 | Provider tidak dipakai |

---

## Leaderboard (12)

| # | File | Line | Sev | Cat | Temuan |
|---|------|:----:|:---:|:---:|--------|
| 1 | `leaderboard_screen.dart` | 131 | M | 6 | `ListView(children:)` |
| 2 | `leaderboard_screen.dart` | 74-79 | M | 6 | `ref.listen` di build() |
| 3 | `leaderboard_screen.dart` | 154-155 | M | 8 | Conditional SizedBox |
| 4-7 | Leaderboard icon files | 4 line | M | 7 | 4 icon dekoratif |
| 8-9 | leaderboard files | 92-94,19-28 | L | 9 | Magic color constants |
| 10 | `leaderboard_separator.dart` | 68-72 | L | 1 | Default params |
| 11 | All store files | all | L | 1 | `blurRadius:0` |
| 12 | `reward_pool_model.dart` | 126-130 | L | 9 | Magic thresholds 500,400 |

---

## Shared / Core (26)

| # | File | Line | Sev | Cat | Temuan |
|---|------|:----:|:---:|:---:|--------|
| 1 | `game_3d_button.dart` | 53-68 | H | 7 | GestureDetector tanpa Semantics |
| 2 | `api_client.dart` | 121 | M | 6 | New Connectivity() tiap request |
| 3 | `cloudinary_service.dart` | 15 | M | 6 | New Dio() tiap upload |
| 4 | `api_client.dart` | 108 | M | 9 | SecureStorage.clearAll di tiap 401 |
| 5 | `sound_service.dart` | 67-90 | M | 9 | playOverlapping duplikat play() |
| 6 | `app_router.dart` | 62-98 | M | 8 | Null assertion di path params |
| 7 | `main_screen.dart` | 201 | M | 7 | Bottom nav tanpa button role |
| 8 | `volume_control.dart` | 116,127 | M | 7 | Icon volume tanpa ExcludeSemantics |
| 9 | `error_body.dart` | 44 | M | 7 | Icon dekoratif |
| 10 | `app_router.dart` | 105-112 | L | 8 | Error page tanpa back button |
| 11 | `app_router.dart` | — | L | 8 | No deep-link routing |
| 12 | `sound_service.dart` | 48-81 | L | 3 | Fragile cleanup AudioPlayer |
| 13 | `volume_control.dart` | 86,124 | L | 2 | Fire-and-forget setMuted/setVolume |
| 14 | `cloudinary_service.dart` | 29-33 | L | 2 | Redundant catch |
| 15 | `main_screen.dart` | 33 | L | 9 | Magic number 5 |
| 16 | `main_screen.dart` | 81-87 | L | 6 | List screens re-created |
| 17 | `game_3d_button.dart` | 32-33 | L | 1 | Default padding unscaled |
| 18 | `connectivity_provider.dart` | 5 | L | 6 | New Connectivity() |
| 19 | `game_3d_button.dart` | 7-10 | L | 9 | darken() duplicate |

---

## File Bersih (0 isu)

- `core/utils/` — semua (10 file)
- `shared/themes/` — app_theme, bloom_theme, theme_provider, theme_parser
- `shared/services/` — fcm_service, local_notification_service, secure_storage
- `shared/providers/` — gamification_providers, auth_refresh_notifier
- `features/store/data/` — store_remote_datasource, reward_pool_remote_datasource, store_model, reward_pool_model
- `features/leaderboard/data/` — leaderboard_remote_datasource, leaderboard_provider, leaderboard_model
- `features/store/presentation/widgets/` — store_empty_state
- `features/courses/data/models/` — course_model, lesson_model, quiz_model, question_model, gamification_models

---

## Riwayat Perubahan

| Tanggal | Perubahan |
|---------|-----------|
| 31 Mei 2026 | Audit awal — 155 temuan (14H, 74M, 67L) |
