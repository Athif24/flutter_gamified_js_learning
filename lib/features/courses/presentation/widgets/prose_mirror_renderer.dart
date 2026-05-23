import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../core/constants/app_strings.dart';
import 'iframe_widget.dart';
import 'video_node_widget.dart';
import 'youtube_player_widget.dart';

class ProseMirrorRenderer extends StatelessWidget {
  final String content;
  final BloomTheme t;
  const ProseMirrorRenderer({super.key, required this.content, required this.t});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> doc;
    try {
      doc = jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      if (!kReleaseMode) debugPrint('[ProseMirrorRenderer] jsonDecode failed: $e');
      return Text(content, style: GoogleFonts.nunito(
          color: t.textPrimary, fontSize: 14, height: 1.7));
    }
    final nodes = doc['content'] as List? ?? [];
    final children = <Widget>[];
    for (final n in nodes) {
      try {
        if (n is Map<String, dynamic>) {
          children.add(_buildNode(n));
        }
      } catch (e) {
        if (!kReleaseMode) debugPrint('[ProseMirrorRenderer] _buildNode error: $e');
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildNode(Map<String, dynamic> node) {
    final type = node['type'] as String? ?? '';
    final content = node['content'] as List? ?? [];
    final attrs = node['attrs'] as Map<String, dynamic>? ?? {};

    switch (type) {
      // ── Text ─────────────────────────────────────────────────────────
      case 'heading':
        final level = (attrs['level'] ?? 1) as int;
        final size = switch (level) { 1 => 20.0, 2 => 17.0, _ => 15.0 };
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

      // ── Lists ────────────────────────────────────────────────────────
      case 'bulletList':
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content.map<Widget>((item) {
              final ic = (item as Map)['content'] as List? ?? [];
              if (ic.isEmpty) return const SizedBox.shrink();
              final itemChildren = <Widget>[];
              for (var i = 0; i < ic.length; i++) {
                final child = ic[i] as Map<String, dynamic>;
                if (i == 0) {
                  itemChildren.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          margin: const EdgeInsets.only(top: 7, right: 10),
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                              color: t.primary, shape: BoxShape.circle),
                        ),
                        Expanded(
                          child: child['type'] == 'paragraph'
                              ? _buildRichText(child['content'] as List? ?? [])
                              : _buildNode(child),
                        ),
                      ]),
                    ),
                  );
                } else {
                  itemChildren.add(
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: _buildNode(child),
                    ),
                  );
                }
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: itemChildren);
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
              if (ic.isEmpty) return const SizedBox.shrink();
              final itemChildren = <Widget>[];
              for (var i = 0; i < ic.length; i++) {
                final child = ic[i] as Map<String, dynamic>;
                if (i == 0) {
                  itemChildren.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2, right: 10),
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                              color: t.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle),
                          child: Center(child: Text('${e.key + 1}',
                              style: GoogleFonts.nunito(
                                  color: t.primary, fontSize: 11,
                                  fontWeight: FontWeight.w800))),
                        ),
                        Expanded(
                          child: child['type'] == 'paragraph'
                              ? _buildRichText(child['content'] as List? ?? [])
                              : _buildNode(child),
                        ),
                      ]),
                    ),
                  );
                } else {
                  itemChildren.add(
                    Padding(
                      padding: const EdgeInsets.only(left: 26, bottom: 4),
                      child: _buildNode(child),
                    ),
                  );
                }
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: itemChildren);
            }).toList(),
          ),
        );

      case 'taskList':
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content.map<Widget>((item) {
              final iAttrs = (item as Map)['attrs'] as Map? ?? {};
              final checked = iAttrs['checked'] as bool? ?? false;
              final ic = item['content'] as List? ?? [];
              if (ic.isEmpty) return const SizedBox.shrink();
              final itemChildren = <Widget>[];
              for (var i = 0; i < ic.length; i++) {
                final child = ic[i] as Map<String, dynamic>;
                if (i == 0) {
                  itemChildren.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2, right: 10),
                          child: Icon(
                            checked
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            color: checked ? t.primary : t.mutedText,
                            size: 22,
                          ),
                        ),
                        Expanded(
                          child: child['type'] == 'paragraph'
                              ? _buildRichText(child['content'] as List? ?? [])
                              : _buildNode(child),
                        ),
                      ]),
                    ),
                  );
                } else {
                  itemChildren.add(
                    Padding(
                      padding: const EdgeInsets.only(left: 32, bottom: 4),
                      child: _buildNode(child),
                    ),
                  );
                }
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: itemChildren);
            }).toList(),
          ),
        );

      // ── Code ─────────────────────────────────────────────────────────
      case 'codeBlock':
        final code = attrs['code'] as String? ?? _extractText(content);
        final lang = attrs['language'] as String? ?? 'js';
        return CodeBlock(code: code.trim(), language: lang, t: t);

      // ── Horizontal Rule ──────────────────────────────────────────────
      case 'horizontalRule':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Divider(color: t.border, thickness: 1),
        );

      // ── Blockquote ───────────────────────────────────────────────────
      case 'blockquote':
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: t.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: t.primary, width: 3)),
          ),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.nunito(
                  color: t.mutedText, fontSize: 14,
                  fontStyle: FontStyle.italic, height: 1.6),
              children: content.isNotEmpty
                  ? _buildSpans((content[0] as Map)['content'] as List? ?? [])
                  : [],
            ),
          ),
        );

      // ── Image ────────────────────────────────────────────────────────
      case 'image':
        final src = attrs['src'] as String? ?? '';
        final alt = attrs['alt'] as String? ?? '';
        if (src.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: src,
                fit: BoxFit.contain,
                width: double.infinity,
                placeholder: (_, __) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: t.bgSurface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: t.primary))),
                errorWidget: (_, __, ___) => Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image_rounded,
                          color: t.mutedText, size: 32),
                      const SizedBox(height: 6),
                      Text(AppStrings.errLoadImage,
                          style: GoogleFonts.nunito(
                              color: t.mutedText, fontSize: 12)),
                    ],
                  )),
                ),
              ),
            ),
            if (alt.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(alt, style: GoogleFonts.nunito(
                    color: t.mutedText, fontSize: 12,
                    fontStyle: FontStyle.italic)),
              ),
          ]),
        );

      // ── YouTube / Iframe ─────────────────────────────────────────────
      case 'iframe':
        final src = attrs['src'] as String? ?? '';
        if (src.isEmpty) return const SizedBox.shrink();
        final isYoutube = src.contains('youtube.com') || src.contains('youtu.be');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isYoutube
                ? YoutubePlayerWidget(src: src, t: t,
                    title: attrs['title'] as String?)
                : SizedBox(
                    height: (attrs['height'] as num?)?.toDouble() ?? 200,
                    child: IframeWidget(src: src),
                  ),
          ),
        );

      // ── Video (Cloudinary / MP4 atau YouTube) ────────────────────────
      case 'video':
        final src = attrs['src'] as String? ?? '';
        if (src.isEmpty) return const SizedBox.shrink();
        final isYoutube = src.contains('youtube.com') || src.contains('youtu.be');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isYoutube
                ? YoutubePlayerWidget(src: src, t: t,
                    title: attrs['title'] as String?)
                : VideoNodeWidget(src: src, t: t),
          ),
        );

      // ── Table ────────────────────────────────────────────────────────
      case 'table':
        final rows = content.map<TableRow>((row) {
          final cells = (row as Map)['content'] as List? ?? [];
          return TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: t.border, width: 1)),
            ),
            children: cells.map((cell) {
              final cellContent = (cell as Map)['content'] as List? ?? [];
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cellContent.map((child) {
                    if (child is Map<String, dynamic> && child['type'] == 'paragraph') {
                      return _buildRichText(child['content'] as List? ?? []);
                    }
                    if (child is Map<String, dynamic>) {
                      return _buildNode(child);
                    }
                    return const SizedBox.shrink();
                  }).toList(),
                ),
              );
            }).toList(),
          );
        }).toList();

        if (rows.isEmpty) return const SizedBox.shrink();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: t.border, width: 1),
                verticalInside: BorderSide(color: t.border, width: 1),
              ),
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: rows,
            ),
          ),
        );

      // ── Callout / Alert ──────────────────────────────────────────────
      case 'callout':
        final calloutType = attrs['type'] as String? ?? 'info';
        final Color calloutColor = switch (calloutType) {
          'warning' => const Color(0xFFFFA726),
          'error'   => const Color(0xFFEF5350),
          'success' => const Color(0xFF66BB6A),
          _         => t.primary,
        };
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: calloutColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border(left: BorderSide(color: calloutColor, width: 4)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Icon(
              switch (calloutType) {
                'warning' => Icons.warning_amber_rounded,
                'error'   => Icons.error_rounded,
                'success' => Icons.check_circle_rounded,
                _         => Icons.info_rounded,
              },
              color: calloutColor, size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: _buildRichText(content)),
          ]),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  List<InlineSpan> _buildSpans(List content) {
    final spans = <InlineSpan>[];
    for (final inline in content) {
      final node = inline as Map<String, dynamic>;
      final itype = node['type'] as String? ?? '';
      if (itype == 'hardBreak') {
        spans.add(const TextSpan(text: '\n'));
        continue;
      }

      final text = node['text'] as String? ?? '';
      final marks = node['marks'] as List? ?? [];
      bool bold = false, italic = false, isCode = false, strike = false, underline = false;
      String? linkHref;

      for (final m in marks) {
        final mt = (m as Map)['type'] as String? ?? '';
        if (mt == 'bold') bold = true;
        if (mt == 'italic') italic = true;
        if (mt == 'code') isCode = true;
        if (mt == 'strike') strike = true;
        if (mt == 'underline') underline = true;
        if (mt == 'link') {
          linkHref = m['attrs']?['href'] as String?;
        }
      }

      if (isCode) {
        spans.add(WidgetSpan(
          baseline: TextBaseline.alphabetic,
          alignment: PlaceholderAlignment.baseline,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: t.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: t.primary.withValues(alpha: 0.2)),
            ),
            child: Text(text, style: GoogleFonts.firaCode(
                color: t.primary, fontSize: 12)),
          ),
        ));
      } else {
        final style = GoogleFonts.nunito(
          color: linkHref != null ? Colors.blue : t.textPrimary,
          fontSize: 14,
          height: 1.7,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          decoration: strike
              ? TextDecoration.lineThrough
              : underline
                  ? TextDecoration.underline
                  : linkHref != null
                      ? TextDecoration.underline
                      : null,
        );

        if (linkHref != null) {
          spans.add(WidgetSpan(
            baseline: TextBaseline.alphabetic,
            alignment: PlaceholderAlignment.baseline,
            child: Semantics(
              link: true,
              label: 'Buka tautan $linkHref',
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse(linkHref!)),
                child: Text(text, style: style),
              ),
            ),
          ));
        } else {
          spans.add(TextSpan(text: text, style: style));
        }
      }
    }
    return spans;
  }

  Widget _buildRichText(List content) =>
      RichText(text: TextSpan(children: _buildSpans(content)));

  String _extractText(List nodes) {
    final buf = StringBuffer();
    for (final n in nodes) {
      if (n is! Map<String, dynamic>) continue;
      if (n['type'] == 'text') buf.write(n['text'] ?? '');
      if (n['type'] == 'hardBreak') buf.write('\n');
      final sub = n['content'] as List?;
      if (sub != null) buf.write(_extractText(sub));
    }
    return buf.toString();
  }

  static List<TextSpan> _highlightSyntax(String code, {double fontSize = 13}) {
    const keywords = {
      'const', 'let', 'var', 'function', 'return', 'if', 'else',
      'for', 'while', 'do', 'switch', 'case', 'break', 'continue',
      'class', 'extends', 'import', 'export', 'default', 'from',
      'new', 'this', 'super', 'delete', 'typeof', 'instanceof',
      'void', 'try', 'catch', 'finally', 'throw', 'async', 'await',
      'true', 'false', 'null', 'undefined', 'NaN', 'in', 'of',
      'console', 'document', 'window', 'Array', 'Object', 'String',
      'Number', 'Boolean', 'Promise', 'Map', 'Set',
    };

    final spans = <TextSpan>[];
    final pattern = RegExp(
      r"""("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|`(?:[^`\\]|\\.)*`|"""
      r"""//[^\n]*|/\*[\s\S]*?\*/|"""
      r"""\b\d+\.?\d*\b|"""
      r"""\b[a-zA-Z_$][\w$]*\b|"""
      r"""[+\-*/%=!<>&|^~?:;,.(){}\[\]])""",
    );

    int lastEnd = 0;
    for (final match in pattern.allMatches(code)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: code.substring(lastEnd, match.start)));
      }

      final raw = match.group(1) ?? '';
      final trimmed = raw.trim();

      Color color;
      if (raw.startsWith('"') || raw.startsWith("'") || raw.startsWith('`')) {
        color = const Color(0xFFA5D6FF);
      } else if (raw.startsWith('//') || raw.startsWith('/*')) {
        color = const Color(0xFF8B949E);
      } else if (keywords.contains(trimmed)) {
        color = const Color(0xFFFF7B72);
      } else if (RegExp(r'^\d+\.?\d*$').hasMatch(trimmed)) {
        color = const Color(0xFF79C0FF);
      } else if (RegExp(r'^[(){}\[\];,.]$').hasMatch(trimmed)) {
        color = const Color(0xFFE6EDF3);
      } else if (RegExp(r'^[+\-*/%=!<>&|^~?:]+$').hasMatch(trimmed)) {
        color = const Color(0xFF79C0FF);
      } else {
        color = const Color(0xFF4ECDC4);
      }

      spans.add(TextSpan(
        text: raw,
        style: TextStyle(color: color, fontSize: fontSize),
      ));

      lastEnd = match.end;
    }

    if (lastEnd < code.length) {
      spans.add(TextSpan(text: code.substring(lastEnd)));
    }

    return spans;
  }
}

// ── Code Block ────────────────────────────────────────────────────────────────

class CodeBlock extends StatelessWidget {
  final String code, language;
  final BloomTheme t;
  const CodeBlock({super.key, required this.code, required this.language, required this.t});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1D23),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: t.primary.withValues(alpha: 0.2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
        child: Row(children: [
          _Dot(t.error), const SizedBox(width: 5),
          _Dot(t.primary), const SizedBox(width: 5),
          _Dot(t.success),
          const Spacer(),
          Text(language.toUpperCase(), style: GoogleFonts.firaCode(
              color: Colors.white30, fontSize: 10)),
        ]),
      ),
      const Divider(color: Colors.white12, height: 1),
      Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText.rich(
            TextSpan(
              style: GoogleFonts.firaCode(fontSize: 13, height: 1.6),
              children: ProseMirrorRenderer._highlightSyntax(code),
            ),
          ),
        ),
      ),
    ]),
  );
}

// ── Dot Helper ────────────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);
  @override
  Widget build(BuildContext context) => Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
