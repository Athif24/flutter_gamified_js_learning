import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/services/sound_service.dart';
import '../../data/models/profile_model.dart';
import 'theme_picker_sheet.dart';

class ProfileHeroCard extends StatelessWidget {
  final BloomTheme t;
  final ProfileModel profile;
  final WidgetRef ref;
  final VoidCallback onEditProfile;

  const ProfileHeroCard({
    super.key,
    required this.t,
    required this.profile,
    required this.ref,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final initials = profile.initials;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(S.scale(context, 24)),
          decoration: BoxDecoration(
            color: t.primary,
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
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t.textPrimary, width: S.scale(context, 3)),
                ),
                child: _ProfileAvatar(
                  avatarUrl: profile.avatar,
                  initials: initials,
                  radius: S.scale(context, 40).roundToDouble(),
                  bgColor: t.bgSurface.withValues(alpha: 0.3),
                  textColor: t.primary,
                  fontSize: S.font(context, 28),
                ),
              ),
              SizedBox(height: S.scale(context, 20)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  profile.name,
                  style: GoogleFonts.nunito(
                    color: t.primaryContent,
                    fontSize: S.font(context, 24),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: S.scale(context, 6)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  profile.email,
                  style: GoogleFonts.nunito(
                    color: t.primaryContent.withValues(alpha: 0.8),
                    fontSize: S.font(context, 14),
                  ),
                ),
              ),
              SizedBox(height: S.scale(context, 6)),
              Wrap(
                spacing: S.scale(context, 8),
                runSpacing: S.scale(context, 6),
                children: [
                  if (profile.levelTitle.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: S.scale(context, 12),
                        vertical: S.scale(context, 4),
                      ),
                      decoration: BoxDecoration(
                        color: t.bgSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(S.scale(context, 50)),
                      ),
                      child: Text(
                        profile.levelTitle,
                        style: GoogleFonts.nunito(
                          color: t.primaryContent,
                          fontSize: S.font(context, 12),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: S.scale(context, 12),
                      vertical: S.scale(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: t.bgSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(S.scale(context, 50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ExcludeSemantics(child: Icon(
                          Icons.calendar_today_rounded,
                          size: S.scale(context, 12),
                          color: t.primaryContent.withValues(alpha: 0.8),
                        )),
                        SizedBox(width: S.scale(context, 4)),
                        Text(
                          'Bergabung ${profile.daysSinceJoined} hari lalu',
                          style: GoogleFonts.nunito(
                            color: t.primaryContent.withValues(alpha: 0.8),
                            fontSize: S.font(context, 12),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: S.scale(context, 20)),
              Semantics(
                button: true,
                label: 'Edit profil',
                child: Bounceable(
                onTap: () {
                  ref.read(soundProvider).playClick();
                  onEditProfile();
                },
                hitTestBehavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: S.scale(context, 16),
                    vertical: S.scale(context, 8),
                  ),
                  decoration: BoxDecoration(
                    color: t.secondary,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: t.secondaryContent,
                        size: S.scale(context, 16),
                      ),
                      SizedBox(width: S.scale(context, 6)),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.nunito(
                          color: t.secondaryContent,
                          fontSize: S.font(context, 14),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -S.scale(context, 48),
          top: -S.scale(context, 48),
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: S.scale(context, 48), sigmaY: S.scale(context, 48)),
              child: Container(
                width: S.scale(context, 192),
                height: S.scale(context, 192),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.bgSurface.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: -S.scale(context, 32),
          bottom: -S.scale(context, 32),
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: S.scale(context, 24), sigmaY: S.scale(context, 24)),
              child: Container(
                width: S.scale(context, 128),
                height: S.scale(context, 128),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.textHint.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: S.scale(context, 12),
          top: S.scale(context, 12),
          child: Semantics(
            button: true,
            label: 'Pilih tema',
            child: Bounceable(
            onTap: () {
              ref.read(soundProvider).playClick();
              showThemePicker(context, ref);
            },
            hitTestBehavior: HitTestBehavior.opaque,
            child: Container(
              width: S.scale(context, 36),
              height: S.scale(context, 36),
              decoration: BoxDecoration(
                color: t.bgSurface.withValues(alpha: 0.7),
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
              child: Icon(
                Icons.palette_rounded,
                color: t.textPrimary,
                size: S.scale(context, 18),
              ),
            ),
          ),
          ),
        ),
      ],
    ).animate().fadeIn();
  }
}

class _ProfileAvatar extends StatefulWidget {
  final String? avatarUrl;
  final String initials;
  final double radius;
  final Color bgColor;
  final Color textColor;
  final double fontSize;

  const _ProfileAvatar({
    required this.avatarUrl,
    required this.initials,
    required this.radius,
    required this.bgColor,
    required this.textColor,
    required this.fontSize,
  });

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.bgColor,
      backgroundImage: widget.avatarUrl != null && !_hasError
          ? CachedNetworkImageProvider(widget.avatarUrl!)
          : null,
      onBackgroundImageError: widget.avatarUrl != null && !_hasError
          ? (_, __) { if (mounted) setState(() => _hasError = true); }
          : null,
      child: widget.avatarUrl == null || _hasError
          ? Text(
              widget.initials,
              style: GoogleFonts.nunito(
                color: widget.textColor,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w900,
              ),
            )
          : null,
    );
  }
}
