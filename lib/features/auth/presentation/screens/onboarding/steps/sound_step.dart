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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(_muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              size: 56, color: _muted ? t.mutedText : t.primary),
          const SizedBox(height: 16),
          Text('Atur Suara',
              style: GoogleFonts.nunito(
                  fontSize: 22, fontWeight: FontWeight.w900, color: t.textPrimary)),
          const SizedBox(height: 8),
          Text('Dengar feedback suara saat jawab quiz',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 13, color: t.mutedText, fontWeight: FontWeight.w500)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active_rounded,
                        color: t.primary, size: 20),
                    const SizedBox(width: 12),
                    Text('Suara Efek',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 14, color: t.textPrimary)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() {
                        _muted = !_muted;
                        _savePrefs();
                      }),
                      child: Container(
                        width: 48, height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: _muted ? t.border : t.primary,
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: _muted ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            width: 22, height: 22,
                            margin: const EdgeInsets.all(2),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.volume_down_rounded, color: t.mutedText, size: 18),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        min: 0, max: 1,
                        activeColor: t.primary,
                        inactiveColor: t.border,
                        onChanged: _muted ? null : (v) {
                          setState(() => _volume = v);
                          _savePrefs();
                        },
                      ),
                    ),
                    Icon(Icons.volume_up_rounded, color: t.mutedText, size: 18),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PreviewButton(
                t: t,
                label: 'Benar',
                color: t.success,
                onTap: () => _preview('sounds/correct.wav'),
              ),
              const SizedBox(width: 16),
              _PreviewButton(
                t: t,
                label: 'Reward',
                color: t.warning,
                onTap: () => _preview('sounds/reward.wav'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Tap tombol di atas untuk preview suara',
              style: GoogleFonts.nunito(
                  fontSize: 11, color: t.mutedText, fontWeight: FontWeight.w500)),
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
  const _PreviewButton({required this.t, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: t.textPrimary, width: 2),
          boxShadow: [
            BoxShadow(color: t.textPrimary, offset: const Offset(2, 2), blurRadius: 0),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, color: t.bgPrimary, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 12, color: t.bgPrimary)),
          ],
        ),
      ),
    );
  }
}
