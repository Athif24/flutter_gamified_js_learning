import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/theme_provider.dart';
import '../../core/utils/responsive_utils.dart';
import '../services/sound_service.dart';

class VolumeButton extends ConsumerWidget {
  final BloomTheme t;
  const VolumeButton({super.key, required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sound = ref.watch(soundProvider);
    final muted = sound.isMuted;
    return Semantics(
      button: true,
      label: muted ? 'Aktifkan suara' : 'Nonaktifkan suara',
      child: GestureDetector(
        onTap: () {
          _showVolumePopover(context, t);
        },
        child: Container(
          width: S.scale(context, 34),
          height: S.scale(context, 34),
          decoration: BoxDecoration(
            color: t.bgSurface2,
            shape: BoxShape.circle,
            border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
          ),
          child: Icon(
            muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            color: muted ? t.mutedText : t.primary,
            size: S.scale(context, 15),
          ),
        ),
      ),
    );
  }
}

void _showVolumePopover(BuildContext context, BloomTheme t) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(S.scale(context, 20))),
    ),
    builder: (ctx) {
      return Consumer(
        builder: (_, ref, __) {
          final s = ref.watch(soundProvider);
          return Padding(
            padding: EdgeInsets.fromLTRB(
              S.scale(context, 24),
              S.scale(context, 8),
              S.scale(context, 24),
              S.scale(context, 32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: S.scale(context, 40),
                  height: S.scale(context, 4),
                  decoration: BoxDecoration(
                    color: t.border,
                    borderRadius: BorderRadius.circular(S.scale(context, 2)),
                  ),
                ),
                SizedBox(height: S.scale(context, 20)),
                Row(
                  children: [
                    ExcludeSemantics(child: Icon(Icons.volume_up_rounded, color: t.primary, size: S.scale(context, 20))),
                    SizedBox(width: S.scale(context, 12)),
                    Text(
                      'Volume Suara',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: S.font(context, 14),
                        color: t.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        try {
                          s.setMuted(!s.isMuted);
                        } catch (_) {
                          debugPrint('[Volume] setMuted gagal');
                        }
                      },
                      child: Container(
                        width: S.scale(context, 48),
                        height: S.scale(context, 26),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(S.scale(context, 13)),
                          color: s.isMuted ? t.border : t.primary,
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: s.isMuted
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
                SizedBox(height: S.scale(context, 12)),
                Row(
                  children: [
                    ExcludeSemantics(child: Icon(Icons.volume_down_rounded, color: t.mutedText, size: S.scale(context, 18))),
                    Expanded(
                      child: Slider(
                        value: s.volume,
                        min: 0,
                        max: 1,
                        activeColor: t.primary,
                        inactiveColor: t.border,
                        onChanged: s.isMuted ? null : (v) {
                          try {
                            s.setVolume(v);
                          } catch (_) {
                            debugPrint('[Volume] setVolume gagal');
                          }
                        },
                      ),
                    ),
                    ExcludeSemantics(child: Icon(Icons.volume_up_rounded, color: t.mutedText, size: S.scale(context, 18))),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
