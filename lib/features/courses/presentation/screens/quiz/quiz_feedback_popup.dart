import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../shared/widgets/game_3d_button.dart';
import '../../../data/models/course_model.dart';

class QuizFeedbackPopup extends StatelessWidget {
  final SubmitAnswerResponse result;
  final BloomTheme t;
  final bool isLast;
  final QuestionModel? currentQuestion;
  final int currentStreak;
  final int? livesRemaining;
  final VoidCallback onLanjut;

  const QuizFeedbackPopup({
    super.key,
    required this.result,
    required this.t,
    required this.isLast,
    this.currentQuestion,
    this.currentStreak = 0,
    this.livesRemaining,
    required this.onLanjut,
  });

  static const _correctBg = Color(0xFF15803d);
  static const _correctBtn = Color(0xFF166534);
  static const _incorrectBg = Color(0xFF991b1b);
  static const _incorrectBtn = Color(0xFF7f1d1d);

  String _getCorrectMessage(int streak) {
    if (streak >= 10) {
      final messages = [
        'Phenomenal! You\'re unstoppable!',
        'Perfect streak energy!',
        'You\'re on fire!',
        'Incredible performance!',
      ];
      return messages[streak % messages.length];
    }
    if (streak >= 5) {
      final messages = [
        '$streak in a row!',
        'Keep it up!',
        'Great momentum!',
        'Amazing!',
      ];
      return messages[streak % messages.length];
    }
    if (streak >= 3) {
      final messages = [
        '$streak in a row!',
        'Nice!',
        'Excellent!',
        'Perfect!',
      ];
      return messages[streak % messages.length];
    }
    return 'Jawaban Tepat!';
  }

  String _getWrongMessage() {
    final messages = [
      'Almost there!',
      'Try again!',
      'Keep learning!',
      'Try it again!',
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }

  String _formatCorrectAnswer(dynamic correctAnswer) {
    if (correctAnswer == null) return '';
    if (correctAnswer is String) return correctAnswer;
    if (correctAnswer is List) return correctAnswer.join(', ');
    if (correctAnswer is Map) return correctAnswer['text']?.toString() ?? correctAnswer.toString();
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: Colors.white.withAlpha(50))),
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
                      _buildAnimatedIcon(isCorrect),
                      const SizedBox(width: 12),
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
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (isCorrect)
                              Text(
                                'Kamu menjawab dengan benar',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: Colors.white.withAlpha(200),
                                ),
                              )
                            else
                              Text(
                                _getWrongAnswerSubtext(),
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: Colors.white.withAlpha(200),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Game3DButton(
                  label: isLast ? 'SELESAI' : 'LANJUT',
                  color: btnColor,
                  shadowColor: darken(btnColor, 0.2),
                  textColor: Colors.white,
                  horizontalPadding: 28,
                  verticalPadding: 13,
                  onTap: onLanjut,
                ),
              ],
            ),

            if (currentStreak >= 3) ...[
              const SizedBox(height: 12),
              _buildStreakBadge(),
            ],

            if (!isCorrect && livesRemaining != null) ...[
              const SizedBox(height: 12),
              _buildLivesIndicator(),
            ],
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildAnimatedIcon(bool isCorrect) {
    final icon = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCorrect ? Icons.check : Icons.close,
        color: Colors.white,
        size: 24,
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

  Widget _buildStreakBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            '$currentStreak in a row!',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivesIndicator() {
    return Row(
      children: [
        Icon(
          Icons.favorite,
          color: result.livesRemaining == null ? Colors.white.withAlpha(100) : Colors.redAccent,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          'Nyawa tersisa: ',
          style: GoogleFonts.nunito(
            color: Colors.white.withAlpha(200),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        ...List.generate(
          result.livesRemaining ?? 0,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Text(
              '❤️',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
