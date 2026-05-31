import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/game_3d_button.dart';
import '../../../../core/utils/accessibility.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/models/reward_pool_model.dart';

class MysteryBoxCard extends StatelessWidget {
  final RewardPool pool;
  final int balance;
  final bool isPending;
  final VoidCallback onBuy;
  final BloomTheme t;

  const MysteryBoxCard({
    super.key,
    required this.pool,
    required this.balance,
    this.isPending = false,
    required this.onBuy,
    required this.t,
  });

  bool get canAfford => balance >= pool.jewelCost;

  String get _icon {
    if (pool.icon != null && pool.icon!.isNotEmpty) return pool.icon!;
    if (pool.name.toLowerCase().contains('legendary')) return '👑';
    if (pool.name.toLowerCase().contains('premium')) return '🎀';
    return '🎁';
  }

  Color? get _bgColor {
    final c = pool.color;
    if (c == null || c.isEmpty) return null;
    try {
      return Color(int.parse(c.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgCol = _bgColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(S.scale(context, 18)),
        border: Border.all(
          color: t.textPrimary,
          width: S.scale(context, 2),
        ),
        boxShadow: [
          BoxShadow(
            color: t.textPrimary,
            offset: Offset(
              S.scale(context, 3),
              S.scale(context, 3),
            ),
            blurRadius: 0,
          ),
        ],
        gradient: bgCol != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(bgCol.withValues(alpha: 0.18), t.bgSurface),
                  Color.alphaBlend(bgCol.withValues(alpha: 0.08), t.bgSurface),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                    t.primary.withValues(alpha: 0.1),
                    t.bgSurface,
                  ),
                  Color.alphaBlend(t.info.withValues(alpha: 0.1), t.bgSurface),
                ],
              ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(S.scale(context, 16)),
        child: Stack(
          children: [
            // Shimmer overlay
            Positioned.fill(
              child:
                  Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              t.primary.withValues(alpha: 0.06),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      )
                      .animate(
                        onPlay: (controller) => a11yReduceMotion(context)
                            ? null
                            : controller.repeat(),
                      )
                      .slideX(
                        begin: -1,
                        end: 3,
                        duration: const Duration(seconds: 3),
                        curve: Curves.linear,
                      ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.fromLTRB(
                S.scale(context, 16),
                S.scale(context, 16),
                S.scale(context, 16),
                S.scale(context, 16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── GRUP ATAS ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Icon + Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                                width: S.scale(context, 40),
                                height: S.scale(context, 40),
                                decoration: BoxDecoration(
                                  color: t.bgSurface.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(
                                      S.scale(context, 10)),
                                  border: Border.all(
                                    color: t.textPrimary,
                                    width: S.scale(context, 1.5),
                                  ),
                                ),
                                child: Center(
                                  child: _icon.startsWith('http')
                                      ? CachedNetworkImage(
                                          imageUrl: _icon,
                                          width: S.scale(context, 24),
                                          height: S.scale(context, 24),
                                          fit: BoxFit.contain,
                                          placeholder: (_, __) => ExcludeSemantics(
                                            child: Icon(
                                              Icons.card_giftcard,
                                              size: S.scale(context, 24),
                                              color: t.mutedText,
                                            ),
                                          ),
                                          errorWidget: (_, __, ___) => ExcludeSemantics(
                                            child: Icon(
                                              Icons.card_giftcard,
                                              size: S.scale(context, 24),
                                              color: t.mutedText,
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          width: S.scale(context, 24),
                                          height: S.scale(context, 24),
                                          child: Center(
                                            child: Text(
                                              _icon,
                                              style: TextStyle(
                                                fontSize: S.scale(context, 20),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              )
                              .animate(
                                onPlay: (controller) =>
                                    a11yReduceMotion(context)
                                    ? null
                                    : controller.repeat(),
                              )
                              .scale(
                                begin: const Offset(1.0, 1.0),
                                end: const Offset(1.06, 1.06),
                                duration: const Duration(milliseconds: 1200),
                                curve: Curves.easeInOut,
                              )
                              .then()
                              .scale(
                                begin: const Offset(1.06, 1.06),
                                end: const Offset(1.0, 1.0),
                                duration: const Duration(milliseconds: 1200),
                                curve: Curves.easeInOut,
                              ),
                          const Spacer(),
                          // Tier badge
                          if (pool.badgeLabel != null &&
                              pool.badgeLabel!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: S.scale(context, 7),
                                vertical: S.scale(context, 2),
                              ),
                              decoration: BoxDecoration(
                                color: t.bgSurface.withValues(alpha: 0.3),
                                borderRadius:
                                    BorderRadius.circular(S.scale(context, 5)),
                                border: Border.all(
                                  color: t.textPrimary.withValues(alpha: 0.35),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  pool.badgeLabel!,
                                  style: GoogleFonts.nunito(
                                    color: t.textPrimary,
                                    fontSize: S.scale(context, 10),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: S.scale(context, 8)),
                      // Name + description
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          pool.name,
                          style: GoogleFonts.nunito(
                            color: t.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: S.scale(context, 14),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: S.scale(context, 3)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Buka untuk mendapatkan hadiah acak!',
                          style: GoogleFonts.nunito(
                            color: t.mutedText,
                            fontSize: S.scale(context, 11),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // ── GRUP TENGAH (conditional) ──
                  if (pool.rewards.isNotEmpty) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Kemungkinan Hadiah',
                            style: GoogleFonts.nunito(
                              color: t.mutedText,
                              fontSize: S.scale(context, 9),
                              fontWeight: FontWeight.w800,
                              letterSpacing: S.scale(context, 1),
                            ),
                          ),
                        ),
                        SizedBox(height: S.scale(context, 4)),
                        Wrap(
                          spacing: S.scale(context, 4),
                          runSpacing: S.scale(context, 4),
                          children: pool.rewards.map((reward) {
                            final color = _parseColor(reward.color);
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: S.scale(context, 6),
                                vertical: S.scale(context, 2),
                              ),
                              decoration: BoxDecoration(
                                color: color != null
                                    ? color.withValues(alpha: 0.15)
                                    : t.bgSurface2,
                                borderRadius: BorderRadius.circular(
                                    S.scale(context, 4)),
                                border: Border.all(
                                  color: color != null
                                      ? color.withValues(alpha: 0.35)
                                      : t.mutedText.withValues(alpha: 0.3),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${reward.displayLabel} ${reward.percentage}%',
                                  style: GoogleFonts.nunito(
                                    color: color ?? t.textPrimary,
                                    fontSize: S.scale(context, 9),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],

                  // ── GRUP BAWAH ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: S.scale(context, 1),
                        color: t.textPrimary.withValues(alpha: 0.1),
                      ),
                      SizedBox(height: S.scale(context, 6)),
                      // Footer: Price + Buy button
                      Row(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ExcludeSemantics(
                                child: Icon(
                                  Icons.diamond,
                                  size: S.scale(context, 16),
                                  color: t.info,
                                ),
                              ),
                              SizedBox(width: S.scale(context, 4)),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  formatNumber(pool.jewelCost),
                                  style: GoogleFonts.nunito(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: S.scale(context, 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          _BuyButton(
                            canAfford: canAfford,
                            isPending: isPending,
                            onTap: canAfford && !isPending ? onBuy : null,
                            t: t,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _parseColor(String? hex) => parseColor(hex);
}

class _BuyButton extends StatelessWidget {
  final bool canAfford;
  final bool isPending;
  final VoidCallback? onTap;
  final BloomTheme t;

  const _BuyButton({
    required this.canAfford,
    this.isPending = false,
    required this.onTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = isPending && canAfford;
    return Semantics(
      label: isLoading
          ? 'Memproses...'
          : canAfford
          ? 'Beli Mystery Box'
          : 'Saldo Tidak Cukup',
      child: Game3DButton(
        label: isLoading ? '' : 'Beli',
        color: canAfford ? t.primary : t.bgSurface2,
        shadowColor: t.textPrimary,
        textColor: canAfford ? t.primaryContent : t.mutedText,
        horizontalPadding: S.scale(context, 14),
        verticalPadding: S.scale(context, 6),
        isLoading: isLoading,
        onTap: canAfford && !isPending ? onTap : null,
        child: isLoading
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Icon(
                    Icons.card_giftcard,
                    size: S.scale(context, 14),
                    color: canAfford ? t.primaryContent : t.mutedText,
                  ),
                  SizedBox(width: S.scale(context, 4)),
                  Text(
                    'Beli',
                    style: GoogleFonts.nunito(
                      color: canAfford ? t.primaryContent : t.mutedText,
                      fontWeight: FontWeight.w800,
                      fontSize: S.scale(context, 12),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}