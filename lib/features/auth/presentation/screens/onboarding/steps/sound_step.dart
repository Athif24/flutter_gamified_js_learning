import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/services/sound_service.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../core/utils/responsive_utils.dart';

class SoundStep extends ConsumerStatefulWidget {
  const SoundStep({super.key});
  @override
  ConsumerState<SoundStep> createState() => _SoundStepState();
}

class _SoundStepState extends ConsumerState<SoundStep> {
  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final sound = ref.watch(soundProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: S.scale(context, 24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          ExcludeSemantics(
            child: Icon(
              sound.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              size: S.scale(context, 56),
              color: sound.isMuted ? t.mutedText : t.primary,
            ),
          ),
          SizedBox(height: S.scale(context, 16)),
          Text(
            'Atur Suara',
            style: GoogleFonts.nunito(
              fontSize: S.font(context, 22),
              fontWeight: FontWeight.w900,
              color: t.textPrimary,
            ),
          ),
          SizedBox(height: S.scale(context, 8)),
          Text(
            'Dengar feedback suara saat jawab quiz',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: S.font(context, 13),
              color: t.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: S.scale(context, 32)),
          Container(
            padding: EdgeInsets.all(S.scale(context, 20)),
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(S.scale(context, 16)),
              border: Border.all(color: t.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: t.primary,
                        size: S.scale(context, 20),
                      ),
                    ),
                    SizedBox(width: S.scale(context, 12)),
                    Text(
                      'Suara Efek',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: S.font(context, 14),
                        color: t.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        final s = ref.read(soundProvider);
                        if (s.isMuted) {
                        }
                        s.setMuted(!s.isMuted);
                      },
                      child: Container(
                        width: S.scale(context, 48),
                        height: S.scale(context, 26),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(S.scale(context, 13)),
                          color: sound.isMuted ? t.border : t.primary,
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: sound.isMuted
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            width: S.scale(context, 22),
                            height: S.scale(context, 22),
                            margin: EdgeInsets.all(S.scale(context, 2)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: t.bgPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: S.scale(context, 16)),
                Row(
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.volume_down_rounded,
                        color: t.mutedText,
                        size: S.scale(context, 18),
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: sound.volume,
                        min: 0,
                        max: 1,
                        activeColor: t.primary,
                        inactiveColor: t.border,
                        onChanged: sound.isMuted
                            ? null
                            : (v) {
                                ref.read(soundProvider).setVolume(v);
                              },
                      ),
                    ),
                    ExcludeSemantics(
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: t.mutedText,
                        size: S.scale(context, 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: S.scale(context, 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PreviewButton(
                t: t,
                label: 'Benar',
                color: t.success,
                onTap: () => ref.read(soundProvider).playCorrect(),
              ),
              SizedBox(width: S.scale(context, 16)),
              _PreviewButton(
                t: t,
                label: 'Reward',
                color: t.warning,
                onTap: () => ref.read(soundProvider).playReward(),
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 8)),
          Text(
            'Tap tombol di atas untuk preview suara',
            style: GoogleFonts.nunito(
              fontSize: S.font(context, 11),
              color: t.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final BloomTheme t;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PreviewButton({
    required this.t,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: S.scale(context, 20), vertical: S.scale(context, 10)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(S.scale(context, 10)),
          border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
          boxShadow: [
            BoxShadow(
              color: t.textPrimary,
              offset: Offset(S.scale(context, 2), S.scale(context, 2)),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, color: t.bgPrimary, size: S.scale(context, 18)),
            SizedBox(width: S.scale(context, 6)),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: S.font(context, 12),
                color: t.bgPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
