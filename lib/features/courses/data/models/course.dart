import 'lesson_model.dart';

class CourseModel {
  final String id;
  final String title;
  final String? description;
  final String? thumbnail;
  final int totalLessons;
  final int completedLessons;
  final bool isEnrolled;
  final bool isPublished;
  final double progress;
  final bool isCompleted;
  final String? lastAccessedLessonTitle;
  final String? lastAccessedUnitTitle;
  final List<UnitModel> units;

  const CourseModel({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    this.totalLessons    = 0,
    this.completedLessons = 0,
    this.isEnrolled      = false,
    this.isPublished     = true,
    this.progress        = 0.0,
    this.isCompleted     = false,
    this.lastAccessedLessonTitle,
    this.lastAccessedUnitTitle,
    this.units           = const [],
  });

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnail,
    int? totalLessons,
    int? completedLessons,
    bool? isEnrolled,
    bool? isPublished,
    double? progress,
    bool? isCompleted,
    String? lastAccessedLessonTitle,
    String? lastAccessedUnitTitle,
    List<UnitModel>? units,
  }) => CourseModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    thumbnail: thumbnail ?? this.thumbnail,
    totalLessons: totalLessons ?? this.totalLessons,
    completedLessons: completedLessons ?? this.completedLessons,
    isEnrolled: isEnrolled ?? this.isEnrolled,
    isPublished: isPublished ?? this.isPublished,
    progress: progress ?? this.progress,
    isCompleted: isCompleted ?? this.isCompleted,
    lastAccessedLessonTitle: lastAccessedLessonTitle ?? this.lastAccessedLessonTitle,
    lastAccessedUnitTitle: lastAccessedUnitTitle ?? this.lastAccessedUnitTitle,
    units: units ?? this.units,
  );

  factory CourseModel.fromJson(Map<String, dynamic> j) {
    final rawUnits = (j['units'] as List? ?? []);
    int completedFromUnits = 0;
    int totalFromUnits = 0;
    for (final u in rawUnits) {
      final lessons = (u as Map)['lessons'] as List? ?? [];
      totalFromUnits += lessons.length;
      for (final l in lessons) {
        if ((l as Map)['is_completed'] == true || l['isCompleted'] == true) {
          completedFromUnits++;
        }
      }
    }

    return CourseModel(
      id               : j['id']?.toString() ?? '',
      title            : j['name'] ?? j['title'] ?? '',
      description      : j['description'],
      thumbnail        : j['thumbnail'] ?? j['imageUrl'],
      totalLessons     : (j['total_lessons'] ?? j['totalLessons'] ?? j['lessonsCount'] ?? totalFromUnits) as int,
      completedLessons : (j['completed_lessons'] ?? j['completedLessons'] ?? j['completedCount'] ?? completedFromUnits) as int,
      isEnrolled       : j['is_enrolled'] ?? j['isEnrolled'] ?? j['enrolled'] ?? false,
      isPublished      : j['is_published'] ?? j['isPublished'] ?? true,
      progress         : _parseDouble(j['progress']),
      isCompleted      : j['is_completed'] ?? j['isCompleted'] ?? false,
      lastAccessedLessonTitle: j['last_accessed_lesson_title'] ?? j['lastAccessedLessonTitle'],
      lastAccessedUnitTitle: j['last_accessed_unit_title'] ?? j['lastAccessedUnitTitle'],
      units            : rawUnits
          .map((e) => UnitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v > 1 ? v / 100.0 : v;
    if (v is int) return v > 1 ? v / 100.0 : v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
