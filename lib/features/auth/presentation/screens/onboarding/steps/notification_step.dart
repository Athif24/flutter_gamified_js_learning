import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../core/utils/responsive_utils.dart';

class NotificationStep extends ConsumerStatefulWidget {
  const NotificationStep({super.key});
  @override
  ConsumerState<NotificationStep> createState() => _NotificationStepState();
}

class _NotificationStepState extends ConsumerState<NotificationStep> {
  double rs(double px) => S.scale(context, px);

  bool _granted = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.getNotificationSettings();
      if (mounted) {
        setState(() {
          _granted =
              settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
          _checked = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(
            _granted
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            size: rs(56),
            color: _granted ? t.primary : t.mutedText,
          ),
          SizedBox(height: rs(16)),
          Text(
            'Notifikasi',
            style: GoogleFonts.nunito(
              fontSize: rs(22),
              fontWeight: FontWeight.w900,
              color: t.textPrimary,
            ),
          ),
          SizedBox(height: rs(8)),
          Text(
            'Dapatkan pengingat dan info terbaru dari Bloom',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: rs(13),
              color: t.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: rs(24)),
          if (_checked)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(rs(14)),
              decoration: BoxDecoration(
                color: _granted
                    ? t.success.withValues(alpha: 0.1)
                    : t.bgSurface2,
                borderRadius: BorderRadius.circular(S.scale(context, 14)),
                border: Border.all(
                  color: _granted ? t.success.withValues(alpha: 0.3) : t.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _granted
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                    color: _granted ? t.success : t.mutedText,
                    size: rs(24),
                  ),
                  SizedBox(width: rs(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _granted
                              ? 'Notifikasi Aktif'
                              : 'Notifikasi Tidak Aktif',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: rs(13),
                            color: t.textPrimary,
                          ),
                        ),
                        SizedBox(height: rs(2)),
                        Text(
                          _granted
                              ? 'Kamu akan menerima pengingat streak dan info dari Bloom'
                              : 'Aktifkan lewat Pengaturan > Aplikasi > Bloom',
                          style: GoogleFonts.nunito(
                            fontSize: rs(11),
                            color: t.mutedText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: rs(16)),
          _NotifCard(
            t: t,
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFF6B35),
            title: 'Pengingat Streak',
            desc: 'Dapatkan notifikasi setiap hari buat jaga streak belajarmu',
          ),
          SizedBox(height: rs(12)),
          _NotifCard(
            t: t,
            icon: Icons.campaign_rounded,
            iconColor: t.info,
            title: 'Pengumuman & Info',
            desc: 'Info admin tentang event, kursus baru, dan promo spesial',
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;
  const _NotifCard({
    required this.t,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    double rs(double px) => S.scale(context, px);
    return Container(
      padding: EdgeInsets.all(rs(14)),
      decoration: BoxDecoration(
        color: t.bgSurface2,
        borderRadius: BorderRadius.circular(S.scale(context, 14)),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            width: rs(42),
            height: rs(42),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(S.scale(context, 12)),
            ),
            child: Icon(icon, color: iconColor, size: rs(22)),
          ),
          SizedBox(width: rs(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: rs(13),
                    color: t.textPrimary,
                  ),
                ),
                SizedBox(height: rs(2)),
                Text(
                  desc,
                  style: GoogleFonts.nunito(
                    fontSize: rs(11),
                    color: t.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}