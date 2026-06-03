import 'package:flutter/foundation.dart';

final pendingDeepLinkNotifier = ValueNotifier<String?>(null);

String? parseNotificationPayload(Map<String, String> data) {
  final type = data['type'];
  final id = data['id'];
  if (type == null || id == null) return null;

  switch (type) {
    case 'course':
      return '/course/$id';
    case 'lesson': {
      final courseId = data['courseId'];
      return courseId != null ? '/lesson/$id?courseId=$courseId' : '/lesson/$id';
    }
    case 'quiz-intro':
    case 'quiz': {
      final courseId = data['courseId'];
      final lessonId = data['lessonId'];
      final params = <String>[];
      if (courseId != null) params.add('courseId=$courseId');
      if (lessonId != null) params.add('lessonId=$lessonId');
      final qs = params.isNotEmpty ? '?${params.join("&")}' : '';
      return '/$type/$id$qs';
    }
    default:
      return null;
  }
}
