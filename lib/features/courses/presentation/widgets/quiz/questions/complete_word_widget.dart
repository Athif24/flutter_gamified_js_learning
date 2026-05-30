import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/course_model.dart';

class CompleteWordWidget extends StatefulWidget {
  final List<QuizOption> options;
  final List<String> blocks;
  final String questionText;
  final BloomTheme t;
  final Function(List<String> orderedIds) onAnswer;

  const CompleteWordWidget({
    super.key,
    required this.options,
    required this.blocks,
    required this.questionText,
    required this.t,
    required this.onAnswer,
  });

  @override
  State<CompleteWordWidget> createState() => CompleteWordWidgetState();
}

class CompleteWordWidgetState extends State<CompleteWordWidget> {
  final Map<int, String> _filledBlanks = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAnswer([]);
    });
  }

  void _updateAnswer() {
    if (_filledBlanks.length < _getBlankCount()) {
      widget.onAnswer([]);
      return;
    }
    final ordered = <String>[];
    final sortedKeys = _filledBlanks.keys.toList()..sort();
    for (final key in sortedKeys) {
      ordered.add(_filledBlanks[key]!);
    }
    widget.onAnswer(ordered);
  }

  void _onChipTap(String optionId) {
    final blankCount = _getBlankCount();
    for (int i = 0; i < blankCount; i++) {
      if (!_filledBlanks.containsKey(i)) {
        setState(() {
          _filledBlanks[i] = optionId;
        });
        _updateAnswer();
        return;
      }
    }
  }

  void _onBlankTap(int blankIndex) {
    if (_filledBlanks.containsKey(blankIndex)) {
      setState(() {
        _filledBlanks.remove(blankIndex);
      });
      _updateAnswer();
    }
  }

  int _getBlankCount() {
    if (widget.blocks.isNotEmpty) {
      int blankCount = 0;
      for (var block in widget.blocks) {
        final isBlank = block.startsWith('___') || block.startsWith('{{');
        if (isBlank) blankCount++;
      }
      return blankCount;
    }
    final text = widget.questionText;
    if (text.isEmpty) return 0;
    final underscoreMatches = RegExp(r'_{3,}').allMatches(text);
    final curlyRegex = RegExp(r'\{\{(\d+)\}\}');
    final curlyMatches = curlyRegex.allMatches(text);
    return underscoreMatches.length + curlyMatches.length;
  }

  String _getOptionText(String optionId) {
    return widget.options
        .firstWhere(
          (o) => o.id == optionId,
          orElse: () => QuizOption(id: optionId, text: optionId),
        )
        .text;
  }

  @override
  Widget build(BuildContext context) {
    final blankCount = _getBlankCount();
    final remaining = blankCount - _filledBlanks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(S.scale(context, 16)),
          decoration: BoxDecoration(
            color: widget.t.bgSurface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.t.info.withValues(alpha: 0.3)),
          ),
          child: _buildCodeWithBlanks(),
        ),
        const SizedBox(height: 16),
        if (blankCount > 0) ...[
          Row(
            children: [
              Text(
                '$remaining TERSISA',
                style: GoogleFonts.nunito(
                  color: widget.t.warning,
                  fontSize: S.font(context, 12),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Wrap(
          spacing: S.scale(context, 8),
          runSpacing: S.scale(context, 8),
          children: widget.options.map((opt) {
            final filledCount = _filledBlanks.values
                .where((id) => id == opt.id)
                .length;
            final optOccurrences = widget.options
                .where((o) => o.id == opt.id)
                .length;
            final allUsed = filledCount >= optOccurrences;
            final isUsed = _filledBlanks.containsValue(opt.id);
            return Semantics(
              button: true,
              label: allUsed ? 'Sudah dipilih' : 'Pilih ${opt.text}',
              child: Bounceable(
                onTap: allUsed ? null : () => _onChipTap(opt.id),
                child: AnimatedOpacity(
                  opacity: allUsed ? 0.25 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: S.scale(context, 14),
                      vertical: S.scale(context, 8),
                    ),
                    decoration: BoxDecoration(
                      color: isUsed
                          ? widget.t.success.withValues(alpha: 0.1)
                          : widget.t.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isUsed
                            ? widget.t.success.withValues(alpha: 0.5)
                            : widget.t.info.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      opt.text,
                      style: GoogleFonts.firaCode(
                        color: isUsed ? widget.t.success : widget.t.info,
                        fontSize: S.font(context, 13),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (remaining <= 0 && blankCount > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: S.scale(context, 14),
              vertical: S.scale(context, 10),
            ),
            decoration: BoxDecoration(
              color: widget.t.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: widget.t.success,
                  size: S.scale(context, 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'Semua bagian sudah terisi',
                  style: GoogleFonts.nunito(
                    color: widget.t.success,
                    fontSize: S.font(context, 12),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildCodeWithBlanks() {
    if (widget.blocks.isEmpty) {
      final text = widget.questionText;
      if (text.isEmpty) {
        return const SizedBox.shrink();
      }
      return Text(
        text,
        style: GoogleFonts.firaCode(
          color: widget.t.info,
          fontSize: S.font(context, 13),
          height: 1.6,
        ),
      );
    }

    final widgets = <Widget>[];
    int blankIndex = 0;

    for (int i = 0; i < widget.blocks.length; i++) {
      final block = widget.blocks[i];
      final isBlank = block.startsWith('___') || block.startsWith('{{');

      if (isBlank) {
        final capturedBlankIndex = blankIndex;
        final isFilled = _filledBlanks.containsKey(blankIndex);
        final filledText = isFilled
            ? _getOptionText(_filledBlanks[blankIndex]!)
            : '';

        widgets.add(
          Semantics(
            button: true,
            label: isFilled ? filledText : 'Isi jawaban',
            child: Bounceable(
              onTap: () => _onBlankTap(capturedBlankIndex),
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: S.scale(context, 4),
                  horizontal: S.scale(context, 4),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: S.scale(context, 16),
                  vertical: S.scale(context, 8),
                ),
                decoration: BoxDecoration(
                  color: isFilled
                      ? widget.t.info.withValues(alpha: 0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isFilled
                        ? widget.t.info
                        : widget.t.textPrimary.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isFilled ? filledText : '___',
                  style: GoogleFonts.firaCode(
                    color: isFilled
                        ? widget.t.info
                        : widget.t.textPrimary.withValues(alpha: 0.3),
                    fontSize: S.font(context, 13),
                    fontWeight: isFilled ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
        blankIndex++;
      } else {
        widgets.add(
          Text(
            block,
            style: GoogleFonts.firaCode(
              color: widget.t.info,
              fontSize: S.font(context, 13),
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