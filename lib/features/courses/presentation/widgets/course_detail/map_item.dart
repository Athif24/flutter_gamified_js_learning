class MapItem {
  final bool isLesson;
  final String? unitName;
  final bool unitUnlocked;
  final String? lessonId;
  final String? lessonName;
  final bool isLocked;
  final bool isCompleted;
  final bool isFirstActive;
  final int lessonMapIndex;

  MapItem({
    required this.isLesson,
    this.unitName,
    this.unitUnlocked = false,
    this.lessonId,
    this.lessonName,
    this.isLocked = false,
    this.isCompleted = false,
    this.isFirstActive = false,
    this.lessonMapIndex = 0,
  });
}

class NodePos {
  final double x;
  final double y;
  const NodePos({required this.x, required this.y});
}