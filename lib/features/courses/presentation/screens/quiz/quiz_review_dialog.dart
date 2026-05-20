import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../data/models/course_model.dart';

class ReviewDialog extends StatelessWidget {
  final List<QuestionResultModel> questionResults;
  final List<QuestionModel> questions;
  final BloomTheme t;

  const ReviewDialog({
    super.key,
    required this.questionResults,
    required this.questions,
    required this.t,
  });

  String _findCorrectText(QuestionModel q, QuestionResultModel qr) {
    if (qr.correctAnswer is String) return qr.correctAnswer as String;
    if (qr.correctAnswer is List) return (qr.correctAnswer as List).join(', ');
    if (qr.correctAnswer is Map) return qr.correctAnswer['text']?.toString() ?? '';
    for (final opt in q.optionObjects) {
      if (opt.id == qr.correctAnswer.toString()) return opt.text;
    }
    return qr.correctAnswer?.toString() ?? '';
  }

  String _findUserText(QuestionModel q, QuestionResultModel qr) {
    if (qr.userAnswer is String) return qr.userAnswer as String;
    if (qr.userAnswer is List) return (qr.userAnswer as List).join(', ');
    if (qr.userAnswer is Map) return qr.userAnswer['text']?.toString() ?? '';
    for (final opt in q.optionObjects) {
      if (opt.id == qr.userAnswer.toString()) return opt.text;
    }
    return qr.userAnswer?.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: t.bgSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Lihat Jawaban',
                  style: GoogleFonts.nunito(
                      color: t.textPrimary, fontSize: 18,
                      fontWeight: FontWeight.w900)),
              const Spacer(),
              Bounceable(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close_rounded, color: t.textSecondary, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: questionResults.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final qr = questionResults[i];
                final q = questions.firstWhere(
                  (qq) => qq.id == qr.questionId,
                  orElse: () => QuestionModel(id: qr.questionId, text: 'Soal #$i', type: 'choice', points: 10),
                );
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: qr.isCorrect ? t.success.withValues(alpha: 0.08) : t.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: qr.isCorrect ? t.success.withValues(alpha: 0.3) : t.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            qr.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: qr.isCorrect ? t.success : t.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Soal ${i + 1}',
                            style: GoogleFonts.nunito(
                              color: t.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(q.text,
                          style: GoogleFonts.nunito(
                              color: t.textPrimary, fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Skor: ${qr.score}/${qr.maxScore}',
                            style: GoogleFonts.nunito(
                              color: qr.isCorrect ? t.success : t.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
