import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/loading_circle.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
import '../providers/course_provider.dart';
import '../../data/models/course_model.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});
  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> with SilentRefreshMixin<CourseDetailScreen> {
  final _scrollCtrl = ScrollController();
  final List<GlobalKey> _itemKeys = [];
  List<double> _unitPositions = [];
  List<String> _unitNames = [];
  final _activeUnitName = ValueNotifier('');
  final _isUnitHeaderVisible = ValueNotifier<bool>(true);
  bool _scrolledToActive = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _isUnitHeaderVisible.dispose();
    _activeUnitName.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_unitPositions.isEmpty) return;
    final offset = _scrollCtrl.offset;
    int activeIdx = 0;
    for (int i = 0; i < _unitPositions.length; i++) {
      if (_unitPositions[i] <= offset + 48) {
        activeIdx = i;
      } else {
        break;
      }
    }

    // Cek apakah unit header aktif masih terlihat di viewport
    final unitHeaderTop = _unitPositions[activeIdx];
    final unitHeaderBottom = unitHeaderTop + 72; // 72 = tinggi _UnitHeader

    // Header "tidak terlihat" jika sudah ter-scroll ke atas (bottom < offset)
    _isUnitHeaderVisible.value = unitHeaderBottom >= offset;

    _activeUnitName.value = _unitNames[activeIdx];
  }

  void _computeUnitInfo(List<_MapItem> items) {
    _unitPositions = [];
    _unitNames = [];
    double y = 0;
    for (final item in items) {
      if (item.isLesson) {
        y += item.isFirstActive ? 192 : 152;
      } else {
        _unitPositions.add(y);
        _unitNames.add(item.unitName ?? '');
        y += 72;
      }
    }
  }

  void _scrollToActive(List<_MapItem> items) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lessonItems = items.where((e) => e.isLesson).toList();
      for (int i = 0; i < lessonItems.length; i++) {
        if (!lessonItems[i].isCompleted && !lessonItems[i].isLocked) {
          final idx = items.indexOf(lessonItems[i]);
          if (idx >= 0 && idx < _itemKeys.length) {
            final ctx = _itemKeys[idx].currentContext;
            if (ctx != null) {
              Scrollable.ensureVisible(ctx,
                  alignment: 0.3,
                  duration: 700.ms,
                  curve: Curves.easeInOutCubic);
            }
          }
          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: Column(
        children: [
          SlowLoadingIndicator(visible: showSlowIndicator, t: t),
          Expanded(
            child: courseAsync.when(
              loading: () => LoadingCircle(t: t),
              error: (e, _) => ErrorBody(
                t: t,
                title: AppStrings.errLoadCourseDetail,
                message: sanitizeErrorMessage(e),
                onRetry: () {
                  setShowSlowIndicator(true);
                  ref.invalidate(courseDetailProvider(widget.courseId));
                },
              ),
              data: (course) => _buildContent(t, course),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BloomTheme t, CourseModel course) {
    final units = course.units;
    final p = course.progress > 0
        ? course.progress
        : (course.totalLessons > 0
            ? course.completedLessons / course.totalLessons
            : 0.0);
    final pct = (p * 100).toInt();
    final completedUnits =
        units.where((u) => u.lessons.every((l) => l.isCompleted)).length;

    final items = _buildMapItems(units);
    _computeUnitInfo(items);
    if (_activeUnitName.value.isEmpty && _unitNames.isNotEmpty) {
      _activeUnitName.value = _unitNames.first;
    }
    if (_itemKeys.length != items.length) {
      _itemKeys
        ..clear()
        ..addAll(List.generate(items.length, (_) => GlobalKey()));
    }
    if (!_scrolledToActive) {
      _scrollToActive(items);
      _scrolledToActive = true;
    }

    return SafeArea(
      child: Column(
        children: [
          // Back button + Course title (app bar region)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Kembali',
                  child: Bounceable(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: t.bgSurface2,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.textPrimary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.textPrimary,
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_ios_rounded,
                          color: t.textPrimary, size: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Detail Kursus',
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _HeaderCard(
              course: course,
              progress: p,
              progressPct: pct,
              completedUnits: completedUnits,
              t: t),
          // Peta Belajar title (fixed — never scrolls)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                Icon(Icons.menu_book, size: 24, color: t.primary),
                const SizedBox(width: 8),
                Text('Peta Belajar',
                    style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          // Active BAB indicator (smooth slide+fade transition)
          ValueListenableBuilder<bool>(
            valueListenable: _isUnitHeaderVisible,
            builder: (_, headerVisible, __) {
              return ValueListenableBuilder<String>(
                valueListenable: _activeUnitName,
                builder: (_, name, __) {
                  final shouldShow = name.isNotEmpty && !headerVisible;
                  return AnimatedSwitcher(
                    duration: 250.ms,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: shouldShow
                        ? Container(
                            key: ValueKey('banner-$name'),
                            margin: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: t.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: t.textPrimary,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag, size: 14, color: t.primary),
                                const SizedBox(width: 6),
                                Text(name.toUpperCase(),
                                    style: GoogleFonts.nunito(
                                      color: t.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    )),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('hidden')),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text('Belum ada bab',
                        style: GoogleFonts.nunito(
                            color: t.mutedText, fontSize: 14)))
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(courseDetailProvider(widget.courseId));
                    },
                    child: RepaintBoundary(
                      child: _PetaBelajar(
                        items: items,
                        scrollCtrl: _scrollCtrl,
                        itemKeys: _itemKeys,
                        t: t,
                        courseId: widget.courseId,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<_MapItem> _buildMapItems(List<UnitModel> units) {
    final items = <_MapItem>[];
    int lessonIdx = 0;
    bool foundFirst = false;

    for (final unit in units) {
      final unitUnlocked = !unit.lessons.every((l) => l.isLocked);

      items.add(_MapItem(
        isLesson: false,
        unitName: unit.title,
        unitUnlocked: unitUnlocked,
      ));

      for (int i = 0; i < unit.lessons.length; i++) {
        final lesson = unit.lessons[i];
        final prevLesson = i > 0 ? unit.lessons[i - 1] : null;
        final isLocked = !unitUnlocked ||
            (prevLesson != null && !prevLesson.isCompleted);
        final isFirstActive =
            !foundFirst && !lesson.isCompleted && !isLocked;
        if (isFirstActive) foundFirst = true;

        items.add(_MapItem(
          isLesson: true,
          lessonId: lesson.id,
          lessonName: lesson.title,
          isLocked: isLocked,
          isCompleted: lesson.isCompleted,
          isFirstActive: isFirstActive,
          lessonMapIndex: lessonIdx,
        ));
        lessonIdx++;
      }
    }
    return items;
  }

}

class _MapItem {
  final bool isLesson;
  final String? unitName;
  final bool unitUnlocked;
  final String? lessonId;
  final String? lessonName;
  final bool isLocked;
  final bool isCompleted;
  final bool isFirstActive;
  final int lessonMapIndex;

  _MapItem({
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

// ── Header Card ─────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final CourseModel course;
  final double progress;
  final int progressPct;
  final int completedUnits;
  final BloomTheme t;
  const _HeaderCard({
    required this.course,
    required this.progress,
    required this.progressPct,
    required this.completedUnits,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final cBg = t.primary;
    final cFg = t.primaryContent;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: cBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.textPrimary, width: 2),
        boxShadow: [
          BoxShadow(color: t.textPrimary, offset: const Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Hero
            Hero(
                    tag: 'course-title-${course.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(course.title,
                          style: GoogleFonts.nunito(
                              color: cFg,
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                  if (course.description != null &&
                      course.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(course.description!,
                        style: GoogleFonts.nunito(
                            color: cFg.withValues(alpha: 0.8),
                            fontSize: 13)),
                  ],
                  const SizedBox(height: 16),
                  // Stats row (3-pill layout like Achievement Hero Card)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: cFg.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: t.textPrimary.withValues(alpha: 0.5), width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: cFg.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cFg.withValues(alpha: 0.3), width: 1.5),
                                ),
                                child: Center(child: Icon(Icons.menu_book, color: cFg, size: 16)),
                              ),
                              const SizedBox(height: 8),
                              Text('${course.totalLessons}', style: GoogleFonts.nunito(
                                  color: cFg, fontSize: 18, fontWeight: FontWeight.w900)),
                              Text('LESSON', style: GoogleFonts.nunito(
                                  color: cFg.withValues(alpha: 0.8), fontSize: 10,
                                  fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: t.textPrimary.withValues(alpha: 0.2)),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: cFg.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cFg.withValues(alpha: 0.3), width: 1.5),
                                ),
                                child: Center(child: Icon(Icons.check, color: cFg, size: 16)),
                              ),
                              const SizedBox(height: 8),
                              Text('$completedUnits/${course.units.length}', style: GoogleFonts.nunito(
                                  color: cFg, fontSize: 18, fontWeight: FontWeight.w900)),
                              Text('UNIT SELESAI', style: GoogleFonts.nunito(
                                  color: cFg.withValues(alpha: 0.8), fontSize: 10,
                                  fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: t.textPrimary.withValues(alpha: 0.2)),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: cFg.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cFg.withValues(alpha: 0.3), width: 1.5),
                                ),
                                child: Center(child: Icon(Icons.percent_rounded, color: cFg, size: 16)),
                              ),
                              const SizedBox(height: 8),
                              Text('$progressPct%', style: GoogleFonts.nunito(
                                  color: cFg, fontSize: 18, fontWeight: FontWeight.w900)),
                              Text('PROGRES', style: GoogleFonts.nunito(
                                  color: cFg.withValues(alpha: 0.8), fontSize: 10,
                                  fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: cFg.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation(cFg),
                      minHeight: 12,
                    ),
                  ),
              ],
            ),
          ),
        );
  }
}

// ── Peta Belajar ──────────────────────────────────────────────────────────

class _PetaBelajar extends StatelessWidget {
  final List<_MapItem> items;
  final ScrollController scrollCtrl;
  final List<GlobalKey> itemKeys;
  final BloomTheme t;
  final String courseId;

  const _PetaBelajar({
    required this.items,
    required this.scrollCtrl,
    required this.itemKeys,
    required this.t,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final centerX = constraints.maxWidth / 2;
        final positions = <_NodePos>[];
        double y = 0;

          for (int i = 0; i < items.length; i++) {
            final item = items[i];
            if (item.isLesson) {
              final lessonH = item.isFirstActive ? 192.0 : 152.0;
              final offsetX = item.lessonMapIndex.isEven ? -70.0 : 70.0;
              positions.add(_NodePos(
                x: centerX + offsetX,
                y: y + lessonH / 2,
              ));
              y += lessonH;
            } else {
            y += 72;
          }
        }

        return SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.only(bottom: 24),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (positions.length >= 2)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PetaBelajarPainter(
                        positions: positions, t: t),
                  ),
                ),
              Column(
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  if (!item.isLesson) {
                    return _UnitHeader(
                      name: item.unitName ?? '',
                      t: t,
                    );
                  }
                  return Semantics(
                    button: true,
                    label: item.isLocked
                        ? '${item.lessonName} (terkunci)'
                        : 'Buka ${item.lessonName}',
                    child: Bounceable(
                      onTap: item.isLocked
                          ? null
                          : () => context.push(
                              '/lesson/${item.lessonId}?courseId=$courseId'),
                      child: Container(
                      key: itemKeys[i],
                      height: item.isFirstActive ? 192 : 152,
                      alignment: Alignment.center,
                      child: _LessonBubble(
                        name: item.lessonName ?? '',
                        isLocked: item.isLocked,
                        isCompleted: item.isCompleted,
                        isFirstActive: item.isFirstActive,
                        mapIndex: item.lessonMapIndex,
                        t: t,
                      ),
                    ),
                  ),
                );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NodePos {
  final double x;
  final double y;
  const _NodePos({required this.x, required this.y});
}

// ── Unit Header ───────────────────────────────────────────────────────────

class _UnitHeader extends StatelessWidget {
  final String name;
  final BloomTheme t;
  const _UnitHeader({required this.name, required this.t});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          const Expanded(child: SizedBox()),
          Expanded(
            flex: 3,
            child: Divider(color: t.border.withValues(alpha: 0.15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  width: 2,
                  color: t.textPrimary,
                ),
                color: t.bgSurface2,
                boxShadow: [
                  BoxShadow(
                    color: t.textPrimary,
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                name.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Divider(color: t.border.withValues(alpha: 0.15)),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

// ── Lesson Bubble ─────────────────────────────────────────────────────────

class _LessonBubble extends StatelessWidget {
  final String name;
  final bool isLocked;
  final bool isCompleted;
  final bool isFirstActive;
  final int mapIndex;
  final BloomTheme t;

  const _LessonBubble({
    required this.name,
    required this.isLocked,
    required this.isCompleted,
    required this.isFirstActive,
    required this.mapIndex,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final offsetX = mapIndex.isEven ? -70.0 : 70.0;

    // Circle widget shared between animated and static states
    Widget circle = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      color: isCompleted
          ? t.bgSurface
          : isLocked
              ? t.bgSurface2
              : t.primary,
        border: Border.all(
          width: 2,
          color: t.textPrimary,
        ),
        boxShadow: [
          BoxShadow(
            color: t.textPrimary,
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner decor circle (only for unlocked bubbles)
          if (!isLocked)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.primaryContent.withValues(alpha: 0.15),
                ),
              ),
            ),
          Center(
            child: isCompleted
                ? Icon(Icons.check,
                    size: 24, color: t.success)
                : isLocked
                    ? Icon(Icons.lock_outline,
                        size: 20,
                        color: t.mutedText.withValues(alpha: 0.5))
                    : Icon(Icons.menu_book_rounded,
                        size: 22, color: t.primaryContent),
          ),
        ],
      ),
    );

    // Subtle breathe pulse on the active bubble
    if (isFirstActive) {
      circle = circle
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(duration: 1200.ms, begin: 1.0, end: 1.06);
    }

    Widget bubble = Transform.translate(
      offset: Offset(offsetX, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              circle,
              const SizedBox(height: 8),
              // Label
              SizedBox(
                width: 120,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    color: isLocked
                        ? t.mutedText.withValues(alpha: 0.5)
                        : t.textPrimary.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          // "Mulai di sini!" floating above the bubble
          if (isFirstActive)
            Positioned(
              top: -40,
              left: 0,
              right: 0,
              child: Center(
                child: _StartHereLabel(t: t),
              ),
            ),
        ],
      ),
    );

    return bubble;
  }
}

// ── Start Here Label ──────────────────────────────────────────────────────

class _StartHereLabel extends StatelessWidget {
  final BloomTheme t;
  const _StartHereLabel({required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: t.textPrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.textPrimary, width: 2),
          ),
          child: Text(
            'Mulai di sini!',
            style: GoogleFonts.nunito(
              color: t.bgPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        // Arrow triangle pointing down
        Transform.translate(
          offset: const Offset(0, -6),
          child: Transform.rotate(
            angle: 0.7854,
            child: Container(
              width: 10,
              height: 10,
              color: t.textPrimary,
            ),
          ),
        ),
      ],
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .moveY(duration: 1500.ms, begin: 0, end: -4);
  }
}

// ── Peta Belajar Painter (connecting lines) ───────────────────────────────

class _PetaBelajarPainter extends CustomPainter {
  final List<_NodePos> positions;
  final BloomTheme t;

  _PetaBelajarPainter({required this.positions, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = t.border.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Create dashed path effect manually
    final dashWidth = 10.0;
    final dashSpace = 8.0;

    for (int i = 0; i < positions.length - 1; i++) {
      final a = positions[i];
      final b = positions[i + 1];

      final path = Path();
      path.moveTo(a.x, a.y);
      path.cubicTo(a.x, a.y + 40, b.x, b.y - 40, b.x, b.y);

      // Draw dashed version
      final metrics = path.computeMetrics();
      for (final metric in metrics) {
        double distance = 0;
        while (distance < metric.length) {
          final end = min(distance + dashWidth, metric.length);
          final segment = metric.extractPath(distance, end);
          canvas.drawPath(segment, paint);
          distance += dashWidth + dashSpace;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PetaBelajarPainter o) =>
      o.positions != positions;
}


