import 'package:flutter/material.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../data/models/course_model.dart';
import 'complete_word_widget.dart';
import 'reorder_words_widget.dart';
import 'drag_blocks_widget.dart';

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