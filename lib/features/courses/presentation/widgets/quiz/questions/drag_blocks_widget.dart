import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/course_model.dart';

class CodeBlockItem {
  final String id;
  final String text;
  const CodeBlockItem({required this.id, required this.text});
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
  State<DragBlocksWidget> createState() => DragBlocksWidgetState();
}

class DragBlocksWidgetState extends State<DragBlocksWidget> {
  late List<CodeBlockItem> _orderedBlocks;

  @override
  void initState() {
    super.initState();
    _initBlocks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAnswer([]);
    });
  }

  void _initBlocks() {
    if (widget.blocks.isNotEmpty) {
      _orderedBlocks =
          widget.blocks
              .asMap()
              .entries
              .map((e) => CodeBlockItem(id: 'block_${e.key}', text: e.value))
              .toList()
            ..shuffle();
    } else {
      _orderedBlocks =
          widget.options
              .map((o) => CodeBlockItem(id: o.id, text: o.text))
              .toList()
            ..shuffle();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: S.scale(context, 8),
              vertical: S.scale(context, 4),
            ),
            decoration: BoxDecoration(
              color: widget.t.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'JAVASCRIPT',
              style: GoogleFonts.firaCode(
                color: widget.t.info,
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
              color: widget.t.bgSurface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.t.info.withValues(alpha: 0.3)),
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
                      color: widget.t.mutedText.withValues(alpha: 0.3),
                      size: S.scale(context, 28),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      S.scale(context, 4),
                      S.scale(context, 12),
                      S.scale(context, 12),
                      S.scale(context, 12),
                    ),
                    child: Text(
                      block.text,
                      style: GoogleFonts.firaCode(
                        color: widget.t.info,
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