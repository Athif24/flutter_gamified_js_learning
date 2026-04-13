import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../achievement/presentation/providers/achievement_provider.dart';
import '../../../achievement/data/models/achievement_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t          = ref.watch(currentThemeProvider);
    final auth       = ref.watch(authProvider);
    final xpAsync    = ref.watch(xpProvider);
    final streakAsync = ref.watch(streakProvider);
    final badgesAsync = ref.watch(userBadgesProvider);
    final reportAsync = ref.watch(learningReportProvider);
    final name    = auth.user?.name ?? 'Mahasiswa';
    final email   = auth.user?.email ?? '';
    final initials = _initials(name);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(children: [

            // ── Profile hero ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [t.accent.withOpacity(0.25),
                      t.info.withOpacity(0.15)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: t.accent.withOpacity(0.3)),
              ),
              child: Row(children: [
                // Avatar
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.bgSurface.withOpacity(0.3),
                    border: Border.all(color: t.accent, width: 2),
                  ),
                  child: Center(child: Text(initials, style: GoogleFonts.nunito(
                      color: t.accent, fontSize: 22,
                      fontWeight: FontWeight.w900))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.nunito(
                        color: t.textPrimary, fontSize: 18,
                        fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(email, style: GoogleFonts.nunito(
                        color: t.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    xpAsync.maybeWhen(
                      data: (xp) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: t.bgSurface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text('// ${xp.levelTitle}',
                            style: GoogleFonts.firaCode(
                                color: t.accent, fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                )),
                Bounceable(onTap: () {}, child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: t.bgSurface.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_outlined, color: t.textPrimary, size: 16),
                )),
              ]),
            ).animate().fadeIn(),

            const SizedBox(height: 14),

            // ── XP Progress ──────────────────────────────────────────
            xpAsync.maybeWhen(
              data: (xp) => _XpBar(t: t, xp: xp)
                  .animate().fadeIn(delay: 100.ms),
              orElse: () => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // ── Stats ────────────────────────────────────────────────
            _SectionLabel(t: t, text: 'STATISTIK'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: xpAsync.maybeWhen(
                data: (xp) => _StatBox(t: t, value: '${xp.totalXp}',
                    label: 'TOTAL XP', color: t.accent),
                orElse: () => _StatBox(t: t, value: '—',
                    label: 'TOTAL XP', color: t.accent),
              )),
              const SizedBox(width: 10),
              Expanded(child: streakAsync.maybeWhen(
                data: (s) => _StatBox(t: t, value: '${s.currentStreak}',
                    label: 'STREAK', color: t.warning),
                orElse: () => _StatBox(t: t, value: '—',
                    label: 'STREAK', color: t.warning),
              )),
              const SizedBox(width: 10),
              Expanded(child: reportAsync.maybeWhen(
                data: (r) => _StatBox(t: t,
                    value: '${r.averageScore.toInt()}%',
                    label: 'AKURASI', color: t.success),
                orElse: () => _StatBox(t: t, value: '—',
                    label: 'AKURASI', color: t.success),
              )),
            ]).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 20),

            // ── Lencana ──────────────────────────────────────────────
            _SectionLabel(t: t, text: 'LENCANA'),
            const SizedBox(height: 10),
            badgesAsync.when(
              loading: () => _Skeleton(t: t, height: 100),
              error: (_, __) => const SizedBox.shrink(),
              data: (badges) => badges.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: t.bgSurface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: t.border),
                      ),
                      child: Center(child: Text('Belum ada lencana',
                          style: GoogleFonts.nunito(
                              color: t.textSecondary))),
                    )
                  : SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: badges.length,
                        itemBuilder: (_, i) {
                          final b = badges[i];
                          return Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 68,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: b.isEarned
                                  ? t.accent.withOpacity(0.1)
                                  : t.bgSurface2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: b.isEarned
                                    ? t.accent.withOpacity(0.4)
                                    : t.border),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(b.icon,
                                    style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(b.name, style: GoogleFonts.nunito(
                                    color: b.isEarned ? t.accent : t.textHint,
                                    fontSize: 8, fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 20),

            // ── Warna Tema ────────────────────────────────────────────
            _SectionLabel(t: t, text: 'TEMA TAMPILAN'),
            const SizedBox(height: 10),
            _ThemePicker(t: t).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 20),

            // ── Akun & Keamanan ───────────────────────────────────────
            _SectionLabel(t: t, text: 'AKUN & KEAMANAN'),
            const SizedBox(height: 10),
            _AccountSection(t: t).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            // ── Logout ────────────────────────────────────────────────
            Bounceable(
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: t.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: t.error.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Icon(Icons.logout_rounded, color: t.error, size: 18),
                  const SizedBox(width: 10),
                  Text('Keluar Akun', style: GoogleFonts.nunito(
                      color: t.error, fontWeight: FontWeight.w700,
                      fontSize: 14)),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded, color: t.error, size: 16),
                ]),
              ),
            ).animate().fadeIn(delay: 350.ms),
          ]),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// ── XP Bar ────────────────────────────────────────────────────────────────────

