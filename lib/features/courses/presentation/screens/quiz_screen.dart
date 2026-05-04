import 'dart:async';
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

Color _darken(Color c, double amt) {
  final h = HSLColor.fromColor(c);
  return h.withLightness((h.lightness - amt).clamp(0.0, 1.0)).toColor();
}

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
                Game3DButton(
                  label: 'Kembali',
                  color: t.accent,
                  shadowColor: _darken(t.accent, 0.2),
                  textColor: t.accentText,
                  onTap: () {
                    ref.read(quizProvider.notifier).reset();
                    context.pop();
                  },
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

    // Guard: quiz loaded but no questions
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
              Game3DButton(
                label: 'Kembali',
                color: t.accent,
                shadowColor: _darken(t.accent, 0.2),
                textColor: t.accentText,
                onTap: () => context.pop(),
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
                  // Timer display
                  if (quiz.quiz!.timeLimit > 0) ...[
                    _TimerWidget(
                      timeLimitMinutes: quiz.quiz!.timeLimit,
                      t: t,
                      onTimeUp: () => ref.read(quizProvider.notifier).submit(widget.quizId),
                    ),
                    const SizedBox(width: 10),
                  ],
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
                    // Question card with type-specific header
                    _QuestionCard(
                      type: current.type,
                      arrangeVariant: current.arrangeVariant,
                      text: current.text,
                      t: t,
                    ).animate().fadeIn().slideY(begin: -0.05),

                    const SizedBox(height: 18),

                    // Answer widget based on question type
                    if (current.type == 'choice')
                      _ChoiceWidget(
                        options: current.optionObjects,
                        selectedId: quiz.answers[current.id]?.toString(),
                        t: t,
                        onSelect: (optionId) => ref
                            .read(quizProvider.notifier)
                            .answer(current.id, optionId),
                      )
                    else if (current.type == 'arrange' || current.type == 'complete_word')
                      _ArrangeWidget(
                        variant: current.type == 'complete_word' ? 'complete_word' : current.arrangeVariant,
                        options: current.optionObjects,
                        blocks: current.blocks,
                        questionText: current.text,
                        t: t,
                        onAnswer: (answer) => ref
                            .read(quizProvider.notifier)
                            .answer(current.id, answer),
                      )
                    else if (current.type == 'coding')
                      _CodingWidget(
                        testCases: current.testCases,
                        t: t,
                        onChanged: (v) => ref
                            .read(quizProvider.notifier)
                            .answer(current.id, v),
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

            // ── Bottom area: Feedback popup OR Bottom bar (mutually exclusive) ──
            if (quiz.lastAnswerResult != null)
              _QuizFeedbackPopup(
                result: quiz.lastAnswerResult!,
                t: t,
                isLast: quiz.isLast,
                currentQuestion: quiz.current,
                onLanjut: () {
                  ref.read(quizProvider.notifier).clearLastAnswerResult();
                  if (quiz.isLast) {
                    ref.read(quizProvider.notifier).submit(widget.quizId);
                  } else {
                    ref.read(quizProvider.notifier).next();
                  }
                },
              )
            else
              _BottomBar(quiz: quiz, quizId: widget.quizId, t: t),
          ],
        ),
      ),
    );
  }

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
          Game3DButton(
            label: 'Keluar',
            color: t.error,
            shadowColor: _darken(t.error, 0.25),
            textColor: Colors.white,
            horizontalPadding: 16,
            verticalPadding: 8,
            onTap: () {
              ref.read(quizProvider.notifier).reset();
              Navigator.pop(context);
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}

// ── Question Card with Type-Specific Header ───────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final String type;
  final String? arrangeVariant;
  final String text;
  final BloomTheme t;

  const _QuestionCard({
    required this.type,
    this.arrangeVariant,
    required this.text,
    required this.t,
  });

  ({String label, IconData icon, Color accent, bool darkBg}) get _style {
    switch (type) {
      case 'choice':
        return (label: '☑️ Pilihan Ganda', icon: Icons.check_box_rounded, accent: const Color(0xFF4ECDC4), darkBg: false);
      case 'arrange':
        return (label: '📝 ${_arrangeLabel(arrangeVariant)}', icon: Icons.sort_rounded, accent: const Color(0xFFFF9F43), darkBg: false);
      case 'coding':
        return (label: '💻 Coding', icon: Icons.code_rounded, accent: const Color(0xFF4ECDC4), darkBg: true);
      case 'essay':
        return (label: '✏️ Essay', icon: Icons.edit_note_rounded, accent: const Color(0xFF9B5DE5), darkBg: false);
      default:
        return (label: type, icon: Icons.question_mark_rounded, accent: const Color(0xFF4ECDC4), darkBg: false);
    }
  }

  static String _arrangeLabel(String? variant) {
    switch (variant) {
      case 'complete_word': return 'Lengkapi Kata';
      case 'reorder_words': return 'Susun Kata-kata';
      case 'drag_blocks':   return 'Susun Blok Kode';
      default:              return 'Susun Jawaban';
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: style.darkBg ? const Color(0xFF1A1D23) : t.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: style.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style.icon, color: style.accent, size: 14),
                const SizedBox(width: 5),
                Text(
                  style.label,
                  style: GoogleFonts.nunito(
                    color: style.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: GoogleFonts.nunito(
              color: style.darkBg ? const Color(0xFF4ECDC4) : t.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Choice Widget — A/B/C/D labels with green selection ────────────────────────────────────

class _ChoiceWidget extends StatelessWidget {
  static const _labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  static const _colors = [
    Color(0xFF4A90E2),
    Color(0xFF9B5DE5),
    Color(0xFF4ECDC4),
    Color(0xFFFF9F43),
    Color(0xFFFF6B9D),
    Color(0xFF6B73E0),
    Color(0xFF44CF87),
    Color(0xFFFF6B6B),
  ];

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
      final idx = e.key;
      final opt = e.value;
      final isSel = selectedId == opt.id;
      final label = idx < _labels.length ? _labels[idx] : '${idx + 1}';
      final color = idx < _colors.length ? _colors[idx] : t.accent;

      return Bounceable(
        onTap: () => onSelect(opt.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSel ? color.withOpacity(0.12) : t.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSel ? color : t.border,
              width: isSel ? 2.5 : 1,
            ),
            boxShadow: isSel ? [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            children: [
              // Numbered circle on the left
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSel ? color : color.withOpacity(0.1),
                  border: Border.all(
                    color: isSel ? color : color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.nunito(
                      color: isSel ? Colors.white : color,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  opt.text,
                  style: GoogleFonts.nunito(
                    color: isSel ? color : t.textPrimary,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isSel)
                Icon(Icons.check_circle_rounded, color: color, size: 20),
            ],
          ),
        ),
      ).animate(key: ValueKey(e.key)).fadeIn(delay: (50 * e.key).ms);
    }).toList(),
  );
}

// ── Arrange Widget — 3 variants ───────────────────────────────────────────────

class _ArrangeWidget extends StatelessWidget {
  final String? variant;
  final List<QuizOption> options;
  final List<String> blocks;
  final String questionText;
  final BloomTheme t;
  final Function(List<String> orderedIds) onAnswer;

  const _ArrangeWidget({
    this.variant,
    required this.options,
    required this.blocks,
    required this.questionText,
    required this.t,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    // Debug logging
    debugPrint('[_ArrangeWidget] variant: $variant');
    debugPrint('[_ArrangeWidget] blocks count: ${blocks.length}');
    debugPrint('[_ArrangeWidget] blocks: $blocks');
    debugPrint('[_ArrangeWidget] options count: ${options.length}');
    debugPrint('[_ArrangeWidget] questionText: $questionText');
    
    switch (variant) {
      case 'complete_word':
        return _CompleteWordWidget(
          options: options,
          blocks: blocks,
          questionText: questionText,
          t: t,
          onAnswer: onAnswer,
        );
      case 'reorder_words':
        return _ReorderWordsWidget(
          options: options,
          t: t,
          onAnswer: onAnswer,
        );
      case 'drag_blocks':
        return _DragBlocksWidget(
          blocks: blocks,
          options: options,
          t: t,
          onAnswer: onAnswer,
        );
      default:
        return _ReorderWordsWidget(
          options: options,
          t: t,
          onAnswer: onAnswer,
        );
    }
  }
}

// ── Complete Word Variant — Tap to Fill in Order ──────────────────────────────

class _CompleteWordWidget extends StatefulWidget {
  final List<QuizOption> options;
  final List<String> blocks;
  final String questionText;
  final BloomTheme t;
  final Function(List<String> orderedIds) onAnswer;

  const _CompleteWordWidget({
    required this.options,
    required this.blocks,
    required this.questionText,
    required this.t,
    required this.onAnswer,
  });

  @override
  State<_CompleteWordWidget> createState() => _CompleteWordWidgetState();
}

class _CompleteWordWidgetState extends State<_CompleteWordWidget> {
  // Tracks which blanks are filled: blankIndex -> optionId
  final Map<int, String> _filledBlanks = {};
  // Tracks which optionIds are used
  final Set<String> _usedOptionIds = {};

  @override
  void initState() {
    super.initState();
    // Initialize with empty state - use post frame callback to avoid
    // "modify provider during build" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAnswer([]);
    });
  }

  void _updateAnswer() {
    // Only send answer when all blanks are filled
    if (_filledBlanks.length < _getBlankCount()) {
      widget.onAnswer([]);
      return;
    }

    // Convert filledBlanks to ordered list of optionIds
    final ordered = <String>[];
    final sortedKeys = _filledBlanks.keys.toList()..sort();
    for (final key in sortedKeys) {
      ordered.add(_filledBlanks[key]!);
    }
    widget.onAnswer(ordered);
  }

  void _onChipTap(String optionId) {
    // Find the next empty blank in order
    final blankCount = _getBlankCount();
    for (int i = 0; i < blankCount; i++) {
      if (!_filledBlanks.containsKey(i)) {
        setState(() {
          _filledBlanks[i] = optionId;
          _usedOptionIds.add(optionId);
        });
        _updateAnswer();
        return;
      }
    }
  }

  void _onBlankTap(int blankIndex) {
    if (_filledBlanks.containsKey(blankIndex)) {
      final optionId = _filledBlanks[blankIndex]!;
      setState(() {
        _filledBlanks.remove(blankIndex);
        _usedOptionIds.remove(optionId);
      });
      _updateAnswer();
    }
  }

  int _getBlankCount() {
    // For complete_word, count blocks that are blanks (start with ___ or {{)
    if (widget.blocks.isNotEmpty) {
      int blankCount =0;
      for (var block in widget.blocks) {
        final isBlank = block.startsWith('___') || block.startsWith('{{');
        if (isBlank) blankCount++;
      }
      debugPrint('[CompleteWord] Blank count from blocks: $blankCount (total blocks: ${widget.blocks.length})');
      return blankCount;
    }
    
    // Fallback: count from question text
    final text = widget.questionText;
    if (text.isEmpty) return 0;
    
    // Support both: ___ and {{0}}, {{1}}
    final underscoreMatches = RegExp(r'_{3,}').allMatches(text);
    
    // For {{0}}, {{1}} etc. - need to match literal {{digits}}
    // In Dart regex: \{ = escape {, \d = digit, \} = escape }
    final curlyRegex = RegExp(r'\{\{(\d+)\}\}');
    final curlyMatches = curlyRegex.allMatches(text);
    
    final count = underscoreMatches.length + curlyMatches.length;
    debugPrint('[CompleteWord] Blank count: $count (underscore: ${underscoreMatches.length}, curly: ${curlyMatches.length})');
    return count;
  }

  String _getOptionText(String optionId) {
    return widget.options
        .firstWhere((o) => o.id == optionId,
            orElse: () => QuizOption(id: optionId, text: optionId))
        .text;
  }

  @override
  Widget build(BuildContext context) {
    final blankCount = _getBlankCount();
    final remaining = blankCount - _filledBlanks.length;
    
    // Debug logging
    debugPrint('[_CompleteWordWidget] blankCount: $blankCount');
    debugPrint('[_CompleteWordWidget] filledBlanks: $_filledBlanks');
    debugPrint('[_CompleteWordWidget] remaining: $remaining');
    debugPrint('[_CompleteWordWidget] blocks count: ${widget.blocks.length}');
    debugPrint('[_CompleteWordWidget] blocks: ${widget.blocks}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Code block with blanks
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D23),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4ECDC4).withOpacity(0.3),
            ),
          ),
          child: _buildCodeWithBlanks(),
        ),

        const SizedBox(height: 16),

        // Options chips area
        if (remaining > 0) ...[
          Row(
            children: [
              Text(
                '$remaining TERSISA',
                style: GoogleFonts.nunito(
                  color: widget.t.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.options
                .where((opt) => !_usedOptionIds.contains(opt.id))
                .map((opt) {
              return Bounceable(
                onTap: () => _onChipTap(opt.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    opt.text,
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFF4ECDC4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: widget.t.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: widget.t.success, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Semua bagian sudah terisi',
                  style: GoogleFonts.nunito(
                    color: widget.t.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCodeWithBlanks() {
    // For complete_word, blocks contain the code with blanks
    // Each block is either code text or a blank placeholder
    if (widget.blocks.isEmpty) {
      // Fallback to questionText if blocks is empty
      final text = widget.questionText;
      if (text.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red),
          ),
          child: Text(
            'DEBUG: blocks kosong! Periksa data dari backend.',
            style: GoogleFonts.nunito(color: Colors.red, fontSize: 12),
          ),
        );
      }
      
      return Text(
        text,
        style: GoogleFonts.firaCode(
          color: const Color(0xFF4ECDC4),
          fontSize: 13,
          height: 1.6,
        ),
      );
    }

    // Build widgets from blocks
    final widgets = <Widget>[];
    int blankIndex = 0;
    int blankCount = 0;

    for (int i = 0; i < widget.blocks.length; i++) {
      final block = widget.blocks[i];
      
      // Check if this block is a blank (starts with ___ or {{)
      final isBlank = block.startsWith('___') || block.startsWith('{{');
      
      if (isBlank) {
        blankCount++;
        final capturedBlankIndex = blankIndex;
        // This is a blank - show as tappable widget
        final isFilled = _filledBlanks.containsKey(blankIndex);
        final filledText = isFilled
            ? _getOptionText(_filledBlanks[blankIndex]!)
            : '';

        widgets.add(
          Bounceable(
            onTap: () => _onBlankTap(capturedBlankIndex),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isFilled
                    ? const Color(0xFF4ECDC4).withOpacity(0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: isFilled
                      ? const Color(0xFF4ECDC4)
                      : Colors.white.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isFilled ? filledText : '___',
                style: GoogleFonts.firaCode(
                  color: isFilled
                      ? const Color(0xFF4ECDC4)
                      : Colors.white.withOpacity(0.3),
                  fontSize: 13,
                  fontWeight:
                      isFilled ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
        blankIndex++;
      } else {
        // This is code text - show as normal text
        widgets.add(
          Text(
            block,
            style: GoogleFonts.firaCode(
              color: const Color(0xFF4ECDC4),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        );
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: widgets,
    );
  }
}

// ── Reorder Words Variant — Tap to Answer in Order ─────────────────────────

class _ReorderWordsWidget extends StatefulWidget {
  final List<QuizOption> options;
  final BloomTheme t;
  final Function(List<String> orderedIds) onAnswer;

  const _ReorderWordsWidget({
    required this.options,
    required this.t,
    required this.onAnswer,
  });

  @override
  State<_ReorderWordsWidget> createState() => _ReorderWordsWidgetState();
}

class _ReorderWordsWidgetState extends State<_ReorderWordsWidget> {
  // Words that have been tapped (in answer area)
  final List<QuizOption> _answerWords = [];
  // Words still available in options
  late List<QuizOption> _availableWords;

  @override
  void initState() {
    super.initState();
    _availableWords = List.from(widget.options);
    // No need to call widget.onAnswer here - wait for user interaction
  }

  void _onOptionTap(QuizOption option) {
    setState(() {
      _availableWords.remove(option);
      _answerWords.add(option);
    });
    _updateAnswer();
  }

  void _onAnswerTap(QuizOption option) {
    setState(() {
      _answerWords.remove(option);
      _availableWords.add(option);
    });
    _updateAnswer();
  }

  void _updateAnswer() {
    widget.onAnswer(_answerWords.map((o) => o.id).toList());
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Answer area at top with placeholder text
      Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.t.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _answerWords.isNotEmpty
                ? widget.t.accent.withOpacity(0.5)
                : widget.t.border,
            width: _answerWords.isNotEmpty ? 2 : 1,
          ),
        ),
        child: _answerWords.isEmpty
            ? Text(
                'Ketuk kata di bawah untuk menyusun jawaban...',
                style: GoogleFonts.nunito(
                  color: widget.t.textHint,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _answerWords.map((word) {
                  return Bounceable(
                    onTap: () => _onAnswerTap(word),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: widget.t.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.t.accent.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            word.text,
                            style: GoogleFonts.nunito(
                              color: widget.t.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.close_rounded,
                            color: widget.t.accent,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),

      const SizedBox(height: 16),

      // Word chips below as options
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _availableWords.map((opt) {
          return Bounceable(
            onTap: () => _onOptionTap(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: widget.t.border),
              ),
              child: Text(
                opt.text,
                style: GoogleFonts.nunito(
                  color: widget.t.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

// ── Drag Blocks Variant — Code Reorder ──────────────────────────────────

class _CodeBlockItem {
  final String id;
  final String text;
  const _CodeBlockItem({required this.id, required this.text});
}

class _DragBlocksWidget extends StatefulWidget {
  final List<String> blocks;
  final List<QuizOption> options;
  final BloomTheme t;
  final Function(List<String> orderedIds) onAnswer;

  const _DragBlocksWidget({
    required this.blocks,
    required this.options,
    required this.t,
    required this.onAnswer,
  });

  @override
  State<_DragBlocksWidget> createState() => _DragBlocksWidgetState();
}

class _DragBlocksWidgetState extends State<_DragBlocksWidget> {
  late List<_CodeBlockItem> _orderedBlocks;

  @override
  void initState() {
    super.initState();
    _initBlocks();
  }

  void _initBlocks() {
    if (widget.blocks.isNotEmpty) {
      _orderedBlocks = widget.blocks
          .map((b) => _CodeBlockItem(id: 'block_${widget.blocks.indexOf(b)}', text: b))
          .toList();
    } else {
      _orderedBlocks = widget.options
          .map((o) => _CodeBlockItem(id: o.id, text: o.text))
          .toList();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAnswer(_orderedBlocks.map((b) => b.id).toList());
    });
  }

  void _shuffle() {
    setState(() {
      _orderedBlocks.shuffle();
    });
    widget.onAnswer(_orderedBlocks.map((b) => b.id).toList());
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Language label + Drag Block label + Acak Ulang button
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'JAVASCRIPT',
              style: GoogleFonts.firaCode(
                color: const Color(0xFF4ECDC4),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Drag Block',
            style: GoogleFonts.nunito(
              color: widget.t.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Bounceable(
            onTap: _shuffle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: widget.t.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shuffle_rounded, color: widget.t.accent, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Acak Ulang',
                    style: GoogleFonts.nunito(
                      color: widget.t.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      // Draggable code blocks
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _orderedBlocks.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _orderedBlocks.removeAt(oldIndex);
            _orderedBlocks.insert(newIndex, item);
          });
          widget.onAnswer(_orderedBlocks.map((b) => b.id).toList());
        },
        itemBuilder: (_, i) {
          final block = _orderedBlocks[i];
          return Container(
            key: ValueKey(block.id),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D23),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                // Drag handle — left side
                Container(
                  width: 44,
                  height: 50,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.drag_handle_rounded,
                    color: Colors.white30,
                    size: 22,
                  ),
                ),
                // Line number
                Container(
                  width: 26,
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.firaCode(
                      color: Colors.white30,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Code content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 12, 12),
                    child: Text(
                      block.text,
                      style: GoogleFonts.firaCode(
                        color: const Color(0xFF4ECDC4),
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}

// ── Essay Widget — Improved ───────────────────────────────────────────────────

class _EssayWidget extends StatefulWidget {
  final BloomTheme t;
  final Function(String) onChanged;

  const _EssayWidget({required this.t, required this.onChanged});

  @override
  State<_EssayWidget> createState() => _EssayWidgetState();
}

class _EssayWidgetState extends State<_EssayWidget> {
  final _controller = TextEditingController();
  static const _maxChars = 500;
  int _charCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Instruction hint
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: widget.t.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.edit_rounded, color: widget.t.info, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tulis jawabanmu dengan jelas dan lengkap',
                style: GoogleFonts.nunito(
                  color: widget.t.info,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),

      // Text area
      Container(
        decoration: BoxDecoration(
          color: widget.t.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.t.border),
        ),
        child: TextField(
          controller: _controller,
          maxLines: 8,
          maxLength: _maxChars,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
          onChanged: (v) {
            setState(() {
              _charCount = v.length;
            });
            widget.onChanged(v);
          },
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: widget.t.textPrimary,
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText: 'Tulis jawaban essay di sini...\n\nContoh: var dapat di-reassign dan di-redeclare, sedangkan let hanya bisa di-reassign...',
            hintStyle: GoogleFonts.nunito(
              color: widget.t.textHint,
              fontSize: 13,
              height: 1.6,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
            counterText: '',
          ),
        ),
      ),

      // Character counter
      Padding(
        padding: const EdgeInsets.only(top: 8, left: 4),
        child: Text(
          '$_charCount/$_maxChars',
          style: GoogleFonts.nunito(
            color: _charCount > _maxChars * 0.9
                ? widget.t.error
                : widget.t.textHint,
            fontSize: 11,
          ),
        ),
      ),
    ],
  );
}

// ── Coding Widget — IDE-style ─────────────────────────────────────────────────

class _CodingWidget extends StatefulWidget {
  final List<TestCaseModel> testCases;
  final BloomTheme t;
  final Function(String) onChanged;

  const _CodingWidget({
    required this.testCases,
    required this.t,
    required this.onChanged,
  });

  @override
  State<_CodingWidget> createState() => _CodingWidgetState();
}

class _CodingWidgetState extends State<_CodingWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleTests = widget.testCases.where((tc) => !tc.isHidden).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction hint
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF4ECDC4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.terminal_rounded, color: const Color(0xFF4ECDC4), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tulis kode JavaScript yang benar',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF4ECDC4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Test cases section
        if (visibleTests.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.play_circle_outline_rounded, color: widget.t.warning, size: 16),
              const SizedBox(width: 6),
              Text(
                'Test Cases',
                style: GoogleFonts.nunito(
                  color: widget.t.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.t.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${visibleTests.length}',
                  style: GoogleFonts.nunito(
                    color: widget.t.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...visibleTests.asMap().entries.map((e) {
            final idx = e.key;
            final tc = e.value;
            return _TestCaseCard(
              index: idx + 1,
              input: tc.input,
              expectedOutput: tc.expectedOutput,
              t: widget.t,
            ).animate().fadeIn(delay: (60 * idx).ms);
          }),
          const SizedBox(height: 12),
        ],

        // Code editor
        Row(
          children: [
            Icon(Icons.code_rounded, color: const Color(0xFF4ECDC4), size: 16),
            const SizedBox(width: 6),
            Text(
              'Code Editor',
              style: GoogleFonts.nunito(
                color: widget.t.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // IDE-style code block
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D23),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Window title bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF252830),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
                  ),
                ),
                child: Row(
                  children: [
                    _Dot(widget.t.error),
                    const SizedBox(width: 5),
                    _Dot(widget.t.accent),
                    const SizedBox(width: 5),
                    _Dot(widget.t.success),
                    const SizedBox(width: 10),
                    Text(
                      'javascript',
                      style: GoogleFonts.firaCode(
                        color: Colors.white30,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Code input
              Padding(
                padding: const EdgeInsets.all(14),
                child: TextField(
                  controller: _controller,
                  maxLines: 12,
                  expands: false,
                  onChanged: widget.onChanged,
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF4ECDC4),
                    fontSize: 13,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: '// tulis kode JavaScript di sini\nfunction solution() {\n  \n}',
                    hintStyle: GoogleFonts.firaCode(
                      color: Colors.white30,
                      fontSize: 13,
                      height: 1.6,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  scrollPhysics: const BouncingScrollPhysics(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TestCaseCard extends StatelessWidget {
  final int index;
  final String input;
  final String expectedOutput;
  final BloomTheme t;

  const _TestCaseCard({
    required this.index,
    required this.input,
    required this.expectedOutput,
    required this.t,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1D23),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: t.warning.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: t.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                'Test $index',
                style: GoogleFonts.nunito(
                  color: t.warning,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (input.isNotEmpty) ...[
          _TestLine(label: 'Input', value: input, isOutput: false, t: t),
          const SizedBox(height: 4),
        ],
        if (expectedOutput.isNotEmpty)
          _TestLine(label: 'Expected', value: expectedOutput, isOutput: true, t: t),
      ],
    ),
  );
}

class _TestLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isOutput;
  final BloomTheme t;

  const _TestLine({
    required this.label,
    required this.value,
    required this.isOutput,
    required this.t,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label: ',
        style: GoogleFonts.nunito(
          color: isOutput ? const Color(0xFF44CF87) : const Color(0xFF9B8FFF),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: GoogleFonts.firaCode(
            color: isOutput ? const Color(0xFF44CF87) : const Color(0xFF9B8FFF),
            fontSize: 11,
          ),
        ),
      ),
    ],
  );
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

// ── Inline Answer Feedback Banner ───────────────────────────────────────

class _QuizFeedbackPopup extends StatelessWidget {
  final SubmitAnswerResponse result;
  final BloomTheme t;
  final bool isLast;
  final QuestionModel? currentQuestion;
  final VoidCallback onLanjut;

  const _QuizFeedbackPopup({
    required this.result,
    required this.t,
    required this.isLast,
    this.currentQuestion,
    required this.onLanjut,
  });

  static const _correctBg = Color(0xFF15803d);
  static const _correctBtn = Color(0xFF166534);
  static const _incorrectBg = Color(0xFF991b1b);
  static const _incorrectBtn = Color(0xFF7f1d1d);

  String _formatCorrectAnswer(dynamic correctAnswer) {
    if (correctAnswer == null) return '';
    if (correctAnswer is String) return correctAnswer;
    if (correctAnswer is List) return correctAnswer.join(', ');
    if (correctAnswer is Map) return correctAnswer['text']?.toString() ?? correctAnswer.toString();
    return correctAnswer.toString();
  }

  String _getWrongAnswerSubtext() {
    // Try to get correct answer from API response
    if (result.correctAnswer != null) {
      final formatted = _formatCorrectAnswer(result.correctAnswer);
      if (formatted.isNotEmpty) {
        return 'Kunci jawaban: $formatted';
      }
    }
    
    // Fallback to feedback from API
    if (result.feedback != null && result.feedback!.isNotEmpty) {
      return result.feedback!;
    }
    
    // Generic fallback
    return 'Jawaban salah, coba lagi!';
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = result.isCorrect;
    final bgColor = isCorrect ? _correctBg : _incorrectBg;
    final btnColor = isCorrect ? _correctBtn : _incorrectBtn;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildAnimatedIcon(isCorrect),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isCorrect ? 'Jawaban Tepat!' : 'Jawaban Salah',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          result.isCorrect
                              ? 'Kamu menjawab dengan benar'
                              : _getWrongAnswerSubtext(),
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Game3DButton(
              label: isLast ? 'SELESAI' : 'LANJUT',
              color: btnColor,
              shadowColor: _darken(btnColor, 0.2),
              textColor: Colors.white,
              horizontalPadding: 28,
              verticalPadding: 13,
              onTap: onLanjut,
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildAnimatedIcon(bool isCorrect) {
    final icon = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCorrect ? Icons.check : Icons.close,
        color: Colors.white,
        size: 24,
      ),
    );

    return isCorrect
        ? icon.animate().scale(
            begin: const Offset(0.5, 0.5),
            duration: 200.ms,
            curve: Curves.bounceOut,
          )
        : icon.animate().shakeX(duration: 300.ms);
  }
}

// ── Game3DButton (Duolingo-style 3D press effect) ─────────────────────────

class Game3DButton extends StatefulWidget {
  final String? label;
  final Widget? child;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final VoidCallback? onTap;
  final bool isLoading;
  final double horizontalPadding;
  final double verticalPadding;

  const Game3DButton({
    this.label,
    this.child,
    required this.color,
    required this.shadowColor,
    required this.textColor,
    this.onTap,
    this.isLoading = false,
    this.horizontalPadding = 28,
    this.verticalPadding = 13,
  }) : assert(label != null || child != null, 'Either label or child must be provided');

  @override
  State<Game3DButton> createState() => _Game3DButtonState();
}

class _Game3DButtonState extends State<Game3DButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null && !widget.isLoading;
    final faceColor = isDisabled ? const Color(0xFFE5E5E5) : widget.color;
    final shadow = isDisabled ? const Color(0xFFC0C0C0) : widget.shadowColor;
    final txtColor = isDisabled ? const Color(0xFFB0B0B0) : widget.textColor;

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null ? (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      } : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(0, _pressed ? 4.0 : 0.0, 0),
        padding: EdgeInsets.symmetric(
          horizontal: widget.horizontalPadding,
          vertical: widget.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: faceColor,
          borderRadius: BorderRadius.circular(50),
          border: Border(
            bottom: BorderSide(
              color: _pressed ? Colors.transparent : shadow,
              width: _pressed ? 0 : 4,
            ),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: txtColor,
                ),
              )
            : (widget.child ??
                Text(
                  widget.label!,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: txtColor,
                    letterSpacing: 0.5,
                  ),
                )),
      ),
    );
  }
}

// ── Bottom Bar (LEWATI kiri, PERIKSA kanan) ─────────────────────────────────

class _BottomBar extends ConsumerWidget {
  final QuizState quiz;
  final String quizId;
  final BloomTheme t;

  const _BottomBar({required this.quiz, required this.quizId, required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAns = quiz.current != null && quiz.answers.containsKey(quiz.current!.id);
    final isLast = quiz.isLast;
    final popupShowing = quiz.lastAnswerResult != null;

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
            // LEWATI button (bottom left)
            Game3DButton(
              label: 'LEWATI',
              color: t.bgSurface2,
              shadowColor: t.border,
              textColor: t.textSecondary,
              horizontalPadding: 20,
              verticalPadding: 12,
              onTap: popupShowing || quiz.isSubmitting || quiz.isSubmittingAnswer
                  ? null
                  : () async {
                      if (isLast) {
                        // Last question: submit answer first if exists, then submit quiz
                        if (hasAns) {
                          await ref.read(quizProvider.notifier).submitCurrentAnswer();
                        }
                        ref.read(quizProvider.notifier).submit(quizId);
                      } else {
                        ref.read(quizProvider.notifier).next();
                      }
                    },
            ),

            const SizedBox(width: 12),

            // Spacer to push PERIKSA to the right
            const Spacer(),

            // PERIKSA button (bottom right)
            Game3DButton(
              label: isLast ? 'SELESAI' : 'PERIKSA',
              color: hasAns ? t.accent : const Color(0xFFE5E5E5),
              shadowColor: hasAns ? _darken(t.accent, 0.2) : const Color(0xFFC0C0C0),
              textColor: hasAns ? t.accentText : const Color(0xFFB0B0B0),
              isLoading: quiz.isSubmitting || quiz.isSubmittingAnswer,
              onTap: (hasAns && !quiz.isSubmitting && !quiz.isSubmittingAnswer && !popupShowing)
                  ? () async {
                      // Only submit answer, don't navigate - popup will handle navigation
                      await ref.read(quizProvider.notifier).submitCurrentAnswer();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Timer Widget ──────────────────────────────────────────────────────

class _TimerWidget extends StatefulWidget {
  final int timeLimitMinutes;
  final BloomTheme t;
  final VoidCallback onTimeUp;

  const _TimerWidget({
    required this.timeLimitMinutes,
    required this.t,
    required this.onTimeUp,
  });

  @override
  State<_TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<_TimerWidget> with TickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeLimitMinutes * 60;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        widget.onTimeUp();
      } else {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 60) {
            _pulseController.forward(from: 0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String get _display {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  bool get _isWarning => _remainingSeconds <= 60;

  @override
  Widget build(BuildContext context) {
    final color = _isWarning ? widget.t.error : widget.t.accent;
    return _pulseController.isAnimating
        ? ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.15).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: _TimerChip(display: _display, color: color, t: widget.t),
          )
        : _TimerChip(display: _display, color: color, t: widget.t);
  }
}

class _TimerChip extends StatelessWidget {
  final String display;
  final Color color;
  final BloomTheme t;
  const _TimerChip({required this.display, required this.color, required this.t});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          display,
          style: GoogleFonts.firaCode(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

// ── Result Screen ─────────────────────────────────────────────────────

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

                // Review answers (if there are question results)
                if (result.questionResults.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Game3DButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_rounded,
                            color: t.accent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Lihat Jawaban',
                          style: GoogleFonts.nunito(
                            color: t.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    color: Colors.transparent,
                    shadowColor: t.accent,
                    textColor: t.accent,
                    horizontalPadding: 20,
                    verticalPadding: 13,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => _ReviewDialog(
                          questionResults: result.questionResults,
                          questions: ref.read(quizProvider).quiz?.questions ?? [],
                          t: t,
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 550.ms),
                ],

                const SizedBox(height: 20),

                // Kembali ke peta belajar
                Game3DButton(
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
                  color: t.accent,
                  shadowColor: _darken(t.accent, 0.2),
                  textColor: t.accentText,
                  horizontalPadding: 20,
                  verticalPadding: 15,
                  onTap: () {
                    ref.read(quizProvider.notifier).reset();
                    context.pop();
                    context.pop();
                  },
                ).animate().fadeIn(delay: 600.ms),

                // Coba lagi (jika belum lulus)
                if (!result.passed) ...[
                  const SizedBox(height: 12),
                  Game3DButton(
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
                    color: Colors.transparent,
                    shadowColor: t.accent,
                    textColor: t.accent,
                    horizontalPadding: 20,
                    verticalPadding: 15,
                    onTap: () {
                        ref.read(quizProvider.notifier).reset();
                        onRetry();
                      },
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

// ── Review Dialog ─────────────────────────────────────────────────────

class _ReviewDialog extends StatelessWidget {
  final List<QuestionResultModel> questionResults;
  final List<QuestionModel> questions;
  final BloomTheme t;

  const _ReviewDialog({
    required this.questionResults,
    required this.questions,
    required this.t,
  });

  String _findCorrectText(QuestionModel q, QuestionResultModel qr) {
    if (qr.correctAnswer is String) return qr.correctAnswer as String;
    if (qr.correctAnswer is List) return (qr.correctAnswer as List).join(', ');
    if (qr.correctAnswer is Map) return qr.correctAnswer['text']?.toString() ?? '';
    for (final opt in q.optionObjects) {
      if (opt.id == qr.correctAnswer.toString()) return opt.text;
    }
    return qr.correctAnswer?.toString() ?? '';
  }

  String _findUserText(QuestionModel q, QuestionResultModel qr) {
    if (qr.userAnswer is String) return qr.userAnswer as String;
    if (qr.userAnswer is List) return (qr.userAnswer as List).join(', ');
    if (qr.userAnswer is Map) return qr.userAnswer['text']?.toString() ?? '';
    for (final opt in q.optionObjects) {
      if (opt.id == qr.userAnswer.toString()) return opt.text;
    }
    return qr.userAnswer?.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: t.bgSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Lihat Jawaban',
                  style: GoogleFonts.nunito(
                      color: t.textPrimary, fontSize: 18,
                      fontWeight: FontWeight.w900)),
              const Spacer(),
              Bounceable(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close_rounded, color: t.textSecondary, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: questionResults.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final qr = questionResults[i];
                final q = questions.firstWhere(
                  (qq) => qq.id == qr.questionId,
                  orElse: () => QuestionModel(id: qr.questionId, text: 'Soal #$i', type: 'choice', points: 10),
                );
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: qr.isCorrect ? t.success.withOpacity(0.08) : t.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: qr.isCorrect ? t.success.withOpacity(0.3) : t.error.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            qr.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: qr.isCorrect ? t.success : t.error,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(q.text,
                                style: GoogleFonts.nunito(
                                    color: t.textPrimary, fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!qr.isCorrect) ...[
                        Text('Jawabanmu: ${_findUserText(q, qr)}',
                            style: GoogleFonts.nunito(
                                color: t.error, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('Benar: ${_findCorrectText(q, qr)}',
                            style: GoogleFonts.nunito(
                                color: t.success, fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ] else
                        Text('Jawaban: ${_findUserText(q, qr)}',
                            style: GoogleFonts.nunito(
                                color: t.success, fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
