import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/course_model.dart';

bool detectIsCodeMode(List<QuizOption> options) {
  int score = 0;
  final symbolPattern = RegExp(r'[(){}\[\];,]');
  final operatorPattern = RegExp(
    r'^(==|!=|<=|>=|&&|\|\||=>|<<|>>|\+\+|--|[+\-*/%=!<>])$',
  );
  const codeKeywords = {
    'const',
    'let',
    'var',
    'function',
    'return',
    'if',
    'else',
    'for',
    'while',
    'class',
    'import',
    'export',
    'new',
    'this',
    'cout',
    'cin',
    'int',
    'void',
    'include',
    'using',
    'namespace',
    'print',
    'println',
    'def',
    'elif',
    'true',
    'false',
    'null',
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

bool isLineMode(List<QuizOption> options) {
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
  State<ReorderWordsWidget> createState() => ReorderWordsWidgetState();
}

class ReorderWordsWidgetState extends State<ReorderWordsWidget> {
  final List<QuizOption> _placed = [];
  late final List<QuizOption> _options;
  late final bool _isCodeMode;
  late final bool _lineMode;

  @override
  void initState() {
    super.initState();
    _options = List.from(widget.options)..shuffle();
    _isCodeMode = detectIsCodeMode(_options);
    _lineMode = _isCodeMode && isLineMode(_options);
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
    if (_placed.length < _options.length) {
      widget.onAnswer([]);
      return;
    }
    widget.onAnswer(_placed.map((o) => o.id).toList());
  }

  bool _isOptionUsed(QuizOption option) {
    final countInOptions = _options.where((o) => o.id == option.id).length;
    final countInPlaced = _placed.where((o) => o.id == option.id).length;
    return countInPlaced >= countInOptions;
  }

  Color _getSyntaxColor(String token) {
    final keywords = {
      'const',
      'let',
      'var',
      'function',
      'return',
      'if',
      'else',
      'for',
      'while',
      'class',
      'cout',
      'cin',
      'int',
      'void',
      'true',
      'false',
      'null',
      'undefined',
    };
    final t = widget.t;
    final trimmed = token.trim();
    if (keywords.contains(trimmed)) return t.error;
    if (trimmed.startsWith('"') || trimmed.startsWith("'")) return t.info;
    if (RegExp(r'^[+\-*/%=!<>&|^~]+$').hasMatch(trimmed)) return t.info;
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(trimmed)) return t.info;
    if (RegExp(r'^[(){}\[\];,]$').hasMatch(trimmed)) return t.textPrimary;
    if (trimmed.contains('.')) return t.accent;
    return t.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isCodeMode) _buildCodeAnswerArea() else _buildWordAnswerArea(),
        SizedBox(height: S.scale(context, 12)),
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
        SizedBox(height: S.scale(context, 8)),
        if (_isCodeMode) _buildCodeChips() else _buildWordChips(),
      ],
    );
  }

  Widget _buildWordAnswerArea() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: S.scale(context, 60)),
      padding: EdgeInsets.all(S.scale(context, 12)),
      decoration: BoxDecoration(
        color: widget.t.bgSurface,
        borderRadius: BorderRadius.circular(S.scale(context, 12)),
        border: Border.all(
          color: widget.t.border.withValues(alpha: 0.5),
          width: S.scale(context, 1.5),
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
              spacing: S.scale(context, 7),
              runSpacing: S.scale(context, 7),
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
          padding: EdgeInsets.symmetric(
            horizontal: S.scale(context, 12),
            vertical: S.scale(context, 6),
          ),
          decoration: BoxDecoration(
            color: widget.t.primary,
            borderRadius: BorderRadius.circular(S.scale(context, 20)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word.text,
                style: GoogleFonts.nunito(
                  fontSize: S.font(context, 13),
                  fontWeight: FontWeight.w700,
                  color: widget.t.primaryContent,
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
                padding: EdgeInsets.symmetric(
                  horizontal: S.scale(context, 14),
                  vertical: S.scale(context, 7),
                ),
                decoration: BoxDecoration(
                  color: widget.t.bgSurface2,
                  border: Border.all(
                    color: widget.t.border.withValues(alpha: 0.6),
                    width: S.scale(context, 1.5),
                  ),
                  borderRadius: BorderRadius.circular(S.scale(context, 20)),
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

  Widget _buildCodeAnswerArea() {
    return Container(
      decoration: BoxDecoration(
        color: widget.t.bgSurface2,
        borderRadius: BorderRadius.circular(S.scale(context, 10)),
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
                : _lineMode
                ? _buildCodeLines()
                : _buildCodeTokenLine(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 11),
        vertical: S.scale(context, 7),
      ),
      color: widget.t.bgSurface,
      child: Row(
        children: [
          _dot(widget.t.error),
          SizedBox(width: S.scale(context, 5)),
          _dot(widget.t.warning),
          SizedBox(width: S.scale(context, 5)),
          _dot(widget.t.success),
          SizedBox(width: S.scale(context, 8)),
          Text(
            'script.js',
            style: GoogleFonts.firaCode(
              fontSize: S.font(context, 10),
              color: widget.t.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: S.scale(context, 9),
      height: S.scale(context, 9),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildCodePlaceholder() {
    return Text(
      '// ketuk token di bawah...',
      style: GoogleFonts.firaCode(
        fontSize: S.font(context, 11),
        color: widget.t.border,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildCodeLines() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _placed.length; i++) _buildCodeLine(_placed[i], i),
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
                color: widget.t.border,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(width: S.scale(context, 12)),
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
                      color: widget.t.textPrimary,
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
            padding: EdgeInsets.only(
              top: S.scale(context, 4),
              right: S.scale(context, 8),
            ),
            child: Text(
              '1',
              style: GoogleFonts.firaCode(
                fontSize: S.font(context, 11),
                color: widget.t.border,
              ),
            ),
          ),
          ..._placed.asMap().entries.map(
            (entry) => _buildTokenChip(entry.value, entry.key),
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
            color: widget.t.bgSurface2,
            border: Border.all(color: widget.t.border),
            borderRadius: BorderRadius.circular(S.scale(context, 4)),
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
                padding: EdgeInsets.symmetric(
                  horizontal: S.scale(context, 11),
                  vertical: S.scale(context, 7),
                ),
                decoration: BoxDecoration(
                  color: widget.t.bgSurface,
                  border: Border.all(color: widget.t.border),
                  borderRadius: BorderRadius.circular(S.scale(context, 7)),
                ),
                child: Text(
                  opt.text,
                  style: GoogleFonts.firaCode(
                    fontSize: S.font(context, 12),
                    color: used
                        ? widget.t.mutedText
                        : _getSyntaxColor(opt.text),
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