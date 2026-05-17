import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../shared/widgets/game_3d_button.dart';
import '../../providers/course_provider.dart';

class BottomBar extends ConsumerWidget {
  final QuizState quiz;
  final String quizId;
  final BloomTheme t;

  const BottomBar({super.key, required this.quiz, required this.quizId, required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAns = quiz.current != null && quiz.answers.containsKey(quiz.current!.id);
    final isLast = quiz.isLast;
    final popupShowing = quiz.lastAnswerResult != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: t.bgSurface,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Game3DButton(
              label: 'LEWATI',
              color: t.bgSurface2,
              shadowColor: t.border,
              textColor: t.textSecondary,
              horizontalPadding: 20,
              verticalPadding: 12,
              onTap: popupShowing || quiz.isSubmitting || quiz.isSubmittingAnswer
                  ? null
                  : () async {
                      if (isLast) {
                        if (hasAns) {
                          await ref.read(quizProvider.notifier).submitCurrentAnswer();
                        }
                        ref.read(quizProvider.notifier).submit(quizId);
                      } else {
                        ref.read(quizProvider.notifier).next();
                      }
                    },
            ),
            const SizedBox(width: 12),
            const Spacer(),
            Game3DButton(
              label: isLast ? 'SELESAI' : 'PERIKSA',
              color: hasAns ? t.accent : const Color(0xFFE5E5E5),
              shadowColor: hasAns ? darken(t.accent, 0.2) : const Color(0xFFC0C0C0),
              textColor: hasAns ? t.accentText : const Color(0xFFB0B0B0),
              isLoading: quiz.isSubmitting || quiz.isSubmittingAnswer,
              onTap: (hasAns && !quiz.isSubmitting && !quiz.isSubmittingAnswer && !popupShowing)
                  ? () async {
                      await ref.read(quizProvider.notifier).submitCurrentAnswer();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
