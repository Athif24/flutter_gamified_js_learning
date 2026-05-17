import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';

class EssayQuestion extends StatefulWidget {
  final BloomTheme t;
  final Function(String) onChanged;

  const EssayQuestion({super.key, required this.t, required this.onChanged});

  @override
  State<EssayQuestion> createState() => _EssayQuestionState();
}

class _EssayQuestionState extends State<EssayQuestion> {
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
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: widget.t.info.withValues(alpha: 0.1),
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
