import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../achievement/presentation/providers/achievement_provider.dart';
import '../providers/course_provider.dart';
import '../../data/models/course_model.dart';

class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t            = ref.watch(currentThemeProvider);
    final auth         = ref.watch(authProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final xpAsync      = ref.watch(xpProvider);
    final firstName    = (auth.user?.name ?? 'Mahasiswa').split(' ').first;

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top stats bar ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                decoration: BoxDecoration(
                  color: t.bgSurface,
                  border: Border(bottom: BorderSide(color: t.border)),
                ),
                child: Row(children: [
                  // Avatar
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: t.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: t.accent.withOpacity(0.4)),
                    ),
                    child: Center(child: Text(
                      firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                      style: GoogleFonts.nunito(
                          color: t.accent, fontWeight: FontWeight.w900,
                          fontSize: 14),
                    )),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hei, $firstName!',
                            style: GoogleFonts.nunito(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('Pilih kursus dan mulai belajar',
                            style: GoogleFonts.nunito(
                                color: t.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  // XP chip
                  xpAsync.maybeWhen(
                    data: (xp) => _StatChip(t, '⭐', '${xp.totalXp} XP', t.accent),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ]).animate().fadeIn(),
              ),
            ),

            // ── Hero banner ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: coursesAsync.maybeWhen(
                data: (courses) => Container(
                  margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [t.accent.withOpacity(0.2), t.info.withOpacity(0.1)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: t.accent.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Text('🚀', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pilih Kursusmu',
                            style: GoogleFonts.nunito(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        Text('Mulai perjalanan belajarmu dan kuasai skill baru!',
                            style: GoogleFonts.nunito(
                                color: t.textSecondary, fontSize: 12)),
                      ],
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: t.accent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text('${courses.length} Kursus',
                          style: GoogleFonts.nunito(
                              color: t.accentText,
                              fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ]),
                ).animate().fadeIn(delay: 100.ms),
                orElse: () => const SizedBox.shrink(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // ── Courses list ───────────────────────────────────────────────
            coursesAsync.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _SkeletonCard(t: t)
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 1200.ms,
                            color: t.bgSurface3.withOpacity(0.5)),
                    childCount: 3,
                  ),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: _ErrorView(t: t, message: e.toString(),
                    onRetry: () => ref.refresh(coursesProvider)),
              ),
              data: (courses) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _CourseCard(
                      course: courses[i], index: i, t: t,
                    ).animate().fadeIn(delay: (80 * i).ms)
                     .slideY(begin: 0.08, end: 0),
                    childCount: courses.length,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final BloomTheme t;
  final String emoji, label;
  final Color color;
  const _StatChip(this.t, this.emoji, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.nunito(
          color: color, fontWeight: FontWeight.w800, fontSize: 11)),
    ]),
  );
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final int index;
  final BloomTheme t;
  const _CourseCard({required this.course, required this.index, required this.t});

  static const _emojis    = ['📘','⚡','🔄','📦','🌐','🚀','🧩','💡'];
  static const _gradPairs = [
    [Color(0xFF4A90E2), Color(0xFF6B73E0)],
    [Color(0xFF9B5DE5), Color(0xFFD45FD4)],
    [Color(0xFF4ECDC4), Color(0xFF44CF87)],
    [Color(0xFFFF9F43), Color(0xFFFF6B6B)],
    [Color(0xFFFF6B9D), Color(0xFFFF9F43)],
  ];

  String get _levelLabel => switch(course.level) {
    1=>'Pemula', 2=>'Junior', 3=>'Mid Dev', 4=>'Senior', _=>'Expert',
  };

  @override
  Widget build(BuildContext context) {
    final emoji = _emojis[index % _emojis.length];
    final grad  = _gradPairs[index % _gradPairs.length];

    return Bounceable(
      onTap: () => context.push('/course/${course.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: t.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.border),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16, offset: const Offset(0, 4),
          )],
        ),
        child: Column(children: [
          // Gradient header
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: grad,
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)),
            ),
            child: Stack(children: [
              // Dot pattern
              Positioned.fill(child: CustomPaint(painter: _DotsPainter())),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(_levelLabel, style: GoogleFonts.nunito(
                            color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w800)),
                      ),
                      const Spacer(),
                      if (course.isEnrolled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text('Enrolled', style: GoogleFonts.nunito(
                              color: Colors.white, fontSize: 10,
                              fontWeight: FontWeight.w800)),
                        ),
                    ]),
                    const Spacer(),
                    Text(emoji, style: const TextStyle(fontSize: 30)),
                  ],
                ),
              ),
            ]),
          ),

          // Info area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title,
                    style: GoogleFonts.nunito(
                        color: t.textPrimary, fontSize: 15,
                        fontWeight: FontWeight.w800),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.layers_outlined, size: 13, color: t.textSecondary),
                  const SizedBox(width: 4),
                  Text('${course.units.length} Unit',
                      style: GoogleFonts.nunito(
                          color: t.textSecondary, fontSize: 11)),
                  const SizedBox(width: 12),
                  Icon(Icons.menu_book_outlined, size: 13, color: t.textSecondary),
                  const SizedBox(width: 4),
                  Text('${course.totalLessons} Materi',
                      style: GoogleFonts.nunito(
                          color: t.textSecondary, fontSize: 11)),
                ]),
                if (course.isEnrolled && course.progress > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress', style: GoogleFonts.nunito(
                          color: t.textSecondary, fontSize: 11)),
                      Text('${(course.progress * 100).toInt()}%',
                          style: GoogleFonts.nunito(
                              color: t.accent, fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: course.progress,
                      backgroundColor: t.bgSurface2,
                      valueColor: AlwaysStoppedAnimation(t.accent),
                      minHeight: 6,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: course.isEnrolled ? t.accent : t.bgSurface2,
                    borderRadius: BorderRadius.circular(50),
                    border: course.isEnrolled ? null : Border.all(color: t.border),
                  ),
                  child: Center(child: Text(
                    course.isEnrolled ? 'Lanjutkan →' : 'Mulai Belajar →',
                    style: GoogleFonts.nunito(
                      color: course.isEnrolled ? t.accentText : t.textSecondary,
                      fontWeight: FontWeight.w800, fontSize: 13,
                    ),
                  )),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.08);
    for (double x = 0; x < size.width; x += 18) {
      for (double y = 0; y < size.height; y += 18) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _SkeletonCard extends StatelessWidget {
  final BloomTheme t;
  const _SkeletonCard({required this.t});
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 16), height: 200,
      decoration: BoxDecoration(
          color: t.bgSurface, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.border)));
}

class _ErrorView extends StatelessWidget {
  final BloomTheme t;
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.t, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('😢', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('Gagal memuat kursus',
          style: GoogleFonts.nunito(color: t.textPrimary,
              fontWeight: FontWeight.w700, fontSize: 16)),
      const SizedBox(height: 8),
      Text(message, style: GoogleFonts.nunito(
          color: t.textSecondary, fontSize: 12),
          textAlign: TextAlign.center, maxLines: 3),
      const SizedBox(height: 22),
      Bounceable(
        onTap: onRetry,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
              color: t.accent, borderRadius: BorderRadius.circular(50)),
          child: Text('Coba Lagi', style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800, color: t.accentText)),
        ),
      ),
    ]),
  ));
}