class QuizOption {
  final String id;
  final String text;

  const QuizOption({required this.id, required this.text});

  factory QuizOption.fromJson(Map<String, dynamic> j) => QuizOption(
    id  : j['id']?.toString() ?? '',
    text: j['text'] ?? '',
  );
}

class TestCaseModel {
  final String input;
  final String expectedOutput;
  final bool isHidden;

  const TestCaseModel({
    required this.input,
    required this.expectedOutput,
    this.isHidden = false,
  });

  factory TestCaseModel.fromJson(Map<String, dynamic> j) => TestCaseModel(
    input          : j['input'] ?? '',
    expectedOutput : j['expectedOutput'] ?? j['expected_output'] ?? '',
    isHidden       : j['isHidden'] ?? j['is_hidden'] ?? false,
  );
}

class QuestionModel {
  final String id;
  final String text;
  final String type;
  final String? arrangeVariant;
  final List<QuizOption> optionObjects;
  final List<String> blocks;
  final int points;
  final List<TestCaseModel> testCases;
  final dynamic answerKey;
  final String? codeSnippet;
  final String? codeTemplate;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    this.arrangeVariant,
    this.optionObjects = const [],
    this.blocks        = const [],
    this.points        = 10,
    this.testCases     = const [],
    this.answerKey,
    this.codeSnippet,
    this.codeTemplate,
  });

  List<String> get options => optionObjects.map((o) => o.text).toList();

  factory QuestionModel.fromJson(Map<String, dynamic> j) {
    final questionField = j['question'];
    final String questionText;
    List<String> extractedBlocks = [];

    if (questionField is Map) {
      questionText = questionField['text'] as String? ?? '';

      if (questionField['blocks'] != null) {
        extractedBlocks = List<String>.from(questionField['blocks']);
      } else {
        final codeTemplate = questionField['codeTemplate'] as String?;
        final text = questionField['text'] as String? ?? '';
        final sourceText = codeTemplate ?? text;

        if (sourceText.contains('{{')) {
          final regex = RegExp(r'\{\{(\d+)\}\}');
          extractedBlocks = [];
          int lastEnd =0;
          for (final match in regex.allMatches(sourceText)) {
            if (match.start > lastEnd) {
              extractedBlocks.add(sourceText.substring(lastEnd, match.start));
            }
            extractedBlocks.add('___');
            lastEnd = match.end;
          }
          if (lastEnd < sourceText.length) {
            extractedBlocks.add(sourceText.substring(lastEnd));
          }
        }
      }
    } else {
      questionText = questionField as String? ?? j['text'] as String? ?? '';
    }

    final rawOptions = j['options'] as List? ?? [];
    final List<QuizOption> parsedOptions = rawOptions.map((o) {
      if (o is Map<String, dynamic>) {
        return QuizOption.fromJson(o);
      } else {
        return QuizOption(id: o.toString(), text: o.toString());
      }
    }).toList();

    final rawTestCases = j['test_case'] as List? ?? [];
    final testCases = rawTestCases.map((tc) {
      if (tc is Map<String, dynamic>) {
        return TestCaseModel.fromJson(tc);
      }
      return const TestCaseModel(input: '', expectedOutput: '', isHidden: false);
    }).toList();

    final blocks = extractedBlocks.isNotEmpty
        ? extractedBlocks
        : List<String>.from(j['blocks'] ?? []);

    final codeSnippet = questionField is Map
        ? questionField['codeSnippet'] as String?
        : null;
    final codeTemplate = questionField is Map
        ? questionField['codeTemplate'] as String?
        : null;

    return QuestionModel(
      id           : j['id']?.toString() ?? '',
      text         : questionText,
      type         : j['type'] ?? 'choice',
      arrangeVariant: j['arrange_variant'] as String?,
      optionObjects: parsedOptions,
      blocks       : blocks,
      points       : (j['score_weight'] ?? j['points'] ?? 10) as int,
      testCases    : testCases,
      answerKey    : j['answer_key'],
      codeSnippet  : codeSnippet,
      codeTemplate : codeTemplate,
    );
  }
}
