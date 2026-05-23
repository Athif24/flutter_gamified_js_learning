import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';

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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: t.textPrimary, width: 2),
          ),
          child: Column(
            children: [
              Container(
                height: 48,
                alignment: Alignment.center,
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: t.mutedText,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: t.mutedText.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _TabBar(
                isLight: _showLight,
                onToggle: (v) => setState(() => _showLight = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: themes.length,
                  itemBuilder: (_, i) => _ThemeCard(
                    theme: themes[i],
                    isActive: themes[i].id == widget.currentThemeId,
                    onTap: () {
                      ref.read(themeProvider.notifier).setTheme(themes[i].id);
                      Navigator.of(context).pop();
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: t.bgSurface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.textPrimary, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Light',
              selected: isLight,
              onTap: () => onToggle(true),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Dark',
              selected: !isLight,
              onTap: () => onToggle(false),
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? t.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: t.textPrimary, width: 2) : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: t.textPrimary,
                    offset: const Offset(2, 2),
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
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends ConsumerWidget {
  final BloomTheme theme;
  final bool isActive;
  final VoidCallback onTap;

  const _ThemeCard({
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
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.bgPrimary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? t.textPrimary : theme.border,
                  width: isActive ? 2.5 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: t.textPrimary,
                          offset: const Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.bgSurface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.bgSurface3,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            theme.name,
            style: GoogleFonts.nunito(
              color: t.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
