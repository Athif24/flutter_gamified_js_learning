import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/theme_provider.dart';
import 'offline_banner.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../core/providers/connectivity_provider.dart';
import '../../features/courses/presentation/providers/course_provider.dart';
import '../../features/courses/presentation/screens/course_list_screen.dart';
import '../../features/achievement/presentation/screens/achievement_screen.dart';
import '../../features/leaderboard/presentation/providers/leaderboard_provider.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/store/presentation/providers/store_provider.dart';
import '../../features/store/presentation/screens/store_screen.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/shared/presentation/providers/fetch_state_providers.dart';
import '../../features/shared/presentation/widgets/post_register_tutorial.dart';

final navIndexProvider = StateProvider<int>((_) => 0);

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});
  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _showTutorial = false;
  final _navKeys = List.generate(5, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _checkTutorial();
  }

  void _checkTutorial() {
    final auth = ref.read(authProvider);
    if (!auth.isLoggedIn || auth.user == null) {
      if (mounted) setState(() => _showTutorial = false);
      return;
    }
    if (mounted) {
      setState(
        () => _showTutorial =
            auth.wizardCompleted && !auth.user!.onboardingCompleted,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (prev, next) {
      if (prev?.user?.onboardingCompleted != next.user?.onboardingCompleted ||
          prev?.wizardCompleted != next.wizardCompleted) {
        _checkTutorial();
      }
    });

    ref.listen(connectivityProvider, (prev, next) {
      final wasOffline = prev?.valueOrNull == false;
      final nowOnline = next.valueOrNull == true;
      if (wasOffline && nowOnline) {
        ref.invalidate(coursesProvider);
        ref.invalidate(achievementFetchProvider);
        ref.invalidate(leaderboardProvider);
        ref.invalidate(storeItemsProvider);
        ref.invalidate(jewelBalanceProvider);
        ref.invalidate(inventoryProvider);
        ref.invalidate(profileProvider);
      }
    });

    final t = ref.watch(currentThemeProvider);
    final index = ref.watch(navIndexProvider);

    const screens = [
      CourseListScreen(),
      AchievementScreen(),
      LeaderboardScreen(),
      StoreScreen(),
      ProfileScreen(),
    ];

    final scaffold = Scaffold(
      backgroundColor: t.bgPrimary,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: IndexedStack(index: index, children: screens),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(current: index, t: t, navKeys: _navKeys),
    );

    if (!_showTutorial) return scaffold;

    return PostRegisterTutorial(
      theme: t,
      onComplete: () {
        ref.read(authProvider.notifier).completeOnboarding().catchError((_) {});
      },
      steps: [
        TutorialStep(
          targetKey: _navKeys[0],
          title: 'Halaman Utama — Courses',
          description:
              'Ini halaman utama! Jelajahi semua kursus JavaScript yang tersedia dan mulai perjalanan belajarmu.',
        ),
        TutorialStep(
          targetKey: _navKeys[1],
          title: 'Achievement',
          description:
              'Pantau XP, streak harian, dan badge prestasimu di sini. Semakin rajin belajar, semakin banyak pencapaian!',
        ),
        TutorialStep(
          targetKey: _navKeys[2],
          title: 'Leaderboard',
          description:
              'Lihat peringkat dan bersaing dengan developer lain. Siapa tahu kamu bisa jadi yang teratas!',
        ),
        TutorialStep(
          targetKey: _navKeys[3],
          title: 'Store',
          description:
              'Tukarkan jewel-mu dengan item-item keren dari store. Lengkapi koleksi dan tampil beda!',
        ),
        TutorialStep(
          targetKey: _navKeys[4],
          title: 'Profile',
          description:
              'Atur profil, avatar, dan pengaturan akun. Pastikan data kamu selalu terbarui!',
        ),
        TutorialStep(
          title: 'Mulai Belajar',
          description:
              'Tap salah satu kursus di halaman ini untuk mulai belajar materi dan mengerjakan quiz seru!',
        ),
        TutorialStep(
          title: 'Siap Jadi Master JavaScript!',
          description:
              'Kamu sudah siap! Jelajahi semua fitur Bloom dan raih prestasi terbaikmu. Selamat belajar! \u{1F680}',
        ),
      ],
      child: scaffold,
    );
  }
}

class _BottomNav extends ConsumerWidget {
  final int current;
  final BloomTheme t;
  final List<GlobalKey> navKeys;
  const _BottomNav({
    required this.current,
    required this.t,
    required this.navKeys,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      (Icons.menu_book_rounded, Icons.menu_book_outlined, 'Courses'),
      (Icons.emoji_events_rounded, Icons.emoji_events_outlined, 'Achievement'),
      (Icons.leaderboard_rounded, Icons.leaderboard_outlined, 'Leaderboard'),
      (Icons.storefront_rounded, Icons.storefront_outlined, 'Store'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: t.bgSurface,
        border: Border(top: BorderSide(color: t.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final sel = i == current;
              final (activeI, inactiveI, label) = e.value;

              return Expanded(
                child: Bounceable(
                  key: navKeys[i],
                  onTap: () => ref.read(navIndexProvider.notifier).state = i,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? t.accent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          sel ? activeI : inactiveI,
                          size: 22,
                          color: sel ? t.accent : t.mutedText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: GoogleFonts.nunito(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: sel ? t.accent : t.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}