import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../data/models/course_model.dart';

class ArrangeQuestion extends StatelessWidget {
  final String? variant;
  final List<QuizOption> options;
  final List<String> blocks;
  final String questionText;
  final String questionId;
  final BloomTheme t;
  final Function(List<String> orderedIds) onAnswer;

  const ArrangeQuestion({
    super.key,
    this.variant,
    required this.options,
    required this.blocks,
    required this.questionText,
    required this.questionId,
    required this.t,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case 'complete_word':
        return CompleteWordWidget(
          key: ValueKey(questionId),
          options: options,
          blocks: blocks,
          questionText: questionText,
          t: t,
          onAnswer: onAnswer,
        );
      case 'reorder_words':
        return ReorderWordsWidget(
          key: ValueKey(questionId),
          options: options,
          t: t,
          onAnswer: onAnswer,
        );
      case 'drag_blocks':
        return DragBlocksWidget(
          key: ValueKey(questionId),
          blocks: blocks,
          options: options,
          t: t,
          onAnswer: onAnswer,
        );
      default:
        return ReorderWordsWidget(
          key: ValueKey(questionId),
          options: options,
          t: t,
          onAnswer: onAnswer,
        );
    }
  }
}

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
  State<CompleteWordWidget> createState() => _CompleteWordWidgetState();
}

