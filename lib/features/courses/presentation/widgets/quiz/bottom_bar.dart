import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../shared/widgets/game_3d_button.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../providers/course_provider.dart';

class BottomBar extends ConsumerWidget {
  final QuizState quiz;
  final String quizId;
  final BloomTheme t;

  const BottomBar({
    super.key,
    required this.quiz,
    required this.quizId,
    required this.t,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ans = quiz.answers[quiz.current?.id];
    final hasAns = quiz.current != null &&
        ans != null &&
        (ans is List ? ans.isNotEmpty : ans is String ? ans.isNotEmpty : true);
    final isLast = quiz.isLast;
    final popupShowing = quiz.lastAnswerResult != null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        S.scale(context, 20),
        S.scale(context, 12),
        S.scale(context, 20),
        S.scale(context, 28),
      ),
      decoration: BoxDecoration(
        color: t.bgSurface,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Semantics(
              button: true,
              label: 'Lewati',
              child: Game3DButton(
                label: 'LEWATI',
                color: t.bgSurface2,
                shadowColor: t.textPrimary,
                textColor: t.mutedText,
                horizontalPadding: S.scale(context, 20),
                verticalPadding: S.scale(context, 12),
                onTap:
                    popupShowing || quiz.isSubmitting || quiz.isSubmittingAnswer
                    ? null
                    : () async {
                        if (isLast) {
                          if (hasAns) {
                            await ref
                                .read(quizProvider.notifier)
                                .submitCurrentAnswer();
                          }
                          ref.read(quizProvider.notifier).submit(quizId);
                        } else {
                          ref.read(quizProvider.notifier).next();
                        }
                      },
              ),
            ),
            SizedBox(width: S.scale(context, 12)),
            const Spacer(),
            Semantics(
              button: true,
              label: isLast ? 'Selesai' : 'Periksa',
              child: Game3DButton(
                label: isLast ? 'SELESAI' : 'PERIKSA',
                color: hasAns ? t.primary : t.bgSurface3,
                shadowColor: t.textPrimary,
                textColor: hasAns ? t.primaryContent : t.mutedText,
                isLoading: quiz.isSubmitting || quiz.isSubmittingAnswer,
                onTap:
                    (hasAns &&
                        !quiz.isSubmitting &&
                        !quiz.isSubmittingAnswer &&
                        !popupShowing)
                    ? () async {
                        await ref
                            .read(quizProvider.notifier)
                            .submitCurrentAnswer();
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}