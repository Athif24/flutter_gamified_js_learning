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
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/course_provider.dart';
import '../../data/models/course_model.dart';
import '../widgets/course_detail/map_item.dart';
import '../widgets/course_detail/header_card.dart';
import '../widgets/course_detail/peta_belajar_widget.dart';
import '../widgets/course_detail/course_tutorial_overlay.dart';

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
  bool _tutorialSeen = false;
  final _headerKey = GlobalKey();
  final _petaKey = GlobalKey();
  bool _isCardExpanded = true;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;
    final seen = await isCourseTutorialSeen(userId);
    if (mounted) setState(() => _tutorialSeen = seen);
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
      if (_unitPositions[i] <= offset + S.scale(context, 48)) {
        activeIdx = i;
      } else {
        break;
      }
    }

    // Header "tidak terlihat" jika top-nya sudah ter-scroll melewati 16px dari viewport top
    final unitHeaderTop = _unitPositions[activeIdx];
    _isUnitHeaderVisible.value = unitHeaderTop >= offset - S.scale(context, 16);

    _activeUnitName.value = _unitNames[activeIdx];
  }

  void _computeUnitInfo(List<MapItem> items) {
    _unitPositions = [];
    _unitNames = [];
    double y = 0;
    for (final item in items) {
      if (item.isLesson) {
        y += S.scale(context, item.isFirstActive ? 192 : 152);
      } else {
        _unitPositions.add(y);
        _unitNames.add(item.unitName ?? '');
        y += S.scale(context, 72);
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
              final renderObj = ctx.findRenderObject();
              if (renderObj is RenderBox && renderObj.attached) {
                final pos = renderObj.localToGlobal(Offset.zero);
                final viewportHeight = MediaQuery.of(context).size.height;
                if (pos.dy >= 0 && pos.dy < viewportHeight * 0.7) return;
              }
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
    final firstActiveLessonIdx = items.indexWhere(
      (e) => e.isLesson && !e.isCompleted && !e.isLocked,
    );

    Widget content = Column(
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
          Container(
            key: _headerKey,
            child: HeaderCard(
              course: course,
              progress: p,
              progressPct: pct,
              completedUnits: completedUnits,
              t: t,
              isExpanded: _isCardExpanded,
              onToggle: () {
                setState(() => _isCardExpanded = !_isCardExpanded);
                Future.delayed(const Duration(milliseconds: 350), () {
                  if (mounted) setState(() {});
                });
              },
            ),
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
              key: _petaKey,
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
                  return AnimatedSize(
                    duration: 250.ms,
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment.topCenter,
                    child: shouldShow
                        ? Container(
                            key: ValueKey('banner-$name'),
                            margin: EdgeInsets.fromLTRB(
                              S.scale(context, 24),
                              S.scale(context, 6),
                              S.scale(context, 24),
                              0,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: S.scale(context, 14),
                              vertical: S.scale(context, 5),
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
                                Icon(Icons.flag, size: S.scale(context, 12), color: t.primary),
                                SizedBox(width: S.scale(context, 6)),
                                Text(
                                  name.toUpperCase(),
                                  style: GoogleFonts.nunito(
                                    color: t.primary,
                                    fontSize: S.font(context, 10),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: S.scale(context, 1.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(
                            key: ValueKey('hidden'),
                          ),
                  );
                },
              );
            },
          ),
          SizedBox(height: S.scale(context, 24)),
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
      );

    final userId = ref.read(authProvider).user?.id ?? '';
    final firstActiveKey = firstActiveLessonIdx >= 0 && firstActiveLessonIdx < _itemKeys.length
        ? _itemKeys[firstActiveLessonIdx]
        : null;

    return SafeArea(
      child: CourseTutorialOverlay(
        show: !_tutorialSeen,
        theme: t,
        onComplete: () async {
          if (userId.isNotEmpty) {
            await markCourseTutorialSeen(userId);
          }
          if (mounted) setState(() => _tutorialSeen = true);
        },
        steps: [
          TutorialStepData(
            targetKey: _headerKey,
            spotlightRadius: 24,
            extendToTop: 16,
            insetLeft: 8,
            insetRight: 8,
            insetBottom: 18,
            title: 'Informasi Kursus',
            description:
                'Ini header kursus. Kamu bisa melihat judul, jumlah materi, unit yang sudah selesai, dan progres belajarmu. Klik tombol ▲/▼ untuk menyembunyikan atau menampilkan detail.',
          ),
          TutorialStepData(
            targetKey: _petaKey,
            extendToBottom: -1,
            extendToTop: 22,
            insetLeft: -5,
            insetRight: -5,
            title: 'Peta Belajar',
            description:
                'Ini adalah peta belajarmu. Semua materi dan quiz tersusun rapi dari awal hingga akhir. Gulir ke bawah untuk melihat materi selanjutnya.',
          ),
          TutorialStepData(
            targetKey: firstActiveKey,
            circleHighlight: true,
            circleRadius: 38,
            circleOffset: Offset(-65, -40),
            title: 'Materi Pembelajaran',
            description:
                'Setiap lingkaran adalah satu materi. Lingkaran biru dengan buku = siap dipelajari, hijau dengan centang = sudah selesai, abu-abu dengan kunci = masih terkunci.',
          ),
          TutorialStepData(
            targetKey: firstActiveKey,
            extendToTop: 25,
            insetLeft: 50,
            insetRight: 185,
            insetBottom: 75,
            spotlightRadius: 16,
            title: 'Mulai Belajar',
            description:
                'Tap lingkaran biru untuk mulai membaca materi. Bacalah dengan saksama dan pahami setiap konsep yang diajarkan.',
          ),
          TutorialStepData(
            title: 'Kerjakan Quiz',
            description:
                'Setelah selesai membaca materi, kerjakan quiz untuk menguji pemahamanmu. Semakin tinggi skor, semakin banyak XP yang kamu dapatkan!',
          ),
        ],
        child: content,
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