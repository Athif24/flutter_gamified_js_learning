import 'package:flutter/material.dart';
import '../../../../shared/themes/theme_provider.dart';

class ProfileSkeleton extends StatelessWidget {
  final BloomTheme t;
  const ProfileSkeleton({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        children: [
          _buildHeroSkeleton(),
          const SizedBox(height: 16),
          _buildStatsSkeleton(),
          const SizedBox(height: 16),
          _buildLearningSkeleton(),
          const SizedBox(height: 16),
          _buildRecentActivitySkeleton(),
          const SizedBox(height: 16),
          _buildAccountSkeleton(),
        ],
      ),
    );
  }

  Widget _buildHeroSkeleton() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: t.bgSurface2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: t.textPrimary.withValues(alpha: 0.15),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildStatsSkeleton() {
    return LayoutBuilder(
      builder: (_, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => Container(
            height: 96,
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: t.textPrimary.withValues(alpha: 0.15),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLearningSkeleton() {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isTablet = constraints.maxWidth > 600;
        if (isTablet) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: t.textPrimary.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: t.textPrimary.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: t.bgSurface2,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: t.textPrimary.withValues(alpha: 0.15),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivitySkeleton() {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isTablet = constraints.maxWidth > 600;
        if (isTablet) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: t.textPrimary.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: t.textPrimary.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: t.bgSurface2,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: t.textPrimary.withValues(alpha: 0.15),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountSkeleton() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: t.bgSurface2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: t.textPrimary.withValues(alpha: 0.15),
          width: 2,
        ),
      ),
    );
  }
}
