import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../providers/course_provider.dart';
import '../../../achievement/presentation/providers/achievement_provider.dart';
import '../widgets/quiz/intro/intro_body.dart';
import '../widgets/quiz/intro/intro_skeleton.dart';

class QuizIntroScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String? courseId;
  final String? lessonId;

  const QuizIntroScreen({
    super.key,
    required this.quizId,
    this.courseId,
    this.lessonId,
  });

  @override
  ConsumerState<QuizIntroScreen> createState() => _QuizIntroScreenState();
}

class _QuizIntroScreenState extends ConsumerState<QuizIntroScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(quizPreviewProvider(widget.quizId));
      ref.invalidate(myQuizResultProvider(widget.quizId));
      ref.invalidate(quizAttemptProvider(widget.quizId));
      ref.invalidate(livesProvider);
      if (widget.courseId != null) {
        ref.invalidate(courseDetailProvider(widget.courseId!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final previewAsync = ref.watch(quizPreviewProvider(widget.quizId));
    final myResultAsync = ref.watch(myQuizResultProvider(widget.quizId));
    final livesAsync = ref.watch(livesProvider);
    final attemptAsync = ref.watch(quizAttemptProvider(widget.quizId));
    final courseDetailAsync = widget.courseId != null
        ? ref.watch(courseDetailProvider(widget.courseId!))
        : null;

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: S.scale(context, 8)),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: S.isTablet(context) ? 500 : double.infinity,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(S.scale(context, 28)),
                    child: previewAsync.when(
                      loading: () => IntroSkeleton(t: t),
                      error: (e, _) => ErrorBody(
                        t: t,
                        icon: iconForError(e),
                        title: AppStrings.errLoadQuiz,
                        message: sanitizeErrorMessage(e),
                        onRetry: () =>
                            ref.invalidate(quizPreviewProvider(widget.quizId)),
                      ),
                      data: (preview) => IntroBody(
                        preview: preview,
                        myResult: myResultAsync.asData?.value,
                        attempt: attemptAsync.asData?.value,
                        lives: livesAsync.asData?.value,
                        course: courseDetailAsync?.asData?.value,
                        t: t,
                        ref: ref,
                        quizId: widget.quizId,
                        courseId: widget.courseId,
                        lessonId: widget.lessonId,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}