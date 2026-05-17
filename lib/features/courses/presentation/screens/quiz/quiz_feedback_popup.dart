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
  final VoidCallback onLanjut;

  const QuizFeedbackPopup({
    super.key,
    required this.result,
    required this.t,
    required this.isLast,
    this.currentQuestion,
    required this.onLanjut,
  });

  static const _correctBg = Color(0xFF15803d);
  static const _correctBtn = Color(0xFF166534);
  static const _incorrectBg = Color(0xFF991b1b);
  static const _incorrectBtn = Color(0xFF7f1d1d);

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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
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
                          isCorrect ? 'Jawaban Tepat!' : 'Jawaban Salah',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isCorrect
                              ? 'Kamu menjawab dengan benar'
                              : _getWrongAnswerSubtext(),
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
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
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildAnimatedIcon(bool isCorrect) {
    final icon = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
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
}
