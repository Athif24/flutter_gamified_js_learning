import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../achievement/presentation/providers/achievement_provider.dart';
import '../providers/course_provider.dart';
import '../../data/models/course_model.dart';

class LessonScreen extends ConsumerWidget {
  final String lessonId;
  /// courseId dipakai untuk refresh bubble setelah selesai
  final String? courseId;
  /// quizId hanya ada di Versi 1. Jika ada, tombol bawah jadi "Kerjakan Quiz"
  final String? quizId;

  const LessonScreen({
    super.key,
    required this.lessonId,
    this.courseId,
    this.quizId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t           = ref.watch(currentThemeProvider);
    final lessonAsync = ref.watch(lessonDetailProvider(lessonId));
    // quizId kosong string dianggap null
    final effectiveQuizId = (quizId?.isNotEmpty ?? false) ? quizId : null;

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: lessonAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: t.accent)),
        error: (e, _) => _ErrorBody(
            t: t, message: e.toString(),
            onRetry: () => ref.refresh(lessonDetailProvider(lessonId))),
        data: (lesson) => Column(children: [
          // ── AppBar ───────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(children: [
                Bounceable(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                        color: t.bgSurface2, shape: BoxShape.circle,
                        border: Border.all(color: t.border)),
                    child: Icon(Icons.arrow_back_ios_rounded,
                        color: t.textPrimary, size: 15),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(lesson.title,
                    style: GoogleFonts.nunito(
                        color: t.textPrimary, fontSize: 15,
                        fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: t.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: t.accent.withOpacity(0.3)),
                  ),
                  child: Text(lesson.type.toUpperCase(),
                      style: GoogleFonts.nunito(
                          color: t.accent, fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lesson.content != null)
                    _ProseMirrorRenderer(content: lesson.content!, t: t)
                        .animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Bottom button ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: t.bgSurface,
              border: Border(top: BorderSide(color: t.border)),
            ),
            child: SafeArea(
              top: false,
              child: Bounceable(
                onTap: () => _handleBottomButton(
                    context, ref, t, effectiveQuizId),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: t.accent,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [BoxShadow(
                      color: t.accent.withOpacity(0.4),
                      blurRadius: 12, offset: const Offset(0, 5),
                    )],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        effectiveQuizId != null
                            ? Icons.quiz_rounded
                            : Icons.check_rounded,
                        color: t.accentText, size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        effectiveQuizId != null
                            ? 'Kerjakan Quiz →'
                            : 'Tandai Selesai',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800, fontSize: 15,
                            color: t.accentText),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _handleBottomButton(
    BuildContext context,
    WidgetRef ref,
    BloomTheme t,
    String? effectiveQuizId,
  ) async {
    try {
      final result = await ref.read(courseDsProvider).completeLesson(lessonId);

      // Refresh bubble di course detail
      if (courseId != null) {
        ref.invalidate(courseDetailProvider(courseId!));
      }
      // Invalidate XP provider to refresh XP display
      try { ref.refresh(xpProvider); } catch (_) {}

      if (!context.mounted) return;

      // Show gamification feedback
      if (!result.alreadyCompleted) {
        final messages = <String>[];
        messages.add('+${result.xpEarned} XP');
        if (result.jewelsEarned > 0) {
          messages.add('+${result.jewelsEarned} Jewel');
        }
        if (result.streak != null) {
          messages.add('Streak: ${result.streak!.currentStreak} hari');
        }
        if (result.levelUp != null && result.levelUp!.leveledUp) {
          messages.add('Level Up: ${result.levelUp!.newLevelName ?? ''}');
        }
        for (final badge in result.badgesAwarded) {
          messages.add('Badge: ${badge.name}');
        }

        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => _GamificationDialog(
              xpEarned: result.xpEarned,
              jewelsEarned: result.jewelsEarned,
              streak: result.streak,
              levelUp: result.levelUp,
              badges: result.badgesAwarded,
              t: t,
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (context.mounted) Navigator.of(context).pop();
        }
      }

      if (!context.mounted) return;

      if (effectiveQuizId != null) {
        // Versi 1: langsung ke quiz tanpa kembali ke course detail
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Materi selesai! Sekarang kerjakan quiz',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          backgroundColor: t.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 2),
        ));
        await Future.delayed(const Duration(milliseconds: 800));
        if (context.mounted) {
          context.pushReplacement(
              '/quiz/$effectiveQuizId?courseId=${courseId ?? ''}');
        }
      } else {
        // Versi 2 / tidak ada quiz: kembali ke peta belajar
        if (!result.alreadyCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Materi selesai!',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
            backgroundColor: t.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ));
        }
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', ''),
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
          backgroundColor: t.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }
}

// ── ProseMirror Renderer ──────────────────────────────────────────────────────

class _ProseMirrorRenderer extends StatelessWidget {
  final String content;
  final BloomTheme t;
  const _ProseMirrorRenderer({required this.content, required this.t});

