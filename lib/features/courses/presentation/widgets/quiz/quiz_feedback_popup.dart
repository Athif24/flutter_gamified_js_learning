import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../shared/widgets/game_3d_button.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../data/models/course_model.dart';

class QuizFeedbackPopup extends StatelessWidget {
  final SubmitAnswerResponse result;
  final BloomTheme t;
  final bool isLast;
  final QuestionModel? currentQuestion;
  final int currentStreak;
  final int? livesRemaining;
  final int? previousLivesRemaining;
  final VoidCallback onLanjut;

  const QuizFeedbackPopup({
    super.key,
    required this.result,
    required this.t,
    required this.isLast,
    this.currentQuestion,
    this.currentStreak = 0,
    this.livesRemaining,
    this.previousLivesRemaining,
    required this.onLanjut,
  });

  Color get _correctBg => t.success.withValues(alpha: 0.12);
  Color get _correctBtn => t.success;
  Color get _incorrectBg => t.error.withValues(alpha: 0.12);
  Color get _incorrectBtn => t.error;

  String _getCorrectMessage(int streak) {
    if (streak >= 10) {
      final messages = [
        'Luar biasa! Kamu tidak terhentikan!',
        'Rekor beruntun sempurna!',
        'Luar biasa!',
        'Penampilan yang hebat!',
      ];
      return messages[streak % messages.length];
    }
    if (streak >= 5) {
      final messages = [
        '$streak beruntun!',
        'Pertahankan!',
        'Momentum yang bagus!',
        'Hebat!',
      ];
      return messages[streak % messages.length];
    }
    if (streak >= 3) {
      final messages = [
        '$streak beruntun!',
        'Mantap!',
        'Bagus sekali!',
        'Sempurna!',
      ];
      return messages[streak % messages.length];
    }
    return 'Jawaban Tepat!';
  }

  String _getWrongMessage() {
    final messages = [
      'Hampir saja!',
      'Coba lagi!',
      'Terus belajar!',
      'Ayo coba lagi!',
    ];
    return messages[DateTime.now().millisecondsSinceEpoch % messages.length];
  }

  String _formatCorrectAnswer(dynamic correctAnswer) {
    if (correctAnswer == null) return '';
    if (correctAnswer is String) return correctAnswer;
    if (correctAnswer is List) return correctAnswer.join(', ');
    if (correctAnswer is Map) {
      return correctAnswer['text']?.toString() ?? correctAnswer.toString();
    }
    return correctAnswer.toString();
  }

  String _getWrongAnswerSubtext() {
    if (result.correctAnswer != null) {
      final formatted = _formatCorrectAnswer(result.correctAnswer);
      if (formatted.isNotEmpty) {
        return 'Kunci jawaban: $formatted';
      }
    }
    if (result.feedback != null && result.feedback!.isNotEmpty) {
      return result.feedback!;
    }
    return 'Jawaban salah, coba lagi!';
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = result.isCorrect;
    final bgColor = isCorrect ? _correctBg : _incorrectBg;
    final btnColor = isCorrect ? _correctBtn : _incorrectBtn;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        S.scale(context, 20),
        S.scale(context, 16),
        S.scale(context, 20),
        S.scale(context, 28),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            width: S.scale(context, 1),
            color: t.border.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildAnimatedIcon(context, isCorrect),
                      SizedBox(width: S.scale(context, 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isCorrect
                                  ? _getCorrectMessage(currentStreak)
                                  : _getWrongMessage(),
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800,
                                fontSize: S.font(context, 16),
                                color: t.textPrimary,
                              ),
                            ),
                            SizedBox(height: S.scale(context, 2)),
                            if (isCorrect)
                              Text(
                                'Kamu menjawab dengan benar',
                                style: GoogleFonts.nunito(
                                  fontSize: S.font(context, 12),
                                  color: t.textSecondary,
                                ),
                              )
                            else
                              Text(
                                _getWrongAnswerSubtext(),
                                style: GoogleFonts.nunito(
                                  fontSize: S.font(context, 12),
                                  color: t.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: S.scale(context, 12)),
                Semantics(
                  button: true,
                  label: isLast ? 'Selesai' : 'Lanjut',
                  child: Game3DButton(
                    label: isLast ? 'SELESAI' : 'LANJUT',
                    color: btnColor,
                    shadowColor: t.textPrimary,
                    textColor: isCorrect ? t.successContent : t.errorContent,
                    horizontalPadding: S.scale(context, 28),
                    verticalPadding: S.scale(context, 13),
                    onTap: onLanjut,
                  ),
                ),
              ],
            ),

            if (currentStreak >= 3) ...[
              SizedBox(height: S.scale(context, 12)),
              _buildStreakBadge(context),
            ],

            if (!isCorrect && livesRemaining != null) ...[
              SizedBox(height: S.scale(context, 12)),
              _buildLivesIndicator(context),
            ],
          ],
        ),
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildAnimatedIcon(BuildContext context, bool isCorrect) {
    final color = isCorrect ? t.success : t.error;
    final icon = Container(
      width: S.scale(context, 40),
      height: S.scale(context, 40),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCorrect ? Icons.check : Icons.close,
        color: color,
        size: S.scale(context, 24),
      ),
    );

    return isCorrect
        ? icon.animate().scale(
            begin: const Offset(0.5, 0.5),
            duration: 200.ms,
            curve: Curves.bounceOut,
          )
        : icon.animate().shakeX(duration: 300.ms);
  }

  Widget _buildStreakBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 12),
        vertical: S.scale(context, 6),
      ),
      decoration: BoxDecoration(
        color: t.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(S.scale(context, 50)),
        border: Border.all(
          width: S.scale(context, 1),
          color: t.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔥', style: TextStyle(fontSize: S.scale(context, 16))),
          SizedBox(width: S.scale(context, 6)),
          Text(
            '$currentStreak beruntun!',
            style: GoogleFonts.nunito(
              color: t.warning,
              fontSize: S.font(context, 12),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivesIndicator(BuildContext context) {
    final lives = result.livesRemaining ?? 0;
    final isCritical = lives > 0 && lives <= 2;
    final lifeLost =
        previousLivesRemaining != null && lives < previousLivesRemaining!;

    final hearts = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: S.scale(context, 4)),
          Text(
            'Nyawa tersisa: ',
            style: GoogleFonts.nunito(
              color: t.textSecondary,
              fontSize: S.font(context, 12),
              fontWeight: FontWeight.w600,
            ),
          ),
          ...List.generate(lives, (i) {
            final heart = Icon(
              Icons.favorite_rounded,
              color: t.error,
              size: S.scale(context, 16),
            );
            Widget animated;
            if (lifeLost) {
              animated = heart
                  .animate()
                  .scaleXY(
                    begin: 1.4,
                    duration: 200.ms,
                    curve: Curves.bounceOut,
                  )
                  .then()
                  .shakeX(duration: 300.ms);
            } else if (isCritical) {
              animated = heart
                  .animate()
                  .shakeX(duration: 400.ms)
                  .then()
                  .shakeX(duration: 400.ms)
                  .then()
                  .shakeX();
            } else {
              animated = heart;
            }
            return Padding(
              padding: EdgeInsets.only(right: S.scale(context, 2)),
              child: animated,
            );
          }),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 10),
        vertical: S.scale(context, 6),
      ),
      decoration: BoxDecoration(
        color: isCritical
            ? t.error.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(S.scale(context, 8)),
      ),
      child: hearts,
    );
  }
}