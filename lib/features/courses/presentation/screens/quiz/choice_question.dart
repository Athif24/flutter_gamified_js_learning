import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../data/models/course_model.dart';

class ChoiceQuestion extends StatelessWidget {
  static const _labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  List<Color> get _colors => [
    t.primary,
    t.secondary,
    t.info,
    t.warning,
    t.success,
    t.accent,
    t.info,
    t.warning,
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
  Widget build(BuildContext context) {
    final useGrid = S.isTablet(context) && options.length >= 3;
    final halfWidth = useGrid ? (MediaQuery.of(context).size.width - S.scale(context, 30)) / 2 : null;

    final items = options.asMap().entries.map((e) {
      final idx = e.key;
      final opt = e.value;
      final isSel = selectedId == opt.id;
      final label = idx < _labels.length ? _labels[idx] : '${idx + 1}';
      final color = idx < _colors.length ? _colors[idx] : t.primary;

      Widget item = Semantics(
        button: true,
        label: 'Pilih ${opt.text}',
        child: Bounceable(
          onTap: () => onSelect(opt.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(bottom: S.scale(context, 10)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSel ? color.withValues(alpha: 0.12) : t.bgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSel ? color : t.textPrimary,
                width: 2,
              ),
              boxShadow: isSel ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ] : [
                BoxShadow(
                  color: t.textPrimary,
                  offset: const Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: S.scale(context, 32),
                  height: S.scale(context, 32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSel ? color : color.withValues(alpha: 0.1),
                    border: Border.all(
                      color: t.textPrimary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: t.textPrimary,
                        offset: const Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: GoogleFonts.nunito(
                        color: isSel ? Colors.white : color,
                        fontWeight: FontWeight.w900,
                        fontSize: S.font(context, 13),
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
                      fontSize: S.font(context, 14),
                    ),
                  ),
                ),
                if (isSel)
                  Icon(Icons.check_circle_rounded, color: color, size: 20),
              ],
            ),
          ),
        ),
      ).animate(key: ValueKey(e.key)).fadeIn(delay: (50 * e.key).ms);

      return useGrid
          ? SizedBox(width: halfWidth, child: item)
          : item;
    }).toList();

    return useGrid
        ? Wrap(spacing: 0, runSpacing: 0, children: items)
        : Column(children: items);
  }
}
