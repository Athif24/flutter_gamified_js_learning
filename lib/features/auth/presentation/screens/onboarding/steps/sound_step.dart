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
    double rs(double px) => S.scale(context, px);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(
            sound.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            size: rs(56),
            color: sound.isMuted ? t.mutedText : t.primary,
          ),
          SizedBox(height: rs(16)),
          Text(
            'Atur Suara',
            style: GoogleFonts.nunito(
              fontSize: rs(22),
              fontWeight: FontWeight.w900,
              color: t.textPrimary,
            ),
          ),
          SizedBox(height: rs(8)),
          Text(
            'Dengar feedback suara saat jawab quiz',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: rs(13),
              color: t.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: rs(32)),
          Container(
            padding: EdgeInsets.all(rs(20)),
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(S.scale(context, 16)),
              border: Border.all(color: t.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      color: t.primary,
                      size: rs(20),
                    ),
                    SizedBox(width: rs(12)),
                    Text(
                      'Suara Efek',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: rs(14),
                        color: t.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        final s = ref.read(soundProvider);
                        if (s.isMuted) {
                          s.playClick();
                        }
                        s.setMuted(!s.isMuted);
                      },
                      child: Container(
                        width: rs(48),
                        height: rs(26),
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
                            width: rs(22),
                            height: rs(22),
                            margin: EdgeInsets.all(rs(2)),
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
                SizedBox(height: rs(16)),
                Row(
                  children: [
                    Icon(
                      Icons.volume_down_rounded,
                      color: t.mutedText,
                      size: rs(18),
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
                    Icon(
                      Icons.volume_up_rounded,
                      color: t.mutedText,
                      size: rs(18),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: rs(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PreviewButton(
                t: t,
                label: 'Benar',
                color: t.success,
                onTap: () => ref.read(soundProvider).playCorrect(),
              ),
              SizedBox(width: rs(16)),
              _PreviewButton(
                t: t,
                label: 'Reward',
                color: t.warning,
                onTap: () => ref.read(soundProvider).playReward(),
              ),
            ],
          ),
          SizedBox(height: rs(8)),
          Text(
            'Tap tombol di atas untuk preview suara',
            style: GoogleFonts.nunito(
              fontSize: rs(11),
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
    double rs(double px) => S.scale(context, px);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(20), vertical: rs(10)),
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
            Icon(Icons.play_arrow_rounded, color: t.bgPrimary, size: rs(18)),
            SizedBox(width: rs(6)),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: rs(12),
                color: t.bgPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
