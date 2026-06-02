import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/theme_provider.dart';
import '../../core/utils/responsive_utils.dart';
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
import '../services/sound_service.dart';

final navIndexProvider = StateProvider<int>((_) => 0);

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});
  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  static const _navCount = 5;
  bool _showTutorial = false;
  final _navKeys = List.generate(_navCount, (_) => GlobalKey());

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

  late final List<Widget> _screens = const [
    CourseListScreen(),
    AchievementScreen(),
    LeaderboardScreen(),
    StoreScreen(),
    ProfileScreen(),
  ];

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

    final screens = _screens;

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
        ref.read(authProvider.notifier).completeOnboarding().catchError(
          (e) => debugPrint('[MainScreen] completeOnboarding error: $e'),
        );
      },
      steps: [
        TutorialStep(
          targetKey: _navKeys[0],
          title: 'Halaman Utama — Courses',
          description:
              'Jelajahi semua kursus JavaScript yang tersedia di sini. Pilih kursus yang ingin kamu pelajari dan mulai perjalanan belajarmu!',
        ),
        TutorialStep(
          targetKey: _navKeys[1],
          title: 'Achievement',
          description:
              'Pantau XP, streak harian, dan badge prestasimu. Semakin rajin belajar, semakin banyak pencapaian yang bisa kamu raih!',
        ),
        TutorialStep(
          targetKey: _navKeys[2],
          title: 'Leaderboard',
          description:
              'Lihat peringkat dan bersaing dengan developer lain. Siapa tahu kamu bisa menjadi yang teratas!',
        ),
        TutorialStep(
          targetKey: _navKeys[3],
          title: 'Store',
          description:
              'Tukarkan jewel-mu dengan item-item keren dari store. Lengkapi koleksimu dan tampil beda dari yang lain!',
        ),
        TutorialStep(
          targetKey: _navKeys[4],
          title: 'Profile',
          description:
              'Atur profil, avatar, dan pengaturan akunmu di sini. Pastikan data kamu selalu terbarui!',
        ),
        TutorialStep(
          title: 'Mulai Belajar & Raih Prestasi!',
          description:
              'Tap salah satu kursus untuk mulai belajar. Kuasai materi, kerjakan quiz seru, kumpulkan XP, dan raih prestasi terbaikmu di Bloom! \u{1F680}',
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
            blurRadius: S.scale(context, 16),
            offset: Offset(0, S.scale(context, -2)),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: S.scale(context, 64),
          child: Row(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final sel = i == current;
              final (activeI, inactiveI, label) = e.value;

              return Expanded(
                child: Semantics(
                  button: true,
                  container: true,
                  child: Bounceable(
                  key: navKeys[i],
                  onTap: () {
                    ref.read(soundProvider).playClick();
                    ref.read(navIndexProvider.notifier).state = i;
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: S.scale(context, 12),
                          vertical: S.scale(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? t.accent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(S.scale(context, 50)),
                        ),
                        child: ExcludeSemantics(
                          child: Icon(
                            sel ? activeI : inactiveI,
                            size: S.scale(context, 22),
                            color: sel ? t.accent : t.mutedText,
                          ),
                        ),
                      ),
                      SizedBox(height: S.scale(context, 2)),
                      Text(
                        label,
                        style: GoogleFonts.nunito(
                          fontSize: S.font(context, 9),
                          fontWeight: FontWeight.w700,
                          color: sel ? t.accent : t.mutedText,
                        ),
                      ),
                    ],
                  ),
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