  @override
  Widget build(BuildContext context) {
    try {
      final doc   = jsonDecode(content) as Map<String, dynamic>;
      final nodes = doc['content'] as List? ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: nodes.map<Widget>(
            (n) => _buildNode(n as Map<String, dynamic>)).toList(),
      );
    } catch (_) {
      return Text(content, style: GoogleFonts.nunito(
          color: t.textPrimary, fontSize: 14, height: 1.7));
    }
  }

  Widget _buildNode(Map<String, dynamic> node) {
    final type    = node['type'] as String? ?? '';
    final content = node['content'] as List? ?? [];
    final attrs   = node['attrs'] as Map<String, dynamic>? ?? {};

    switch (type) {
      case 'heading':
        final level = (attrs['level'] ?? 1) as int;
        final size  = switch (level) { 1 => 20.0, 2 => 17.0, _ => 15.0 };
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(_extractText(content),
              style: GoogleFonts.nunito(
                  color: t.textPrimary, fontSize: size,
                  fontWeight: FontWeight.w800)),
        );

      case 'paragraph':
        if (content.isEmpty) return const SizedBox(height: 8);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildRichText(content),
        );

      case 'codeBlock':
        final code = attrs['code'] as String? ?? _extractText(content);
        final lang = attrs['language'] as String? ?? 'js';
        return _CodeBlock(code: code.trim(), language: lang, t: t);

      case 'bulletList':
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content.map<Widget>((item) {
              final ic = (item as Map)['content'] as List? ?? [];
              final txt = ic.isNotEmpty
                  ? _extractText((ic[0] as Map)['content'] as List? ?? [])
                  : '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7, right: 10),
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                        color: t.accent, shape: BoxShape.circle),
                  ),
                  Expanded(child: Text(txt, style: GoogleFonts.nunito(
                      color: t.textPrimary, fontSize: 14, height: 1.6))),
                ]),
              );
            }).toList(),
          ),
        );

      case 'orderedList':
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content.asMap().entries.map<Widget>((e) {
              final ic = (e.value as Map)['content'] as List? ?? [];
              final txt = ic.isNotEmpty
                  ? _extractText((ic[0] as Map)['content'] as List? ?? [])
                  : '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2, right: 10),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                        color: t.accent.withOpacity(0.15),
                        shape: BoxShape.circle),
                    child: Center(child: Text('${e.key + 1}',
                        style: GoogleFonts.nunito(
                            color: t.accent, fontSize: 11,
                            fontWeight: FontWeight.w800))),
                  ),
                  Expanded(child: Text(txt, style: GoogleFonts.nunito(
                      color: t.textPrimary, fontSize: 14, height: 1.6))),
                ]),
              );
            }).toList(),
          ),
        );

      case 'horizontalRule':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Divider(color: t.border, thickness: 1),
        );

      case 'blockquote':
        final txt = content.isNotEmpty
            ? _extractText((content[0] as Map)['content'] as List? ?? [])
            : '';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color : t.accent.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: t.accent, width: 3)),
          ),
          child: Text(txt, style: GoogleFonts.nunito(
              color: t.textSecondary, fontSize: 14,
              fontStyle: FontStyle.italic, height: 1.6)),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRichText(List content) {
    final spans = <InlineSpan>[];
    for (final inline in content) {
      final node  = inline as Map<String, dynamic>;
      final itype = node['type'] as String? ?? '';
      if (itype == 'hardBreak') { spans.add(const TextSpan(text: '\n')); continue; }

      final text   = node['text'] as String? ?? '';
      final marks  = node['marks'] as List? ?? [];
      bool bold    = false, italic = false, isCode = false;
      for (final m in marks) {
        final mt = (m as Map)['type'] as String? ?? '';
        if (mt == 'bold')   bold   = true;
        if (mt == 'italic') italic = true;
        if (mt == 'code')   isCode = true;
      }

      if (isCode) {
        spans.add(WidgetSpan(
          baseline : TextBaseline.alphabetic,
          alignment: PlaceholderAlignment.baseline,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: t.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: t.accent.withOpacity(0.2)),
            ),
            child: Text(text, style: GoogleFonts.firaCode(
                color: t.accent, fontSize: 12)),
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: text,
          style: GoogleFonts.nunito(
            color     : t.textPrimary,
            fontSize  : 14, height: 1.7,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            fontStyle : italic ? FontStyle.italic : FontStyle.normal,
          ),
        ));
      }
    }
    return RichText(text: TextSpan(children: spans));
  }

  String _extractText(List nodes) {
    final buf = StringBuffer();
    for (final n in nodes) {
      final node = n as Map<String, dynamic>;
      if (node['type'] == 'text') buf.write(node['text'] ?? '');
      if (node['type'] == 'hardBreak') buf.write('\n');
      final sub = node['content'] as List?;
      if (sub != null) buf.write(_extractText(sub));
    }
    return buf.toString();
  }
}

