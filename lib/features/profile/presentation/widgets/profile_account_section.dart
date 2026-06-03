import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';

class ProfileAccountSection extends ConsumerStatefulWidget {
  final BloomTheme t;
  final String email;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  const ProfileAccountSection({
    super.key,
    required this.t,
    required this.email,
    required this.onChangePassword,
    required this.onLogout,
  });

  @override
  ConsumerState<ProfileAccountSection> createState() =>
      ProfileAccountSectionState();
}

class ProfileAccountSectionState extends ConsumerState<ProfileAccountSection> {
  @override
  Widget build(BuildContext context) {
    final t = widget.t;
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
              ExcludeSemantics(child: Icon(Icons.shield_rounded, color: t.success, size: S.scale(context, 20))),
              SizedBox(width: S.scale(context, 8)),
              Text(
                'Akun & Keamanan',
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
                    Icons.email_rounded,
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
                        'EMAIL LOGIN',
                        style: GoogleFonts.nunito(
                          color: t.textSecondary.withValues(alpha: 0.55),
                          fontSize: S.font(context, 11),
                          fontWeight: FontWeight.w700,
                          letterSpacing: S.scale(context, 0.5),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.email,
                          style: GoogleFonts.nunito(
                            color: t.textPrimary,
                            fontSize: S.font(context, 14),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: S.scale(context, 12)),
          Column(
            children: [
              Semantics(
                button: true,
                label: 'Ubah password',
                child: SizedBox(
                  width: double.infinity,
                  child: Bounceable(
                    onTap: () {
                      widget.onChangePassword();
                    },
                  child: Container(
                    constraints: BoxConstraints(minHeight: S.scale(context, 48)),
                    padding: EdgeInsets.symmetric(vertical: S.scale(context, 12)),
                    decoration: BoxDecoration(
                      color: t.primary,
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
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: t.primaryContent,
                            size: S.scale(context, 16),
                          ),
                          SizedBox(width: S.scale(context, 6)),
                          Text(
                            'Ubah Password',
                            style: GoogleFonts.nunito(
                              color: t.primaryContent,
                              fontSize: S.font(context, 14),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: S.scale(context, 12)),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: 'Keluar dari aplikasi',
                  child: Bounceable(
                    onTap: () {
                      widget.onLogout();
                    },
                    child: Container(
                    constraints: BoxConstraints(minHeight: S.scale(context, 48)),
                    padding: EdgeInsets.symmetric(vertical: S.scale(context, 12)),
                    decoration: BoxDecoration(
                      color: t.error,
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
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: t.bgPrimary,
                            size: S.scale(context, 16),
                          ),
                          SizedBox(width: S.scale(context, 6)),
                            Text(
                              'Keluar',
                              style: GoogleFonts.nunito(
                                color: t.bgPrimary,
                                fontSize: S.font(context, 14),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 12)),
          Text(
            'Untuk keamanan, ganti password secara berkala dan pastikan tidak '
            'menggunakan password yang sama dengan akun lain.',
            style: GoogleFonts.nunito(color: t.textHint, fontSize: S.font(context, 12)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}
