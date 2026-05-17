import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../data/models/course_model.dart';

class ChoiceQuestion extends StatelessWidget {
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

  const ChoiceQuestion({
    super.key,
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
            color: isSel ? color.withValues(alpha: 0.12) : t.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSel ? color : t.border,
              width: isSel ? 2.5 : 1,
            ),
            boxShadow: isSel ? [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSel ? color : color.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isSel ? color : color.withValues(alpha: 0.3),
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
