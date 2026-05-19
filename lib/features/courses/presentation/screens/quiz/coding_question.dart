import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';

class CodingQuestion extends StatefulWidget {
  final BloomTheme t;
  final String? codeSnippet;
  final String? codeTemplate;
  final Function(String) onChanged;

  const CodingQuestion({
    super.key,
    required this.t,
    this.codeSnippet,
    this.codeTemplate,
    required this.onChanged,
  });

  @override
  State<CodingQuestion> createState() => _CodingQuestionState();
}

class _CodingQuestionState extends State<CodingQuestion> {
  late final TextEditingController _controller;
  bool _showTemplate = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.codeTemplate ?? '',
    );
    _controller.addListener(() => widget.onChanged(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final hasSnippet = widget.codeSnippet != null && widget.codeSnippet!.isNotEmpty;
    final hasTemplate = widget.codeTemplate != null && widget.codeTemplate!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasSnippet)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.info.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: t.info, size: 16),
                    const SizedBox(width: 6),
                    Text('Petunjuk',
                      style: GoogleFonts.nunito(
                        color: t.info,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      )),
                  ],
                ),
                const SizedBox(height: 8),
                Text(widget.codeSnippet!,
                  style: GoogleFonts.jetBrainsMono(
                    color: t.textPrimary,
                    fontSize: 13,
                    height: 1.5,
                  )),
              ],
            ),
          ),
        if (hasSnippet && hasTemplate)
          const SizedBox(height: 14),
        if (hasTemplate)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.code_rounded, color: t.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text('Kode Template',
                    style: GoogleFonts.nunito(
                      color: t.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    )),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _showTemplate = !_showTemplate),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: t.bgSurface2,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showTemplate ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            size: 12,
                            color: t.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showTemplate ? 'Sembunyikan' : 'Tampilkan',
                            style: GoogleFonts.nunito(
                              color: t.textHint,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_showTemplate)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: t.bgPrimary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.border),
                  ),
                  child: Text(widget.codeTemplate!,
                    style: GoogleFonts.jetBrainsMono(
                      color: t.textSecondary,
                      fontSize: 13,
                      height: 1.6,
                    )),
                ),
            ],
          ),
        if (hasTemplate)
          const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: t.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.border),
          ),
          child: TextField(
            controller: _controller,
            maxLines: 10,
            minLines: 5,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              color: t.textPrimary,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: 'Tulis kode jawaban di sini...',
              hintStyle: GoogleFonts.jetBrainsMono(
                color: t.textHint,
                fontSize: 13,
                height: 1.6,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