class _XpBar extends StatelessWidget {
  final BloomTheme t;
  final XpModel xp;
  const _XpBar({required this.t, required this.xp});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: t.bgSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: t.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Menuju ${xp.levelTitle}', style: GoogleFonts.nunito(
            color: t.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('${xp.totalXp} / ${xp.xpToNextLevel}',
            style: GoogleFonts.nunito(
                color: t.textSecondary, fontSize: 12)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(5),
        child: LinearProgressIndicator(
          value: xp.progress,
          backgroundColor: t.bgSurface3,
          valueColor: AlwaysStoppedAnimation(t.accent),
          minHeight: 10,
        ),
      ),
    ]),
  );
}

// ── Theme Picker ──────────────────────────────────────────────────────────────

class _ThemePicker extends ConsumerWidget {
  final BloomTheme t;
  const _ThemePicker({required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentId = ref.watch(themeProvider).themeId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Wrap(
        spacing: 10, runSpacing: 10,
        children: bloomThemeList.map((theme) {
          final sel = theme.id == currentId;
          return Bounceable(
            onTap: () => ref.read(themeProvider.notifier).setTheme(theme.id),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: theme.accent,
                  shape: BoxShape.circle,
                  border: sel ? Border.all(color: Colors.white, width: 3) : null,
                  boxShadow: sel ? [BoxShadow(
                    color: theme.accent.withOpacity(0.5),
                    blurRadius: 10, spreadRadius: 1,
                  )] : null,
                ),
                child: Center(child: sel
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18)
                    : Text(theme.emoji,
                        style: const TextStyle(fontSize: 16))),
              ),
              const SizedBox(height: 4),
              Text(theme.name, style: GoogleFonts.nunito(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: sel ? theme.accent : t.textSecondary)),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ── Account section ───────────────────────────────────────────────────────────

class _AccountSection extends ConsumerWidget {
  final BloomTheme t;
  const _AccountSection({required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: t.info.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('📧',
                style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('EMAIL LOGIN', style: GoogleFonts.nunito(
                color: t.textSecondary, fontSize: 10,
                fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            Text(auth.user?.email ?? '', style: GoogleFonts.nunito(
                color: t.textPrimary, fontSize: 13,
                fontWeight: FontWeight.w600)),
          ]),
        ]),
        Divider(height: 20, color: t.border),
        Row(children: [
          Expanded(child: Bounceable(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: t.info.withOpacity(0.12),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: t.info.withOpacity(0.3)),
              ),
              child: Center(child: Text('🔒 Ubah Password',
                  style: GoogleFonts.nunito(
                      color: t.info, fontWeight: FontWeight.w700,
                      fontSize: 12))),
            ),
          )),
        ]),
        const SizedBox(height: 8),
        Text(
          'Untuk keamanan, ganti password secara berkala.',
          style: GoogleFonts.nunito(
              color: t.textHint, fontSize: 10),
        ),
      ]),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final BloomTheme t;
  final String text;
  const _SectionLabel({required this.t, required this.text});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: GoogleFonts.nunito(
        fontSize: 11, fontWeight: FontWeight.w800,
        color: t.textSecondary, letterSpacing: 1.5)),
  );
}

class _StatBox extends StatelessWidget {
  final BloomTheme t;
  final String value, label;
  final Color color;
  const _StatBox({required this.t, required this.value,
      required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Column(children: [
      Text(value, style: GoogleFonts.nunito(
          color: color, fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      Text(label, style: GoogleFonts.nunito(
          color: t.textSecondary, fontSize: 9,
          fontWeight: FontWeight.w700, letterSpacing: 0.3)),
    ]),
  );
}

class _Skeleton extends StatelessWidget {
  final BloomTheme t;
  final double height;
  const _Skeleton({required this.t, required this.height});
  @override
  Widget build(BuildContext context) => Container(
      height: height,
      decoration: BoxDecoration(
          color: t.bgSurface2, borderRadius: BorderRadius.circular(14)))
      .animate(onPlay: (c) => c.repeat())
      .shimmer(duration: 1200.ms, color: t.bgSurface3);
}