class _CompleteWordWidgetState extends State<CompleteWordWidget> {
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
        .firstWhere((o) => o.id == optionId,
            orElse: () => QuizOption(id: optionId, text: optionId))
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
            color: const Color(0xFF1A1D23),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
            ),
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
            final filledCount = _filledBlanks.values.where((id) => id == opt.id).length;
            final optOccurrences = widget.options.where((o) => o.id == opt.id).length;
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
                          : const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isUsed
                            ? widget.t.success.withValues(alpha: 0.5)
                            : const Color(0xFF4ECDC4).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      opt.text,
                      style: GoogleFonts.firaCode(
                        color: isUsed
                            ? widget.t.success
                            : const Color(0xFF4ECDC4),
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
            padding: EdgeInsets.symmetric(horizontal: S.scale(context, 14), vertical: S.scale(context, 10)),
            decoration: BoxDecoration(
              color: widget.t.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: widget.t.success, size: S.scale(context, 16)),
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
          color: const Color(0xFF4ECDC4),
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
                margin: EdgeInsets.symmetric(vertical: S.scale(context, 4), horizontal: S.scale(context, 4)),
                padding: EdgeInsets.symmetric(
                  horizontal: S.scale(context, 16),
                  vertical: S.scale(context, 8),
                ),
                decoration: BoxDecoration(
                  color: isFilled
                      ? const Color(0xFF4ECDC4).withValues(alpha: 0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isFilled
                        ? const Color(0xFF4ECDC4)
                        : Colors.white.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isFilled ? filledText : '___',
                  style: GoogleFonts.firaCode(
                    color: isFilled
                        ? const Color(0xFF4ECDC4)
                        : Colors.white.withValues(alpha: 0.3),
                    fontSize: S.font(context, 13),
                    fontWeight:
                        isFilled ? FontWeight.w600 : FontWeight.w400,
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
              color: const Color(0xFF4ECDC4),
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

bool _detectIsCodeMode(List<QuizOption> options) {
  int score = 0;
  final symbolPattern = RegExp(r'[(){}\[\];,]');
  final operatorPattern = RegExp(r'^(==|!=|<=|>=|&&|\|\||=>|<<|>>|\+\+|--|[+\-*/%=!<>])$');
  const codeKeywords = {
    'const', 'let', 'var', 'function', 'return', 'if', 'else',
    'for', 'while', 'class', 'import', 'export', 'new', 'this',
    'cout', 'cin', 'int', 'void', 'include', 'using', 'namespace',
    'print', 'println', 'def', 'elif', 'true', 'false', 'null',
  };

  for (final opt in options) {
    final trimmed = opt.text.trim();

    if (symbolPattern.hasMatch(trimmed) && trimmed.length <= 2) score += 2;
    if (operatorPattern.hasMatch(trimmed)) score += 2;
    if (codeKeywords.contains(trimmed.toLowerCase())) score += 3;
    if (RegExp(r'^[a-zA-Z_]\w*\.[a-zA-Z_]\w*$').hasMatch(trimmed)) score += 3;
    if (trimmed.startsWith('"') || trimmed.startsWith("'")) score += 1;
    if (trimmed.length <= 2 && !RegExp(r'^[a-zA-Z]+$').hasMatch(trimmed)) score += 1;
  }

  return score >= 4;
}

bool _isLineMode(List<QuizOption> options) {
  int lineCount = 0;
  for (final opt in options) {
    final trimmed = opt.text.trim();
    if (trimmed.contains(' ') && trimmed.length > 10) lineCount++;
    if (trimmed.endsWith('{')) lineCount++;
    if (trimmed.startsWith('}')) lineCount++;
  }
  return lineCount > options.length ~/ 2;
}

class ReorderWordsWidget extends StatefulWidget {
  final List<QuizOption> options;
  final BloomTheme t;
  final Function(List<String> orderedIds) onAnswer;

  const ReorderWordsWidget({
    super.key,
    required this.options,
    required this.t,
    required this.onAnswer,
  });

  @override
  State<ReorderWordsWidget> createState() => _ReorderWordsWidgetState();
}

class _ReorderWordsWidgetState extends State<ReorderWordsWidget> {
  final List<QuizOption> _placed = [];
  late final List<QuizOption> _options;
  late final bool _isCodeMode;
  late final bool _lineMode;

  @override
  void initState() {
    super.initState();
    _options = List.from(widget.options)..shuffle();
    _isCodeMode = _detectIsCodeMode(_options);
    _lineMode = _isCodeMode && _isLineMode(_options);
  }

  void _addToken(QuizOption option) {
    setState(() {
      _placed.add(option);
    });
    _updateAnswer();
  }

  void _removeAt(int index) {
    setState(() {
      _placed.removeAt(index);
    });
    _updateAnswer();
  }

  void _updateAnswer() {
    widget.onAnswer(_placed.map((o) => o.id).toList());
  }

  bool _isOptionUsed(QuizOption option) {
    final countInOptions = _options.where((o) => o.id == option.id).length;
    final countInPlaced = _placed.where((o) => o.id == option.id).length;
    return countInPlaced >= countInOptions;
  }

  Color _getSyntaxColor(String token) {
    const keywords = {
      'const', 'let', 'var', 'function', 'return', 'if', 'else',
      'for', 'while', 'class', 'cout', 'cin', 'int', 'void',
      'true', 'false', 'null', 'undefined',
    };
    final trimmed = token.trim();
    if (keywords.contains(trimmed)) return const Color(0xFFFF7B72);
    if (trimmed.startsWith('"') || trimmed.startsWith("'")) return const Color(0xFFA5D6FF);
    if (RegExp(r'^[+\-*/%=!<>&|^~]+$').hasMatch(trimmed)) return const Color(0xFF79C0FF);
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(trimmed)) return const Color(0xFF79C0FF);
    if (RegExp(r'^[(){}\[\];,]$').hasMatch(trimmed)) return const Color(0xFFE6EDF3);
    if (trimmed.contains('.')) return const Color(0xFFD2A8FF);
    return const Color(0xFFFFA657);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isCodeMode) _buildCodeAnswerArea() else _buildWordAnswerArea(),
        const SizedBox(height: 12),
        Text(
          _isCodeMode
              ? (_lineMode ? 'Baris tersedia:' : 'Token tersedia:')
              : 'Kata tersedia:',
          style: GoogleFonts.nunito(
          fontSize: S.font(context, 11),
          fontWeight: FontWeight.w500,
          color: widget.t.mutedText,
          ),
        ),
        const SizedBox(height: 8),
        if (_isCodeMode) _buildCodeChips() else _buildWordChips(),
      ],
    );
  }

  // ---------- Word Mode ----------

  Widget _buildWordAnswerArea() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: S.scale(context, 60)),
      padding: EdgeInsets.all(S.scale(context, 12)),
      decoration: BoxDecoration(
        color: widget.t.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.t.border.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: _placed.isEmpty
          ? Text(
              'Ketuk kata di bawah untuk menyusun jawaban...',
              style: GoogleFonts.nunito(
                fontSize: S.font(context, 12),
                fontStyle: FontStyle.italic,
                color: widget.t.mutedText.withValues(alpha: 0.7),
              ),
            )
          : Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (int i = 0; i < _placed.length; i++)
                  _buildPlacedWordChip(_placed[i], i),
              ],
            ),
    );
  }

  Widget _buildPlacedWordChip(QuizOption word, int index) {
    return Semantics(
      button: true,
      label: 'Hapus ${word.text}',
      child: Bounceable(
        onTap: () => _removeAt(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: S.scale(context, 12), vertical: S.scale(context, 6)),
          decoration: BoxDecoration(
            color: widget.t.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word.text,
                style: GoogleFonts.nunito(
                  fontSize: S.font(context, 13),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordChips() {
    return Wrap(
      spacing: S.scale(context, 8),
      runSpacing: S.scale(context, 8),
      children: _options.map((opt) {
        final used = _isOptionUsed(opt);
        return Semantics(
          button: true,
          label: used ? 'Sudah dipilih' : 'Pilih ${opt.text}',
          child: Bounceable(
            onTap: used ? null : () => _addToken(opt),
            child: AnimatedOpacity(
              opacity: used ? 0.2 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: S.scale(context, 14), vertical: S.scale(context, 7)),
                decoration: BoxDecoration(
                  color: widget.t.bgSurface2,
                  border: Border.all(
                    color: widget.t.border.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  opt.text,
                  style: GoogleFonts.nunito(
                  fontSize: S.font(context, 13),
                  fontWeight: FontWeight.w600,
                  color: used ? widget.t.mutedText : widget.t.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------- Code Mode ----------

  Widget _buildCodeAnswerArea() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditorTopBar(),
          Padding(
            padding: EdgeInsets.all(S.scale(context, 12)),
            child: _placed.isEmpty
                ? _buildCodePlaceholder()
                : _lineMode ? _buildCodeLines() : _buildCodeTokenLine(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorTopBar() {
    return Container(
                padding: EdgeInsets.symmetric(horizontal: S.scale(context, 11), vertical: S.scale(context, 7)),
      color: const Color(0xFF161B22),
      child: Row(
        children: [
          _dot(const Color(0xFFFF5F56)),
          const SizedBox(width: 5),
          _dot(const Color(0xFFFFBD2E)),
          const SizedBox(width: 5),
          _dot(const Color(0xFF27C93F)),
          const SizedBox(width: 8),
          Text(
            'script.js',
            style: GoogleFonts.firaCode(
            fontSize: S.font(context, 10),
            color: const Color(0xFF8B949E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildCodePlaceholder() {
    return Text(
      '// ketuk token di bawah...',
      style: GoogleFonts.firaCode(
      fontSize: S.font(context, 11),
      color: const Color(0xFF3D444D),
      fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildCodeLines() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _placed.length; i++)
          _buildCodeLine(_placed[i], i),
      ],
    );
  }

  Widget _buildCodeLine(QuizOption option, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: S.scale(context, 6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: S.scale(context, 24),
            child: Text(
              '${index + 1}',
              style: GoogleFonts.firaCode(
                fontSize: S.font(context, 11),
                color: const Color(0xFF3D444D),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Semantics(
                button: true,
                label: 'Hapus ${option.text}',
                child: Bounceable(
                  onTap: () => _removeAt(index),
                  child: Text(
                    option.text,
                    style: GoogleFonts.firaCode(
                      fontSize: S.font(context, 12),
                      color: const Color(0xFFE6EDF3),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeTokenLine() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: S.scale(context, 4), right: S.scale(context, 8)),
            child: Text(
              '1',
              style: GoogleFonts.firaCode(
                fontSize: S.font(context, 11),
                color: const Color(0xFF3D444D),
              ),
            ),
          ),
          ..._placed.asMap().entries.map((entry) =>
            _buildTokenChip(entry.value, entry.key),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenChip(QuizOption token, int index) {
    return Semantics(
      button: true,
      label: 'Hapus ${token.text}',
      child: Bounceable(
        onTap: () => _removeAt(index),
        child: Container(
          height: S.scale(context, 26),
          margin: EdgeInsets.only(right: S.scale(context, 2)),
          padding: EdgeInsets.symmetric(horizontal: S.scale(context, 6)),
          decoration: BoxDecoration(
            color: const Color(0xFF21262D),
            border: Border.all(color: const Color(0xFF30363D)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              token.text,
              style: GoogleFonts.firaCode(
                fontSize: S.font(context, 12),
                color: _getSyntaxColor(token.text),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeChips() {
    return Wrap(
      spacing: S.scale(context, 7),
      runSpacing: S.scale(context, 7),
      children: _options.map((opt) {
        final used = _isOptionUsed(opt);
        return Semantics(
          button: true,
          label: used ? 'Sudah dipakai' : 'Pilih ${opt.text}',
          child: Bounceable(
            onTap: used ? null : () => _addToken(opt),
            child: AnimatedOpacity(
              opacity: used ? 0.25 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
      padding: EdgeInsets.symmetric(horizontal: S.scale(context, 11), vertical: S.scale(context, 7)),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  border: Border.all(color: const Color(0xFF30363D)),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  opt.text,
                  style: GoogleFonts.firaCode(
                    fontSize: S.font(context, 12),
                    color: used ? const Color(0xFF8B949E) : _getSyntaxColor(opt.text),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CodeBlockItem {
  final String id;
  final String text;
  const _CodeBlockItem({required this.id, required this.text});
}

class DragBlocksWidget extends StatefulWidget {
  final List<String> blocks;
  final List<QuizOption> options;
  final BloomTheme t;
  final Function(List<String> orderedIds) onAnswer;

  const DragBlocksWidget({
    super.key,
    required this.blocks,
    required this.options,
    required this.t,
    required this.onAnswer,
  });

  @override
  State<DragBlocksWidget> createState() => _DragBlocksWidgetState();
}

class _DragBlocksWidgetState extends State<DragBlocksWidget> {
  late List<_CodeBlockItem> _orderedBlocks;

  @override
  void initState() {
    super.initState();
    _initBlocks();
  }

  void _initBlocks() {
    if (widget.blocks.isNotEmpty) {
      _orderedBlocks = widget.blocks.asMap().entries
          .map((e) => _CodeBlockItem(id: 'block_${e.key}', text: e.value))
          .toList()
          ..shuffle();
    } else {
      _orderedBlocks = widget.options
          .map((o) => _CodeBlockItem(id: o.id, text: o.text))
          .toList()
          ..shuffle();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAnswer(_orderedBlocks.map((b) => b.id).toList());
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: S.scale(context, 8), vertical: S.scale(context, 4)),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'JAVASCRIPT',
              style: GoogleFonts.firaCode(
                color: const Color(0xFF4ECDC4),
                fontSize: S.font(context, 10),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ReorderableListView.builder(
        buildDefaultDragHandles: false,
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
            margin: EdgeInsets.only(bottom: S.scale(context, 8)),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D23),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: i,
                  child: Container(
                    width: S.scale(context, 56),
                    height: S.scale(context, 50),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: Colors.white30,
                      size: S.scale(context, 28),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(S.scale(context, 4), S.scale(context, 12), S.scale(context, 12), S.scale(context, 12)),
                    child: Text(
                      block.text,
                      style: GoogleFonts.firaCode(
                        color: const Color(0xFF4ECDC4),
                      fontSize: S.font(context, 12),
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
