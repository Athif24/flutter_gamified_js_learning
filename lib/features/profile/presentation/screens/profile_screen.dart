import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../data/models/profile_model.dart';
import '../widgets/profile_skeleton.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_hero_card.dart';
import '../widgets/profile_stats_grid.dart';
import '../widgets/profile_learning_summary.dart';
import '../widgets/profile_recent_activity.dart';
import '../widgets/profile_account_section.dart';
import '../widgets/profile_dialogs.dart';
import '../widgets/profile_notification_section.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProfileModel? _cachedProfile;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildContent(ProfileModel profile, BloomTheme t) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(profileProvider);
        await ref.read(profileProvider.future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          S.scale(context, 20),
          S.scale(context, 20),
          S.scale(context, 20),
          S.scale(context, 40),
        ),
        child: Column(
          children: [
            ProfileHeroCard(
              t: t,
              profile: profile,
              ref: ref,
              onEditProfile: () => showEditProfile(context, ref, t, profile),
            ),
            SizedBox(height: S.scale(context, 16)),
            ProfileStatsGrid(t: t, profile: profile),
            SizedBox(height: S.scale(context, 16)),
            LayoutBuilder(
              builder: (_, constraints) {
                final isTablet = constraints.maxWidth > 600;
                if (isTablet) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ProfileLearningSummary(t: t, profile: profile),
                      ),
                      SizedBox(width: S.scale(context, 16)),
                      Expanded(
                        child: ProfileRecentActivity(
                          t: t,
                          entries: profile.recentXp,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    ProfileLearningSummary(t: t, profile: profile),
                    SizedBox(height: S.scale(context, 16)),
                    ProfileRecentActivity(t: t, entries: profile.recentXp),
                  ],
                );
              },
            ),
            SizedBox(height: S.scale(context, 16)),
            ProfileNotificationSection(t: t),
            SizedBox(height: S.scale(context, 16)),
            ProfileAccountSection(
              t: t,
              email: profile.email,
              onChangePassword: () => showChangePassword(context, ref, t),
              onLogout: () => showLogoutConfirm(context, ref, t),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listenManual<int>(navIndexProvider, (prev, next) {
      if (prev != null && prev != 4 && next == 4) {
        ref.invalidate(profileProvider);
      }
    });

    final t = ref.watch(currentThemeProvider);
    final profileAsync = ref.watch(profileProvider);

    profileAsync.whenOrNull(data: (p) => _cachedProfile = p);
    final profile = _cachedProfile;

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: profile != null
                  ? _buildContent(profile, t)
                  : profileAsync.when(
                      loading: () => ProfileSkeleton(t: t),
                      error: (e, _) => ErrorBody(
                        t: t,
                        icon: iconForError(e),
                        title: AppStrings.errLoadProfile,
                        message: sanitizeErrorMessage(e),
                        onRetry: () => ref.invalidate(profileProvider),
                      ),
                      data: (p) => _buildContent(p, t),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}