// ── Code Block ────────────────────────────────────────────────────────────────

class _CodeBlock extends StatelessWidget {
  final String code, language;
  final BloomTheme t;
  const _CodeBlock({required this.code, required this.language, required this.t});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1D23),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: t.accent.withOpacity(0.2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
        child: Row(children: [
          _Dot(t.error), const SizedBox(width: 5),
          _Dot(t.accent), const SizedBox(width: 5),
          _Dot(t.success),
          const Spacer(),
          Text(language.toUpperCase(), style: GoogleFonts.firaCode(
              color: Colors.white30, fontSize: 10)),
        ]),
      ),
      const Divider(color: Colors.white12, height: 1),
      Padding(
        padding: const EdgeInsets.all(14),
        child: SelectableText(code, style: GoogleFonts.firaCode(
            color: const Color(0xFF4ECDC4), fontSize: 13, height: 1.6)),
      ),
    ]),
  );
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);
  @override
  Widget build(BuildContext context) => Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

// ── Gamification Dialog ───────────────────────────────────────────────────────

class _GamificationDialog extends StatelessWidget {
  final int xpEarned;
  final int jewelsEarned;
  final StreakInfo? streak;
  final LevelUpInfo? levelUp;
  final List<BadgeInfo> badges;
  final BloomTheme t;

  const _GamificationDialog({
    required this.xpEarned,
    required this.jewelsEarned,
    this.streak,
    this.levelUp,
    this.badges = const [],
    required this.t,
  });

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text('Selesai!',
              style: GoogleFonts.nunito(
                  color: t.textPrimary, fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),

          // XP
          _RewardRow(t, '⭐', '+$xpEarned XP', t.accent),
          if (jewelsEarned > 0)
            _RewardRow(t, '💎', '+$jewelsEarned Jewel', const Color(0xFF4A90E2)),

          // Streak
          if (streak != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text('Streak ${streak!.currentStreak} hari',
                      style: GoogleFonts.nunito(
                          color: t.warning, fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),

          // Level up
          if (levelUp != null && levelUp!.leveledUp)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: t.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🚀', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text('Level Up: ${levelUp!.newLevelName ?? ''}',
                        style: GoogleFonts.nunito(
                            color: t.accent, fontSize: 14,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),

          // Badges
          for (final badge in badges)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: t.info.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏅', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text('Badge: ${badge.name}',
                        style: GoogleFonts.nunito(
                            color: t.info, fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _RewardRow extends StatelessWidget {
  final BloomTheme t;
  final String emoji, label;
  final Color color;
  const _RewardRow(this.t, this.emoji, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.nunito(
                color: color, fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final BloomTheme t;
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.t, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('😢', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('Gagal memuat materi', style: GoogleFonts.nunito(
          color: t.textPrimary, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      Bounceable(
        onTap: onRetry,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
              color: t.accent, borderRadius: BorderRadius.circular(50)),
          child: Text('Coba Lagi', style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800, color: t.accentText)),
        ),
      ),
    ],
  ));
}