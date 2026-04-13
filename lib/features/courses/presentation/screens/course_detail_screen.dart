import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../providers/course_provider.dart';
import '../../data/models/course_model.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;
  /// false = Versi 1 (1 bubble per materi, quiz di dalam lesson screen)
  /// true  = Versi 2 (2 bubble: materi kanan, quiz kiri)
  final bool showQuizBubbles;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.showQuizBubbles = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t           = ref.watch(currentThemeProvider);
    final courseAsync = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: courseAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: t.accent)),
        error: (e, _) => _ErrorBody(t: t, message: e.toString(),
            onRetry: () => ref.refresh(courseDetailProvider(courseId))),
        data: (course) => _Body(
          course         : course,
          t              : t,
          ref            : ref,
          courseId       : courseId,
          showQuizBubbles: showQuizBubbles,
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final CourseModel course;
  final BloomTheme t;
  final WidgetRef ref;
  final String courseId;
  final bool showQuizBubbles;

  const _Body({
    required this.course, required this.t,
    required this.ref, required this.courseId,
    required this.showQuizBubbles,
  });

  int get _total => course.units.fold(0, (s, u) => s + u.lessons.length);
  int get _done  => course.units.fold(0, (s, u) =>
      s + u.lessons.where((l) => l.isCompleted).length);
  double get _pct => _total > 0 ? _done / _total : 0;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Sticky header ──────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 170,
          pinned: true,
          backgroundColor: t.bgPrimary,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Bounceable(
              onTap: () => context.pop(),
              child: Container(
                decoration: BoxDecoration(
                    color: t.bgSurface2, shape: BoxShape.circle,
                    border: Border.all(color: t.border)),
                child: Icon(Icons.arrow_back_ios_rounded,
                    color: t.textPrimary, size: 16),
              ),
            ),
          ),
          actions: [
            if (!course.isEnrolled)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Bounceable(
                  onTap: () async {
                    try {
                      await ref.read(courseDsProvider).enrollCourse(courseId);
                      ref.invalidate(courseDetailProvider(courseId));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Berhasil enroll! 🎉',
                              style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                          backgroundColor: t.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.toString().replaceAll('Exception: ', ''),
                              style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                          backgroundColor: t.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ));
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: t.accent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text('Enroll',
                        style: GoogleFonts.nunito(
                            color: t.accentText,
                            fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [t.accent.withOpacity(0.3), t.info.withOpacity(0.2)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(children: [
                    _Pill(t, '$_total Materi', Icons.menu_book_outlined),
                    const SizedBox(width: 8),
                    _Pill(t, '${course.units.length} Unit', Icons.layers_outlined),
                    const SizedBox(width: 8),
                    _Pill(t, '${(_pct * 100).toInt()}% Selesai',
                        Icons.check_circle_outline_rounded),
                  ]),
                  const SizedBox(height: 8),
                  Text(course.title,
                      style: GoogleFonts.nunito(
                          color: t.textPrimary, fontSize: 20,
                          fontWeight: FontWeight.w900),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    percent: _pct, lineHeight: 8,
                    backgroundColor: t.bgSurface3,
                    progressColor: t.accent,
                    barRadius: const Radius.circular(4),
                    padding: EdgeInsets.zero, animation: true,
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Peta Belajar header ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(children: [
              Icon(Icons.map_outlined, color: t.accent, size: 18),
              const SizedBox(width: 8),
              Text('Peta Belajar', style: GoogleFonts.nunito(
                  color: t.textPrimary, fontSize: 17,
                  fontWeight: FontWeight.w900)),
              const Spacer(),
              // Label versi aktif
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: t.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: t.accent.withOpacity(0.3)),
                ),
                child: Text(
                  showQuizBubbles ? 'Versi 2' : 'Versi 1',
                  style: GoogleFonts.nunito(
                      color: t.accent, fontSize: 9,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ]).animate().fadeIn(),
          ),
        ),

        // ── Units ──────────────────────────────────────────────────────
        course.units.isEmpty
            ? SliverFillRemaining(child: _EmptyState(t: t))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _UnitSection(
                    unit           : course.units[i],
                    unitIndex      : i,
                    t              : t,
                    courseId       : courseId,
                    showQuizBubbles: showQuizBubbles,
                  ).animate().fadeIn(delay: (100 * i).ms),
                  childCount: course.units.length,
                ),
              ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── Pill ──────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final BloomTheme t;
  final String label;
  final IconData icon;
  const _Pill(this.t, this.label, this.icon);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: t.bgSurface.withOpacity(0.3),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: t.textPrimary),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.nunito(
          color: t.textPrimary, fontSize: 11,
          fontWeight: FontWeight.w700)),
    ]),
  );
}

