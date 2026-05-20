import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../core/utils/accessibility.dart';
import '../../data/models/reward_pool_model.dart';

String _fmt(int n) {
  if (n < 1000) return n.toString();
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

class MysteryBoxCard extends StatelessWidget {
  final RewardPool pool;
  final int balance;
  final VoidCallback onBuy;
  final BloomTheme t;

  const MysteryBoxCard({
    super.key,
    required this.pool,
    required this.balance,
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.textPrimary.withValues(alpha: 0.25), width: 2),
        boxShadow: [
          BoxShadow(color: t.border, offset: const Offset(3, 3), blurRadius: 0),
        ],
        gradient: bgCol != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgCol.withValues(alpha: 0.1),
                  bgCol.withValues(alpha: 0.04),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  const Color(0xFF06B6D4).withValues(alpha: 0.1),
                ],
              ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Shimmer overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      t.textPrimary.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
                ).animate(
                  onPlay: (controller) => a11yReduceMotion(context)
                      ? null
                      : controller.repeat(),
                ).slideX(
                begin: -1,
                end: 3,
                duration: const Duration(seconds: 3),
                curve: Curves.linear,
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Icon + Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: t.bgSurface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: t.textPrimary.withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: _icon.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: _icon,
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                  placeholder: (_, __) =>
                                      Icon(Icons.card_giftcard,
                                          size: 20, color: t.textHint),
                                  errorWidget: (_, __, ___) =>
                                      Icon(Icons.card_giftcard,
                                          size: 20, color: t.textHint),
                                )
                              : Text(
                                  _icon,
                                  style: const TextStyle(fontSize: 22),
                                ),
                        ),
                          )
                              .animate(
                                onPlay: (controller) => a11yReduceMotion(context)
                                    ? null
                                    : controller.repeat(),
                              )
                              .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.06, 1.06),
                            duration: const Duration(milliseconds: 2500),
                            curve: Curves.easeInOut,
                          ),
                      const Spacer(),
                      // Tier badge
                      if (pool.badgeLabel != null &&
                          pool.badgeLabel!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: t.bgSurface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color:
                                    t.textPrimary.withValues(alpha: 0.35)),
                          ),
                          child: Text(
                            pool.badgeLabel!,
                            style: GoogleFonts.nunito(
                              color: t.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Name + description
                  Text(
                    pool.name,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Buka untuk mendapatkan hadiah acak!',
                    style: GoogleFonts.nunito(
                      color: t.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Reward preview
                  if (pool.rewards.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Kemungkinan Hadiah',
                      style: GoogleFonts.nunito(
                        color: t.textHint,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: pool.rewards.map((reward) {
                        final color = _parseColor(reward.color);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color != null
                                ? color.withValues(alpha: 0.15)
                                : t.bgSurface2,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: color != null
                                  ? color.withValues(alpha: 0.35)
                                  : t.textHint.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '${reward.displayLabel} ${reward.percentage}%',
                            style: GoogleFonts.nunito(
                              color: color ?? t.textPrimary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 8),
                  Divider(
                      height: 1,
                      color: t.textPrimary.withValues(alpha: 0.1)),
                  const SizedBox(height: 6),

                  // Footer: Price + Buy button
                  Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.diamond,
                              size: 16, color: Color(0xFF60A5FA)),
                          const SizedBox(width: 4),
                          Text(
                            _fmt(pool.jewelCost),
                            style: GoogleFonts.nunito(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _BuyButton(
                        canAfford: canAfford,
                        onTap: canAfford ? onBuy : null,
                        t: t,
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

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }
}

class _BuyButton extends StatelessWidget {
  final bool canAfford;
  final VoidCallback? onTap;
  final BloomTheme t;

  const _BuyButton({
    required this.canAfford,
    required this.onTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: canAfford ? 'Beli Mystery Box' : 'Saldo Tidak Cukup',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: canAfford ? t.accent : t.bgSurface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: t.border, width: 2),
            boxShadow: canAfford
                ? [
                    BoxShadow(
                        color: t.border,
                        offset: const Offset(2, 2),
                        blurRadius: 0)
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.card_giftcard,
                  size: 14, color: canAfford ? t.accentText : t.textHint),
              const SizedBox(width: 4),
              Text(
                'Beli',
                style: GoogleFonts.nunito(
                  color: canAfford ? t.accentText : t.textHint,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
