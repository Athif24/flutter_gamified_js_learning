import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../shared/themes/theme_provider.dart';

class SoundStep extends ConsumerStatefulWidget {
  const SoundStep({super.key});
  @override
  ConsumerState<SoundStep> createState() => _SoundStepState();
}

class _SoundStepState extends ConsumerState<SoundStep> {
  final _player = AudioPlayer();
  bool _muted = false;
  double _volume = 0.7;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _muted = prefs.getBool('sound_muted') ?? false;
        _volume = prefs.getDouble('sound_volume') ?? 0.7;
      });
    }
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_muted', _muted);
    await prefs.setDouble('sound_volume', _volume);
  }

  Future<void> _preview(String asset) async {
    if (_muted) return;
    await _player.setVolume(_volume);
    await _player.play(AssetSource(asset));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(
            _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            size: rs(56),
            color: _muted ? t.mutedText : t.primary,
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
              borderRadius: BorderRadius.circular(16),
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
                      onTap: () => setState(() {
                        _muted = !_muted;
                        _savePrefs();
                      }),
                      child: Container(
                        width: rs(48),
                        height: rs(26),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: _muted ? t.border : t.primary,
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: _muted
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
                        value: _volume,
                        min: 0,
                        max: 1,
                        activeColor: t.primary,
                        inactiveColor: t.border,
                        onChanged: _muted
                            ? null
                            : (v) {
                                setState(() => _volume = v);
                                _savePrefs();
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
                onTap: () => _preview('sounds/correct.wav'),
              ),
              SizedBox(width: rs(16)),
              _PreviewButton(
                t: t,
                label: 'Reward',
                color: t.warning,
                onTap: () => _preview('sounds/reward.wav'),
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
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(20), vertical: rs(10)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: t.textPrimary, width: 2),
          boxShadow: [
            BoxShadow(
              color: t.textPrimary,
              offset: const Offset(2, 2),
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