// ── PathNode ──────────────────────────────────────────────────────────────────

class _PathNode {
  final String id, title, type;
  final bool isQuiz, isCompleted, isLocked;
  /// Hanya diisi di Versi 1: ID quiz yang terkait dengan materi ini
  final String? quizId;

  const _PathNode({
    required this.id, required this.title, required this.type,
    required this.isQuiz, required this.isCompleted, required this.isLocked,
    this.quizId,
  });
}

// ── Unit Section ──────────────────────────────────────────────────────────────

class _UnitSection extends StatelessWidget {
  final UnitModel unit;
  final int unitIndex;
  final BloomTheme t;
  final String courseId;
  final bool showQuizBubbles;

  const _UnitSection({
    required this.unit, required this.unitIndex,
    required this.t, required this.courseId,
    required this.showQuizBubbles,
  });

  bool get _allDone => unit.lessons.isNotEmpty &&
      unit.lessons.every((l) => l.isCompleted);
  int get _done => unit.lessons.where((l) => l.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    final nodes = <_PathNode>[];

    if (showQuizBubbles) {
      // ── VERSI 2: Materi (kanan) + Quiz (kiri) ────────────────────────
      for (int i = 0; i < unit.lessons.length; i++) {
        final lesson     = unit.lessons[i];
        // Kunci lesson jika lesson sebelumnya belum selesai
        final lessonLock = i > 0 && !unit.lessons[i - 1].isCompleted;

        nodes.add(_PathNode(
          id         : lesson.id,
          title      : lesson.title,
          type       : lesson.type,
          isQuiz     : false,
          isCompleted: lesson.isCompleted,
          isLocked   : lessonLock,
        ));

        // Tambahkan bubble quiz yang terkait dengan lesson ini
        for (final quiz in unit.quizzes) {
          if (quiz.lessonId == lesson.id) {
            nodes.add(_PathNode(
              id         : quiz.id,
              title      : quiz.title,
              type       : 'quiz',
              isQuiz     : true,
              isCompleted: quiz.isPassed,
              isLocked   : !lesson.isCompleted || quiz.isLocked,
            ));
          }
        }
      }
    } else {
      // ── VERSI 1: Hanya materi, quiz dilampirkan sebagai quizId ───────
      for (int i = 0; i < unit.lessons.length; i++) {
        final lesson     = unit.lessons[i];
        final lessonLock = i > 0 && !unit.lessons[i - 1].isCompleted;

        // Cari quiz yang cocok untuk lesson ini
        final quiz = unit.quizzes
            .where((q) => q.lessonId == lesson.id)
            .firstOrNull;

        nodes.add(_PathNode(
          id         : lesson.id,
          title      : lesson.title,
          type       : lesson.type,
          isQuiz     : false,
          isCompleted: lesson.isCompleted,
          isLocked   : lessonLock,
          quizId     : quiz?.id,
        ));
      }
    }

    final activeIdx = nodes.indexWhere((n) => !n.isCompleted && !n.isLocked);

    return Column(children: [
      // BAB header
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color : _allDone ? t.success.withOpacity(0.1) : t.bgSurface2,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: _allDone ? t.success : t.border),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: t.accent, borderRadius: BorderRadius.circular(50)),
              child: Text('BAB ${unitIndex + 1}', style: GoogleFonts.nunito(
                  color: t.accentText, fontWeight: FontWeight.w900, fontSize: 10)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(unit.title, style: GoogleFonts.nunito(
                color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                overflow: TextOverflow.ellipsis)),
            Text('$_done/${unit.lessons.length}',
                style: GoogleFonts.nunito(
                  color: _allDone ? t.success : t.textSecondary,
                  fontSize: 12, fontWeight: FontWeight.w700,
                )),
            if (_allDone) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_circle_rounded, color: t.success, size: 16),
            ],
          ]),
        ),
      ),

      // Path nodes dengan garis tengah
      Stack(children: [
        Positioned.fill(
          child: Center(
            child: Container(width: 2, color: t.border),
          ),
        ),
        Column(
          children: nodes.asMap().entries.map((e) {
            // V2: materi selalu kanan, quiz selalu kiri
            // V1: zigzag biasa (index genap = kanan)
            final isRight = showQuizBubbles
                ? !e.value.isQuiz
                : e.key % 2 == 0;

            return _NodeWidget(
              node           : e.value,
              isActive       : e.key == activeIdx,
              isRight        : isRight,
              t              : t,
              courseId       : courseId,
              showQuizBubbles: showQuizBubbles,
            ).animate().fadeIn(delay: (50 * e.key).ms);
          }).toList(),
        ),
      ]),

      const SizedBox(height: 8),
      Divider(color: t.border, indent: 20, endIndent: 20),
      const SizedBox(height: 8),
    ]);
  }
}

