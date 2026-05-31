import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/services/sound_service.dart';

class ProfileNotificationSection extends ConsumerStatefulWidget {
  final BloomTheme t;

  const ProfileNotificationSection({super.key, required this.t});

  @override
  ConsumerState<ProfileNotificationSection> createState() =>
      ProfileNotificationSectionState();
}

class ProfileNotificationSectionState
    extends ConsumerState<ProfileNotificationSection> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotifPref();
  }

  Future<void> _loadNotifPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    if (mounted) setState(() => _notificationsEnabled = value);

    final api = ref.read(apiClientProvider);
    try {
      if (value) {
        await FcmService.registerToken(api);
      } else {
        await FcmService.unregisterToken(api);
      }
    } catch (e) {
      debugPrint('[_toggleNotifications] $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final sound = ref.watch(soundProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(S.scale(context, 20)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(S.scale(context, 24)),
        border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
        boxShadow: [
          BoxShadow(
            color: t.textPrimary,
            offset: Offset(S.scale(context, 3), S.scale(context, 3)),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(child: Icon(Icons.notifications_rounded, color: t.accent, size: S.scale(context, 20))),
              SizedBox(width: S.scale(context, 8)),
              Text(
                'Notifikasi',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: S.font(context, 16),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 16)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(S.scale(context, 12)),
            decoration: BoxDecoration(
              color: t.bgSurface2.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(S.scale(context, 16)),
              border: Border.all(
                color: t.textPrimary.withValues(alpha: 0.15),
                width: S.scale(context, 2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: S.scale(context, 40),
                  height: S.scale(context, 40),
                  decoration: BoxDecoration(
                    color: t.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(S.scale(context, 12)),
                    border: Border.all(
                      color: t.textPrimary.withValues(alpha: 0.35),
                      width: S.scale(context, 1),
                    ),
                  ),
                  child: ExcludeSemantics(child: Icon(
                    Icons.notifications_outlined,
                    color: t.primary,
                    size: S.scale(context, 20),
                  )),
                ),
                SizedBox(width: S.scale(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifikasi',
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: S.font(context, 14),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Terima notifikasi belajar',
                        style: GoogleFonts.nunito(
                          color: t.textHint,
                          fontSize: S.font(context, 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return t.primary;
                    return t.textHint;
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: S.scale(context, 12)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(S.scale(context, 12)),
            decoration: BoxDecoration(
              color: t.bgSurface2.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(S.scale(context, 16)),
              border: Border.all(
                color: t.textPrimary.withValues(alpha: 0.15),
                width: S.scale(context, 2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: S.scale(context, 40),
                      height: S.scale(context, 40),
                      decoration: BoxDecoration(
                        color: t.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(S.scale(context, 12)),
                        border: Border.all(
                          color: t.textPrimary.withValues(alpha: 0.35),
                          width: S.scale(context, 1),
                        ),
                      ),
                      child: ExcludeSemantics(child: Icon(
                        sound.isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: t.primary,
                        size: S.scale(context, 20),
                      )),
                    ),
                    SizedBox(width: S.scale(context, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suara Efek',
                            style: GoogleFonts.nunito(
                              color: t.textPrimary,
                              fontSize: S.font(context, 14),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Feedback suara aplikasi',
                            style: GoogleFonts.nunito(
                              color: t.textHint,
                              fontSize: S.font(context, 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: !sound.isMuted,
                      onChanged: (v) {
                        if (sound.isMuted) {
                          ref.read(soundProvider).playClick();
                        }
                        ref.read(soundProvider).setMuted(!v);
                      },
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return t.primary;
                        }
                        return t.textHint;
                      }),
                    ),
                  ],
                ),
                if (!sound.isMuted) ...[
                  SizedBox(height: S.scale(context, 8)),
                  Row(
                    children: [
                      ExcludeSemantics(child: Icon(Icons.volume_down_rounded,
                          color: t.mutedText, size: S.scale(context, 16))),
                      Expanded(
                        child: Slider(
                          value: sound.volume,
                          min: 0,
                          max: 1,
                          activeColor: t.primary,
                          inactiveColor: t.border,
                          onChanged: (v) {
                            ref.read(soundProvider).setVolume(v);
                          },
                        ),
                      ),
                      ExcludeSemantics(child: Icon(Icons.volume_up_rounded,
                          color: t.mutedText, size: S.scale(context, 16))),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}
