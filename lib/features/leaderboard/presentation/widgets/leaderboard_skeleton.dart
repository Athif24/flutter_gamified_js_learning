import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';

class LeaderboardSkeleton extends StatelessWidget {
  final BloomTheme t;
  const LeaderboardSkeleton({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    double rs(double px) => S.scale(context, px);
    final t = this.t;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rs(20), rs(20), rs(20), rs(32)),
      child:
          Column(
            children: [
              _buildHeaderSkeleton(rs),
              SizedBox(height: rs(16)),
              _buildUserCardSkeleton(rs),
              SizedBox(height: rs(16)),
              _buildPodiumSkeleton(rs),
              SizedBox(height: rs(16)),
              _buildSearchSkeleton(rs),
              SizedBox(height: rs(16)),
              _buildTableSkeleton(rs),
              SizedBox(height: rs(16)),
              _buildFooterSkeleton(rs),
            ],
          ).animate().shimmer(
            duration: Duration(milliseconds: 1500),
            color: t.bgSurface2,
          ),
    );
  }

  Widget _buildHeaderSkeleton(double Function(double) rs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: rs(32),
              height: rs(32),
              decoration: BoxDecoration(
                color: t.bgSurface2,
                borderRadius: BorderRadius.circular(rs(8)),
              ),
            ),
            SizedBox(width: rs(8)),
            Container(
              width: rs(180),
              height: rs(28),
              decoration: BoxDecoration(
                color: t.bgSurface2,
                borderRadius: BorderRadius.circular(rs(8)),
              ),
            ),
          ],
        ),
        SizedBox(height: rs(8)),
        Container(
          width: rs(280),
          height: rs(14),
          decoration: BoxDecoration(
            color: t.bgSurface2,
            borderRadius: BorderRadius.circular(rs(6)),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCardSkeleton(double Function(double) rs) {
    return Container(
      padding: EdgeInsets.all(rs(24)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(rs(24)),
        border: Border.all(color: t.textPrimary, width: rs(2)),
      ),
      child: Column(
        children: [
          Container(
            width: rs(120),
            height: rs(18),
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(rs(6)),
            ),
          ),
          SizedBox(height: rs(16)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: rs(60),
                      height: rs(10),
                      color: t.bgSurface2,
                    ),
                    SizedBox(height: rs(8)),
                    Container(
                      width: rs(80),
                      height: rs(28),
                      color: t.bgSurface2,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: rs(60),
                      height: rs(10),
                      color: t.bgSurface2,
                    ),
                    SizedBox(height: rs(8)),
                    Container(
                      width: rs(100),
                      height: rs(28),
                      color: t.bgSurface2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSkeleton(double Function(double) rs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: rs(22),
              height: rs(22),
              decoration: BoxDecoration(
                color: t.bgSurface2,
                borderRadius: BorderRadius.circular(rs(4)),
              ),
            ),
            SizedBox(width: rs(8)),
            Container(width: rs(160), height: rs(18), color: t.bgSurface2),
          ],
        ),
        SizedBox(height: rs(16)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _podiumBlock(rs, height: rs(48))),
            SizedBox(width: rs(8)),
            Expanded(child: _podiumBlock(rs, height: rs(80))),
            SizedBox(width: rs(8)),
            Expanded(child: _podiumBlock(rs, height: rs(40))),
          ],
        ),
      ],
    );
  }

  Widget _podiumBlock(double Function(double) rs, {required double height}) {
    return Column(
      children: [
        Container(
          width: rs(44),
          height: rs(44),
          decoration: BoxDecoration(
            color: t.bgSurface2,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: rs(8)),
        Container(width: rs(50), height: rs(10), color: t.bgSurface2),
        SizedBox(height: rs(4)),
        Container(width: rs(30), height: rs(10), color: t.bgSurface2),
        SizedBox(height: rs(8)),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: t.bgSurface2,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(rs(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSkeleton(double Function(double) rs) {
    return Container(
      padding: EdgeInsets.all(rs(16)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(rs(18)),
        border: Border.all(color: t.textPrimary, width: rs(2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: rs(80), height: rs(12), color: t.bgSurface2),
          SizedBox(height: rs(8)),
          Container(
            height: rs(40),
            decoration: BoxDecoration(
              color: t.bgPrimary,
              borderRadius: BorderRadius.circular(rs(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSkeleton(double Function(double) rs) {
    return Container(
      padding: EdgeInsets.all(rs(16)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(rs(24)),
        border: Border.all(color: t.textPrimary, width: rs(2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: rs(28),
                height: rs(28),
                decoration: BoxDecoration(
                  color: t.bgSurface2,
                  borderRadius: BorderRadius.circular(rs(6)),
                ),
              ),
              SizedBox(width: rs(8)),
              Container(width: rs(120), height: rs(20), color: t.bgSurface2),
            ],
          ),
          SizedBox(height: rs(16)),
          ...List.generate(
            5,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: rs(8)),
              child: Row(
                children: [
                  Container(width: rs(32), height: rs(24), color: t.bgSurface2),
                  SizedBox(width: rs(12)),
                  Container(width: rs(32), height: rs(32), color: t.bgSurface2),
                  SizedBox(width: rs(8)),
                  Expanded(
                    child: Container(height: rs(14), color: t.bgSurface2),
                  ),
                  SizedBox(width: rs(12)),
                  Container(width: rs(60), height: rs(14), color: t.bgSurface2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSkeleton(double Function(double) rs) {
    return Container(
      padding: EdgeInsets.all(rs(16)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(rs(18)),
        border: Border.all(color: t.textPrimary, width: rs(2)),
      ),
      child: Row(
        children: [
          Expanded(child: _footerItem(rs)),
          Expanded(child: _footerItem(rs)),
          Expanded(child: _footerItem(rs)),
        ],
      ),
    );
  }

  Widget _footerItem(double Function(double) rs) {
    return Column(
      children: [
        Container(width: rs(60), height: rs(10), color: t.bgSurface2),
        SizedBox(height: rs(8)),
        Container(width: rs(40), height: rs(20), color: t.bgSurface2),
      ],
    );
  }
}