// ── Node Widget ───────────────────────────────────────────────────────────────

class _NodeWidget extends StatelessWidget {
  final _PathNode node;
  final bool isActive, isRight;
  final BloomTheme t;
  final String courseId;
  final bool showQuizBubbles;

  const _NodeWidget({
    required this.node, required this.isActive,
    required this.isRight, required this.t,
    required this.courseId, required this.showQuizBubbles,
  });

  Color get _circleColor {
    if (node.isCompleted) return t.success;
    if (isActive) return node.isQuiz ? const Color(0xFF9B8FFF) : t.accent;
    return t.bgSurface3;
  }

  Color get _borderColor {
    if (node.isCompleted) return t.success;
    if (isActive) return node.isQuiz ? const Color(0xFF9B8FFF) : t.accent;
    return t.border;
  }

  String get _statusLabel {
    if (node.isCompleted) return node.isQuiz ? 'LULUS ✓' : 'SELESAI ✓';
    if (isActive) return node.isQuiz ? 'KERJAKAN' : 'AKTIF';
    return node.isQuiz ? 'SETELAH MATERI' : 'TERKUNCI';
  }

  Color get _statusColor {
    if (node.isCompleted) return t.success;
    if (isActive) return node.isQuiz ? const Color(0xFF9B8FFF) : t.accent;
    return t.textHint;
  }

