import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../shared/services/sound_service.dart';
import '../../../../../../core/utils/responsive_utils.dart';

class ThemeStep extends ConsumerStatefulWidget {
  const ThemeStep({super.key});
  @override
  ConsumerState<ThemeStep> createState() => _ThemeStepState();
}

class _ThemeStepState extends ConsumerState<ThemeStep> {
  bool _showLight = true;

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final currentId = ref.watch(themeProvider).themeId;
    final allThemes = bloomThemeList;
    final themes = allThemes.where((x) => x.isLight == _showLight).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: S.scale(context, 24)).copyWith(bottom: S.scale(context, 16)),
      child: Column(
        children: [
          SizedBox(height: S.scale(context, 64)),
          ExcludeSemantics(child: Icon(Icons.palette_rounded, size: S.scale(context, 48), color: t.primary)),
          SizedBox(height: S.scale(context, 12)),
          Text(
            'Pilih Tema Favorit',
            style: GoogleFonts.nunito(
              fontSize: S.font(context, 22),
              fontWeight: FontWeight.w900,
              color: t.textPrimary,
            ),
          ),
          SizedBox(height: S.scale(context, 6)),
          Text(
            '${allThemes.length} tema tersedia',
            style: GoogleFonts.nunito(
              fontSize: S.font(context, 12),
              color: t.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: S.scale(context, 16)),
          _TabBar(
            t: t,
            isLight: _showLight,
            onToggle: (v) {
              ref.read(soundProvider).playClick();
              setState(() => _showLight = v);
            },
          ),
          SizedBox(height: S.scale(context, 16)),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: S.isTablet(context) ? 5 : 4,
                mainAxisSpacing: S.scale(context, 12),
                crossAxisSpacing: S.scale(context, 12),
                childAspectRatio: S.isTablet(context) ? 0.9 : 0.85,
              ),
              itemCount: themes.length,
              itemBuilder: (_, i) {
                final theme = themes[i];
                final selected = theme.id == currentId;
                return _CircleThemePreview(
                  t: t,
                  theme: theme,
                  selected: selected,
                  onTap: () {
                    ref.read(soundProvider).playClick();
                    ref.read(themeProvider.notifier).setTheme(theme.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final BloomTheme t;
  final bool isLight;
  final ValueChanged<bool> onToggle;
  const _TabBar({
    required this.t,
    required this.isLight,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: t.bgSurface2,
        borderRadius: BorderRadius.circular(S.scale(context, 12)),
        border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              t: t,
              label: '☀️  Light',
              selected: isLight,
              onTap: () => onToggle(true),
            ),
          ),
          Expanded(
            child: _TabButton(
              t: t,
              label: '🌚  Dark',
              selected: !isLight,
              onTap: () => onToggle(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final BloomTheme t;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.t,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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

class _CircleThemePreview extends StatelessWidget {
  final BloomTheme t;
  final BloomTheme theme;
  final bool selected;
  final VoidCallback onTap;
  const _CircleThemePreview({
    required this.t,
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              border: selected
                  ? Border.all(
                      color: t.textPrimary.withValues(alpha: 0.7),
                      width: S.scale(context, 2),
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
