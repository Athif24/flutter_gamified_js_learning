import 'package:flutter/material.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../core/utils/responsive_utils.dart';

class ProfileSkeleton extends StatelessWidget {
  final BloomTheme t;
  const ProfileSkeleton({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(S.scale(context, 20), S.scale(context, 20), S.scale(context, 20), S.scale(context, 40)),
      child: Column(
        children: [
          _buildHeroSkeleton(context),
          SizedBox(height: S.scale(context, 16)),
          _buildStatsSkeleton(context),
          SizedBox(height: S.scale(context, 16)),
          _buildLearningSkeleton(context),
          SizedBox(height: S.scale(context, 16)),
          _buildRecentActivitySkeleton(context),
          SizedBox(height: S.scale(context, 16)),
          _buildAccountSkeleton(context),
        ],
      ),
    );
  }

  Widget _buildHeroSkeleton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: S.scale(context, 180),
      decoration: BoxDecoration(
        color: t.bgSurface2,
        borderRadius: BorderRadius.circular(S.scale(context, 24)),
        border: Border.all(
          color: t.textPrimary.withValues(alpha: 0.15),
          width: S.scale(context, 2),
        ),
      ),
    );
  }

  Widget _buildStatsSkeleton(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: S.scale(context, 12),
            mainAxisSpacing: S.scale(context, 12),
            childAspectRatio: 1.1,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => Container(
            height: S.scale(context, 96),
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(S.scale(context, 16)),
              border: Border.all(
                color: t.textPrimary.withValues(alpha: 0.15),
                width: S.scale(context, 2),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLearningSkeleton(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isTablet = constraints.maxWidth > 600;
        if (isTablet) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: S.scale(context, 200),
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(S.scale(context, 24)),
                    border: Border.all(
                      color: t.textPrimary.withValues(alpha: 0.15),
                      width: S.scale(context, 2),
                    ),
                  ),
                ),
              ),
              SizedBox(width: S.scale(context, 16)),
              Expanded(
                child: Container(
                  height: S.scale(context, 200),
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(S.scale(context, 24)),
                    border: Border.all(
                      color: t.textPrimary.withValues(alpha: 0.15),
                      width: S.scale(context, 2),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Container(
          width: double.infinity,
          height: S.scale(context, 200),
          decoration: BoxDecoration(
            color: t.bgSurface2,
            borderRadius: BorderRadius.circular(S.scale(context, 24)),
            border: Border.all(
              color: t.textPrimary.withValues(alpha: 0.15),
              width: S.scale(context, 2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivitySkeleton(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isTablet = constraints.maxWidth > 600;
        if (isTablet) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: S.scale(context, 180),
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(S.scale(context, 24)),
                    border: Border.all(
                      color: t.textPrimary.withValues(alpha: 0.15),
                      width: S.scale(context, 2),
                    ),
                  ),
                ),
              ),
              SizedBox(width: S.scale(context, 16)),
              Expanded(
                child: Container(
                  height: S.scale(context, 180),
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(S.scale(context, 24)),
                    border: Border.all(
                      color: t.textPrimary.withValues(alpha: 0.15),
                      width: S.scale(context, 2),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Container(
          width: double.infinity,
          height: S.scale(context, 180),
          decoration: BoxDecoration(
            color: t.bgSurface2,
            borderRadius: BorderRadius.circular(S.scale(context, 24)),
            border: Border.all(
              color: t.textPrimary.withValues(alpha: 0.15),
              width: S.scale(context, 2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountSkeleton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: S.scale(context, 120),
      decoration: BoxDecoration(
        color: t.bgSurface2,
        borderRadius: BorderRadius.circular(S.scale(context, 24)),
        border: Border.all(
          color: t.textPrimary.withValues(alpha: 0.15),
          width: S.scale(context, 2),
        ),
      ),
    );
  }
}