  void _onTap(BuildContext context) {
    if (node.isLocked && !isActive) return;

    if (node.isQuiz) {
      // Quiz bubble (hanya Versi 2)
      context.push('/quiz/${node.id}?courseId=$courseId');
    } else {
      // Lesson bubble
      if (showQuizBubbles || node.quizId == null) {
        // V2: tidak ada quizId di lesson screen
        context.push('/lesson/${node.id}?courseId=$courseId');
      } else {
        // V1: kirim quizId agar lesson screen bisa navigasi ke quiz
        context.push('/lesson/${node.id}?courseId=$courseId&quizId=${node.quizId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = node.isLocked && !isActive;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment:
            isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.44,
            child: Bounceable(
              onTap: () => _onTap(context),
              child: Opacity(
                opacity: locked ? 0.45 : 1.0,
                child: Column(children: [
                  _NodeCircle(
                    isActive   : isActive,
                    isCompleted: node.isCompleted,
                    isQuiz     : node.isQuiz,
                    circleColor: _circleColor,
                    borderColor: _borderColor,
                    type       : node.type,
                    hasQuiz    : !showQuizBubbles && node.quizId != null,
                  ),
                  const SizedBox(height: 6),
                  Text(node.title,
                      style: GoogleFonts.nunito(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: locked ? t.textHint : t.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color : _statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: _statusColor.withOpacity(0.4)),
                    ),
                    child: Text(_statusLabel, style: GoogleFonts.nunito(
                        color: _statusColor, fontSize: 9,
                        fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Node Circle ───────────────────────────────────────────────────────────────

class _NodeCircle extends StatelessWidget {
  final bool isActive, isCompleted, isQuiz, hasQuiz;
  final Color circleColor, borderColor;
  final String type;

  const _NodeCircle({
    required this.isActive, required this.isCompleted,
    required this.isQuiz, required this.circleColor,
    required this.borderColor, required this.type,
    this.hasQuiz = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon;
    if (isCompleted) {
      icon = const Icon(Icons.check_rounded, color: Colors.white, size: 26);
    } else if (isQuiz) {
      icon = Icon(isActive ? Icons.quiz_rounded : Icons.quiz_outlined,
          color: isActive ? Colors.white : Colors.white38, size: 22);
    } else {
      icon = Icon(_iconForType(type),
          color: isActive ? Colors.white : Colors.white38, size: 20);
    }

    final circle = Stack(
      children: [
        Container(
          width: 58, height: 58,
          decoration: BoxDecoration(
            shape    : BoxShape.circle,
            color    : circleColor,
            border   : Border.all(color: borderColor, width: 3),
            boxShadow: isActive ? [BoxShadow(
              color: circleColor.withOpacity(0.5),
              blurRadius: 18, spreadRadius: 2,
            )] : null,
          ),
          child: Center(child: icon),
        ),
        // Badge quiz kecil di pojok kanan atas (Versi 1 saja)
        if (hasQuiz && !isCompleted)
          Positioned(
            top: 0, right: 0,
            child: Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                color : const Color(0xFF9B8FFF),
                shape : BoxShape.circle,
                border: Border.all(color: Colors.black26, width: 1.5),
              ),
              child: const Center(
                child: Icon(Icons.quiz_rounded, size: 10, color: Colors.white),
              ),
            ),
          ),
      ],
    );

    if (!isActive) return circle;
    return circle.animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08),
               duration: 900.ms, curve: Curves.easeInOut);
  }

  IconData _iconForType(String t) => switch (t) {
    'video'  => Icons.play_circle_outline_rounded,
    'coding' => Icons.code_rounded,
    _        => Icons.menu_book_outlined,
  };
}

// ── Empty & Error ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final BloomTheme t;
  const _EmptyState({required this.t});

  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('📚', style: TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      Text('Belum ada materi', style: GoogleFonts.nunito(
          color: t.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('Materi akan segera ditambahkan', style: GoogleFonts.nunito(
          color: t.textSecondary, fontSize: 13)),
    ],
  ));
}

class _ErrorBody extends StatelessWidget {
  final BloomTheme t;
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.t, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('😢', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('Gagal memuat kursus', style: GoogleFonts.nunito(
          color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
      const SizedBox(height: 8),
      Text(message, style: GoogleFonts.nunito(
          color: t.textSecondary, fontSize: 12),
          textAlign: TextAlign.center, maxLines: 3),
      const SizedBox(height: 22),
      Bounceable(
        onTap: onRetry,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
          decoration: BoxDecoration(
              color: t.accent, borderRadius: BorderRadius.circular(50)),
          child: Text('Coba Lagi', style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800, color: t.accentText)),
        ),
      ),
    ]),
  ));
}