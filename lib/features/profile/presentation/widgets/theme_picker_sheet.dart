import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/services/sound_service.dart';
import '../../../../core/utils/responsive_utils.dart';

void showThemePicker(BuildContext context, WidgetRef ref) {
  final t = ref.read(currentThemeProvider);
  final currentId = t.id;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ThemePickerSheet(currentThemeId: currentId),
  );
}

class _ThemePickerSheet extends ConsumerStatefulWidget {
  final String currentThemeId;
  const _ThemePickerSheet({required this.currentThemeId});

  @override
  ConsumerState<_ThemePickerSheet> createState() => _ThemePickerSheetState();
}

class _ThemePickerSheetState extends ConsumerState<_ThemePickerSheet> {
  late bool _showLight;

  @override
  void initState() {
    super.initState();
    final current = ref.read(currentThemeProvider);
    _showLight = current.isLight;
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final allThemes = bloomThemeList;
    final themes = allThemes.where((t) => t.isLight == _showLight).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.55,
      maxChildSize: 0.85,
      expand: false,
      snap: true,
      snapSizes: const [0.55, 0.85],
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: t.bgSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(S.scale(context, 24))),
            border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
          ),
          child: Column(
            children: [
              Container(
                height: S.scale(context, 48),
                alignment: Alignment.center,
                child: Container(
                  width: S.scale(context, 48),
                  height: S.scale(context, 6),
                  decoration: BoxDecoration(
                    color: t.mutedText,
                    borderRadius: BorderRadius.circular(S.scale(context, 3)),
                    boxShadow: [
                      BoxShadow(
                        color: t.mutedText.withValues(alpha: 0.3),
                        blurRadius: S.scale(context, 4),
                        offset: Offset(0, S.scale(context, 2)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: S.scale(context, 8)),
              _TabBar(
                isLight: _showLight,
                onToggle: (v) => setState(() => _showLight = v),
              ),
              SizedBox(height: S.scale(context, 12)),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(S.scale(context, 16), S.scale(context, 8), S.scale(context, 16), S.scale(context, 24)),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: S.isTablet(context) ? 5 : 4,
                    mainAxisSpacing: S.scale(context, 12),
                    crossAxisSpacing: S.scale(context, 12),
                    childAspectRatio: S.isTablet(context) ? 0.9 : 0.85,
                  ),
                  itemCount: themes.length,
                  itemBuilder: (_, i) => _CirclePreview(
                    theme: themes[i],
                    isActive: themes[i].id == widget.currentThemeId,
                    onTap: () {
                      ref.read(soundProvider).playClick();
                      ref.read(themeProvider.notifier).setTheme(themes[i].id);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabBar extends ConsumerWidget {
  final bool isLight;
  final ValueChanged<bool> onToggle;

  const _TabBar({required this.isLight, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: S.scale(context, 16)),
      decoration: BoxDecoration(
        color: t.bgSurface2,
        borderRadius: BorderRadius.circular(S.scale(context, 12)),
        border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: '☀️  Light',
              selected: isLight,
              onTap: () {
                ref.read(soundProvider).playClick();
                onToggle(true);
              },
            ),
          ),
          Expanded(
            child: _TabButton(
              label: '🌚  Dark',
              selected: !isLight,
              onTap: () {
                ref.read(soundProvider).playClick();
                onToggle(false);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends ConsumerWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);

    return Bounceable(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: S.scale(context, 10)),
        decoration: BoxDecoration(
          color: selected ? t.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(S.scale(context, 10)),
          border: selected ? Border.all(color: t.textPrimary, width: S.scale(context, 2)) : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: t.textPrimary,
                    offset: Offset(S.scale(context, 2), S.scale(context, 2)),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            color: selected ? t.primaryContent : t.mutedText,
            fontWeight: FontWeight.w800,
            fontSize: S.font(context, 14),
          ),
        ),
      ),
    );
  }
}

class _CirclePreview extends ConsumerWidget {
  final BloomTheme theme;
  final bool isActive;
  final VoidCallback onTap;

  const _CirclePreview({
    required this.theme,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);

    return Bounceable(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: S.scale(context, 56),
            height: S.scale(context, 56),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [theme.primary, theme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: isActive
                  ? Border.all(
                      color: t.textPrimary,
                      width: S.scale(context, 2.5),
                    )
                  : null,
            ),
          ),
          SizedBox(height: S.scale(context, 6)),
          Text(
            theme.name,
            style: GoogleFonts.nunito(
              color: t.mutedText,
              fontSize: S.font(context, 11),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
