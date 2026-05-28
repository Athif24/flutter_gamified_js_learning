import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';

class QuestionCard extends StatelessWidget {
  final String type;
  final String? arrangeVariant;
  final String text;
  final BloomTheme t;
  final String? codeSnippet;

  const QuestionCard({
    super.key,
    required this.type,
    this.arrangeVariant,
    required this.text,
    required this.t,
    this.codeSnippet,
  });

  ({String label, IconData icon, Color accent, bool darkBg}) get _style {
    switch (type) {
      case 'choice':
        return (label: '\u{2611}\u{FE0F} Pilihan Ganda', icon: Icons.check_box_rounded, accent: t.info, darkBg: false);
      case 'arrange':
        return (label: '\u{1F4DD} ${_arrangeLabel(arrangeVariant)}', icon: Icons.sort_rounded, accent: t.warning, darkBg: false);
      case 'coding':
        return (label: '\u{1F4BB} Coding', icon: Icons.code_rounded, accent: t.info, darkBg: true);
      case 'essay':
        return (label: '\u{270F}\u{FE0F} Essay', icon: Icons.edit_note_rounded, accent: t.secondary, darkBg: false);
      default:
        return (label: type, icon: Icons.question_mark_rounded, accent: t.info, darkBg: false);
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
      padding: EdgeInsets.all(S.scale(context, 18)),
      decoration: BoxDecoration(
        color: style.darkBg ? t.bgSurface2 : t.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: style.accent.withValues(alpha: 0.12),
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
                    fontSize: S.font(context, 11),
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
              color: style.darkBg ? t.info : t.textPrimary,
              fontSize: S.font(context, 15),
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          if (codeSnippet != null && codeSnippet!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: t.bgSurface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: style.accent.withValues(alpha: 0.2)),
              ),
              child: Text(
                codeSnippet!,
                style: GoogleFonts.jetBrainsMono(
                  color: t.info,
                  fontSize: S.font(context, 13),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
