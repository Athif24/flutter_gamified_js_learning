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

class QuizScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String? courseId;

  const QuizScreen({super.key, required this.quizId, this.courseId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(quizProvider.notifier).load(widget.quizId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final quiz = ref.watch(quizProvider);

    // Loading
    if (quiz.quiz == null && quiz.error == null) {
      return Scaffold(
        backgroundColor: t.bgPrimary,
        body: Center(child: CircularProgressIndicator(color: t.accent)),
      );
    }

    // Error
    if (quiz.error != null) {
      return Scaffold(
        backgroundColor: t.bgPrimary,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('😢', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat kuis',
                  style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  quiz.error!,
                  style: GoogleFonts.nunito(
                    color: t.textSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Bounceable(
                  onTap: () {
                    ref.read(quizProvider.notifier).reset();
                    context.pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: t.accent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Kembali',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: t.accentText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Result screen
    if (quiz.isFinished) {
      return _ResultScreen(
        result: quiz.result!,
        t: t,
        courseId: widget.courseId,
        quizId: widget.quizId,
        onRetry: () => ref.read(quizProvider.notifier).load(widget.quizId),
      );
    }

    // Guard: quiz loaded but no questions (shouldn't happen after load() fix)
    if (quiz.quiz == null || quiz.quiz!.questions.isEmpty) {
      return Scaffold(
        backgroundColor: t.bgPrimary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📋', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                'Belum ada soal',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Soal untuk kuis ini belum ditambahkan.',
                style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 22),
              Bounceable(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: t.accent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Kembali',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      color: t.accentText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final questions = quiz.quiz!.questions;
    final current = quiz.current!;
    final progress = (quiz.currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Bounceable(
                    onTap: () => _confirmExit(context, t),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t.bgSurface2,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.border),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: t.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      quiz.quiz!.title,
                      style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: t.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: t.accent.withOpacity(0.3)),
                    ),
                    child: Text(
                      '⭐ +${current.points} XP',
                      style: GoogleFonts.nunito(
                        color: t.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Text(
                    '${quiz.currentIndex + 1}',
                    style: GoogleFonts.nunito(
                      color: t.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '/${questions.length}',
                    style: GoogleFonts.nunito(
                      color: t.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LinearPercentIndicator(
                      percent: progress,
                      lineHeight: 10,
                      backgroundColor: t.bgSurface3,
                      progressColor: t.accent,
                      barRadius: const Radius.circular(5),
                      padding: EdgeInsets.zero,
                      animation: true,
                      animateFromLastPercent: true,
                    ),
                  ),
                ],
              ),
            ),

            // ── Question ───────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: t.bgSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: t.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: t.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              _typeLabel(current.type),
                              style: GoogleFonts.nunito(
                                color: t.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            current.text,
                            style: GoogleFonts.nunito(
                              color: t.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.05),

                    const SizedBox(height: 18),

                    // Answer widget berdasarkan tipe soal
                    if (current.type == 'choice')
                      _ChoiceWidget(
                        options: current.optionObjects,
                        // selected = option ID yang dipilih
                        selectedId: quiz.answers[current.id]?.toString(),
                        t: t,
                        onSelect: (optionId) => ref
                            .read(quizProvider.notifier)
                            .answer(current.id, optionId),
                      )
                    else if (current.type == 'arrange')
                      _ArrangeWidget(
                        options: current.optionObjects,
                        t: t,
                        onAnswer: (answer) => ref
                            .read(quizProvider.notifier)
                            .answer(current.id, answer),
                      )
                    else
                      _EssayWidget(
                        t: t,
                        onChanged: (v) => ref
                            .read(quizProvider.notifier)
                            .answer(current.id, v),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Bottom bar ─────────────────────────────────────────────────
            _BottomBar(quiz: quiz, quizId: widget.quizId, t: t),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
    'arrange' => '📝 Susun Jawaban',
    'choice' => '☑️ Pilihan Ganda',
    'coding' => '💻 Coding',
    _ => '✏️ Essay',
  };

  void _confirmExit(BuildContext context, BloomTheme t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: t.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Keluar dari Kuis?',
          style: GoogleFonts.nunito(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Progress kuis akan hilang.',
          style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Lanjut',
              style: GoogleFonts.nunito(
                color: t.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Bounceable(
            onTap: () {
              ref.read(quizProvider.notifier).reset();
              Navigator.pop(context);
              context.pop();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: t.error,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                'Keluar',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Choice Widget — jawaban berdasarkan option ID ─────────────────────────────

class _ChoiceWidget extends StatelessWidget {
  final List<QuizOption> options;
  final String? selectedId;
  final BloomTheme t;
  final Function(String optionId) onSelect;

  const _ChoiceWidget({
    required this.options,
    this.selectedId,
    required this.t,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: options.asMap().entries.map((e) {
      final opt = e.value;
      final isSel = selectedId == opt.id;
      return Bounceable(
        onTap: () => onSelect(opt.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSel ? t.accent.withOpacity(0.1) : t.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSel ? t.accent : t.border,
              width: isSel ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSel ? t.accent : Colors.transparent,
                  border: Border.all(
                    color: isSel ? t.accent : t.textSecondary,
                    width: 2,
                  ),
                ),
                child: isSel
                    ? Icon(Icons.check_rounded, size: 13, color: t.accentText)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  opt.text,
                  style: GoogleFonts.nunito(
                    color: isSel ? t.accent : t.textPrimary,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate(key: ValueKey(e.key)).fadeIn(delay: (50 * e.key).ms);
    }).toList(),
  );
}

// ── Arrange Widget ────────────────────────────────────────────────────────────

class _ArrangeWidget extends StatefulWidget {
  final List<QuizOption> options;
  final BloomTheme t;
  final Function(List<String> orderedIds) onAnswer;

  const _ArrangeWidget({
    required this.options,
    required this.t,
    required this.onAnswer,
  });

  @override
  State<_ArrangeWidget> createState() => _ArrangeWidgetState();
}

class _ArrangeWidgetState extends State<_ArrangeWidget> {
  late List<QuizOption> _ordered;

  // @override
  // void initState() {
  //   super.initState();
  //   _ordered = List.from(widget.options);
  //   // Kirim urutan awal
  //   widget.onAnswer(_ordered.map((o) => o.id).toList());
  // }
  @override
  void initState() {
    super.initState();
    _ordered = List.from(widget.options);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAnswer(_ordered.map((o) => o.id).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Urutkan jawaban dengan drag & drop:',
            style: GoogleFonts.nunito(
              color: widget.t.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _ordered.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _ordered.removeAt(oldIndex);
              _ordered.insert(newIndex, item);
            });
            widget.onAnswer(_ordered.map((o) => o.id).toList());
          },
          itemBuilder: (_, i) {
            final opt = _ordered[i];
            return Container(
              key: ValueKey(opt.id),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.t.bgSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.t.accent.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.t.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: GoogleFonts.nunito(
                          color: widget.t.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      opt.text,
                      style: GoogleFonts.nunito(
                        color: widget.t.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.drag_handle_rounded,
                    color: widget.t.textHint,
                    size: 20,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Essay Widget ──────────────────────────────────────────────────────────────

class _EssayWidget extends StatelessWidget {
  final BloomTheme t;
  final Function(String) onChanged;
  const _EssayWidget({required this.t, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: t.bgSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: t.border),
    ),
    child: TextField(
      onChanged: onChanged,
      maxLines: 5,
      style: GoogleFonts.firaCode(fontSize: 13, color: t.textPrimary),
      decoration: InputDecoration(
        hintText: 'Tulis jawabanmu di sini...',
        hintStyle: GoogleFonts.nunito(color: t.textHint, fontSize: 13),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
      ),
    ),
  );
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────

class _BottomBar extends ConsumerWidget {
  final QuizState quiz;
  final String quizId;
  final BloomTheme t;
  const _BottomBar({required this.quiz, required this.quizId, required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAns =
        quiz.current != null && quiz.answers.containsKey(quiz.current!.id);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: t.bgSurface,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (quiz.currentIndex > 0) ...[
              Bounceable(
                onTap: () => ref.read(quizProvider.notifier).prev(),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    shape: BoxShape.circle,
                    border: Border.all(color: t.border),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: t.accent,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Bounceable(
                onTap: (hasAns && !quiz.isSubmitting)
                    ? () {
                        if (quiz.isLast) {
                          ref.read(quizProvider.notifier).submit(quizId);
                        } else {
                          ref.read(quizProvider.notifier).next();
                        }
                      }
                    : () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: hasAns ? t.accent : t.bgSurface3,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: hasAns
                        ? [
                            BoxShadow(
                              color: t.accent.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: quiz.isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: t.accentText,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                quiz.isLast ? 'Submit Kuis' : 'Lanjut',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: hasAns ? t.accentText : t.textHint,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                quiz.isLast
                                    ? Icons.send_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                                color: hasAns ? t.accentText : t.textHint,
                              ),
                            ],
                          ),
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

// ── Result Screen ─────────────────────────────────────────────────────────────

class _ResultScreen extends ConsumerWidget {
  final QuizResultModel result;
  final BloomTheme t;
  final String? courseId;
  final String quizId;
  final VoidCallback onRetry;

  const _ResultScreen({
    required this.result,
    required this.t,
    required this.courseId,
    required this.quizId,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = result.percentage.round();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (courseId?.isNotEmpty ?? false) {
        ref.invalidate(courseDetailProvider(courseId!));
      }
    });

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  result.passed ? '🏆' : '😅',
                  style: const TextStyle(fontSize: 80),
                ).animate().scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 700.ms,
                  curve: Curves.elasticOut,
                ),

                const SizedBox(height: 20),
                Text(
                  result.passed ? 'Luar Biasa! 🎉' : 'Belum Berhasil',
                  style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 8),
                Text(
                  result.passed
                      ? 'Kamu berhasil melewati kuis ini!'
                      : 'Nilai kamu $pct%. Kerjakan lagi untuk mendapat nilai lebih baik.',
                  style: GoogleFonts.nunito(
                    color: t.textSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 28),

                // Score card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: result.passed
                          ? [t.accent.withOpacity(0.3), t.info.withOpacity(0.2)]
                          : [
                              t.error.withOpacity(0.2),
                              t.error.withOpacity(0.1),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: result.passed
                          ? t.accent.withOpacity(0.3)
                          : t.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(t, '📊', '$pct%', 'Nilai'),
                      Container(
                        width: 1,
                        height: 50,
                        color: t.textSecondary.withOpacity(0.2),
                      ),
                      _Stat(
                        t,
                        '🎯',
                        '${result.score}/${result.totalPoints}',
                        'Poin',
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: t.textSecondary.withOpacity(0.2),
                      ),
                      _Stat(t, '⭐', '+${result.xpEarned}', 'XP'),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.15),

                const SizedBox(height: 28),

                // Kembali ke peta belajar
                Bounceable(
                  onTap: () {
                    ref.read(quizProvider.notifier).reset();
                    context.pop();
                    context.pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: t.accent,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: t.accent.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, color: t.accentText, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Kembali ke Peta Belajar',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: t.accentText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),

                // Coba lagi (jika belum lulus)
                if (!result.passed) ...[
                  const SizedBox(height: 12),
                  Bounceable(
                    onTap: () {
                      ref.read(quizProvider.notifier).reset();
                      onRetry();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: t.accent, width: 1.5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.replay_rounded, color: t.accent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Coba Lagi',
                            style: GoogleFonts.nunito(
                              color: t.accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 650.ms),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final BloomTheme t;
  final String emoji, value, label;
  const _Stat(this.t, this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 6),
      Text(
        value,
        style: GoogleFonts.nunito(
          color: t.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(
        label,
        style: GoogleFonts.nunito(
          color: t.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
