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
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/services/sound_service.dart';
import '../providers/course_provider.dart';
import '../../data/models/course_model.dart';
import '../widgets/course_detail/map_item.dart';
import '../widgets/course_detail/header_card.dart';
import '../widgets/course_detail/peta_belajar_widget.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});
  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SilentRefreshMixin<CourseDetailScreen> {
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

  void _computeUnitInfo(List<MapItem> items) {
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

  void _scrollToActive(List<MapItem> items) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lessonItems = items.where((e) => e.isLesson).toList();
      for (int i = 0; i < lessonItems.length; i++) {
        if (!lessonItems[i].isCompleted && !lessonItems[i].isLocked) {
          final idx = items.indexOf(lessonItems[i]);
          if (idx >= 0 && idx < _itemKeys.length) {
            final ctx = _itemKeys[idx].currentContext;
            if (ctx != null) {
              Scrollable.ensureVisible(
                ctx,
                alignment: 0.3,
                duration: 700.ms,
                curve: Curves.easeInOutCubic,
              );
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
      body: SafeArea(
        child: Column(
          children: [
            SlowLoadingIndicator(visible: showSlowIndicator, t: t),
            Expanded(
              child: courseAsync.when(
                loading: () => LoadingCircle(t: t),
                error: (e, _) => ErrorBody(
                  t: t,
                  icon: iconForError(e),
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
    final completedUnits = units
        .where((u) => u.lessons.every((l) => l.isCompleted))
        .length;

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
            padding: EdgeInsets.fromLTRB(
              S.scale(context, 16),
              S.scale(context, 8),
              S.scale(context, 16),
              0,
            ),
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Kembali',
                  child: Bounceable(
                    onTap: () {
                      ref.read(soundProvider).playClick();
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    child: Container(
                      width: S.scale(context, 38),
                      height: S.scale(context, 38),
                      decoration: BoxDecoration(
                        color: t.bgSurface2,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
                        boxShadow: [
                          BoxShadow(
                            color: t.textPrimary,
                            offset: Offset(S.scale(context, 3), S.scale(context, 3)),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: t.textPrimary,
                        size: S.scale(context, 15),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: S.scale(context, 12)),
                Flexible(
                  child: Text(
                    'Detail Kursus',
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: S.font(context, 18),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          HeaderCard(
            course: course,
            progress: p,
            progressPct: pct,
            completedUnits: completedUnits,
            t: t,
          ),
          // Peta Belajar title (fixed — never scrolls)
          Padding(
            padding: EdgeInsets.fromLTRB(
              S.scale(context, 24),
              S.scale(context, 16),
              S.scale(context, 24),
              0,
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book, size: S.scale(context, 24), color: t.primary),
                SizedBox(width: S.scale(context, 8)),
                Text(
                  'Peta Belajar',
                  style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontSize: S.font(context, 20),
                    fontWeight: FontWeight.w900,
                  ),
                ),
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
                            margin: EdgeInsets.fromLTRB(
                              S.scale(context, 24),
                              S.scale(context, 10),
                              S.scale(context, 24),
                              0,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: S.scale(context, 14),
                              vertical: S.scale(context, 6),
                            ),
                            decoration: BoxDecoration(
                              color: t.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(S.scale(context, 50)),
                              border: Border.all(
                                color: t.textPrimary,
                                width: S.scale(context, 2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag, size: S.scale(context, 14), color: t.primary),
                                SizedBox(width: S.scale(context, 6)),
                                Text(
                                  name.toUpperCase(),
                                  style: GoogleFonts.nunito(
                                    color: t.primary,
                                    fontSize: S.font(context, 11),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: S.scale(context, 1.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('hidden')),
                  );
                },
              );
            },
          ),
          SizedBox(height: S.scale(context, 12)),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada bab',
                      style: GoogleFonts.nunito(
                        color: t.mutedText,
                        fontSize: S.font(context, 14),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(courseDetailProvider(widget.courseId));
                    },
                    child: RepaintBoundary(
                      child: PetaBelajar(
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

  List<MapItem> _buildMapItems(List<UnitModel> units) {
    final items = <MapItem>[];
    int lessonIdx = 0;
    bool foundFirst = false;

    for (final unit in units) {
      final unitUnlocked = !unit.lessons.every((l) => l.isLocked);

      items.add(
        MapItem(
          isLesson: false,
          unitName: unit.title,
          unitUnlocked: unitUnlocked,
        ),
      );

      for (int i = 0; i < unit.lessons.length; i++) {
        final lesson = unit.lessons[i];
        final prevLesson = i > 0 ? unit.lessons[i - 1] : null;
        final isLocked =
            !unitUnlocked || (prevLesson != null && !prevLesson.isCompleted);
        final isFirstActive = !foundFirst && !lesson.isCompleted && !isLocked;
        if (isFirstActive) foundFirst = true;

        items.add(
          MapItem(
            isLesson: true,
            lessonId: lesson.id,
            lessonName: lesson.title,
            isLocked: isLocked,
            isCompleted: lesson.isCompleted,
            isFirstActive: isFirstActive,
            lessonMapIndex: lessonIdx,
          ),
        );
        lessonIdx++;
      }
    }
    return items;
  }
}