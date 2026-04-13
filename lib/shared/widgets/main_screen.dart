import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/theme_provider.dart';
import '../../features/courses/presentation/screens/course_list_screen.dart';
import '../../features/achievement/presentation/screens/achievement_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/store/presentation/screens/store_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

final navIndexProvider = StateProvider<int>((_) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t     = ref.watch(currentThemeProvider);
    final index = ref.watch(navIndexProvider);

    const screens = [
      CourseListScreen(),
      AchievementScreen(),
      LeaderboardScreen(),
      StoreScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: _BottomNav(current: index, t: t),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  final int current;
  final BloomTheme t;
  const _BottomNav({required this.current, required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      (Icons.menu_book_rounded,    Icons.menu_book_outlined,      'Courses'),
      (Icons.emoji_events_rounded, Icons.emoji_events_outlined,   'Achievement'),
      (Icons.leaderboard_rounded,  Icons.leaderboard_outlined,    'Leaderboard'),
      (Icons.storefront_rounded,   Icons.storefront_outlined,     'Store'),
      (Icons.person_rounded,       Icons.person_outline_rounded,  'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: t.bgSurface,
        border: Border(top: BorderSide(color: t.border)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16, offset: const Offset(0, -2),
        )],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: items.asMap().entries.map((e) {
              final i   = e.key;
              final sel = i == current;
              final (activeI, inactiveI, label) = e.value;

              return Expanded(
                child: Bounceable(
                  onTap: () =>
                      ref.read(navIndexProvider.notifier).state = i,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: sel
                              ? t.accent.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          sel ? activeI : inactiveI,
                          size: 22,
                          color: sel ? t.accent : t.textHint,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(label, style: GoogleFonts.nunito(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        color: sel ? t.accent : t.textHint,
                      )),
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