import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/info_row.dart';
import '../../../../core/utils/accessibility.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/models/reward_pool_model.dart';

class MysteryBoxBuyDialog extends StatelessWidget {
  final RewardPool pool;
  final int balance;
  final bool isPending;
  final VoidCallback onClose;
  final VoidCallback onConfirm;
  final BloomTheme t;

  const MysteryBoxBuyDialog({
    super.key,
    required this.pool,
    required this.balance,
    required this.isPending,
    required this.onClose,
    required this.onConfirm,
    required this.t,
  });

  String get _icon {
    if (pool.icon != null && pool.icon!.isNotEmpty) return pool.icon!;
    if (pool.name.toLowerCase().contains('legendary')) return '👑';
    if (pool.name.toLowerCase().contains('premium')) return '🎀';
    return '🎁';
  }

  Color? _parseColor(String? hex) => parseColor(hex);

  @override
  Widget build(BuildContext context) {
    final remaining = balance - pool.jewelCost;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: t.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.textPrimary, width: 2),
          boxShadow: [
            BoxShadow(
              color: t.textPrimary,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: t.textPrimary, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.5),
                          child: _icon.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: _icon,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.contain,
                                  placeholder: (_, __) => Container(
                                    color: t.bgSurface2,
                                    child: Icon(
                                      Icons.card_giftcard,
                                      size: 20,
                                      color: t.mutedText,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: t.bgSurface2,
                                    child: Icon(
                                      Icons.card_giftcard,
                                      size: 20,
                                      color: t.mutedText,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: t.bgSurface2,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _icon,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                        ),
                      )
                      .animate(
                        onPlay: (controller) => a11yReduceMotion(context)
                            ? null
                            : controller.repeat(),
                      )
                      .shimmer(
                        duration: 1200.ms,
                        color: t.primary.withValues(alpha: 0.15),
                      )
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.12, 1.12),
                        duration: 1200.ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.12, 1.12),
                        end: const Offset(1.0, 1.0),
                        duration: 1200.ms,
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Beli ${pool.name}?',
                      style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hadiah yang didapat bersifat acak. Jewels tidak bisa dikembalikan setelah pembelian.',
                      style: GoogleFonts.nunito(
                        color: t.mutedText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: t.bgPrimary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.textPrimary, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: t.textPrimary,
                            offset: const Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          InfoRow(
                            label: 'Harga',
                            t: t,
                            value: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.diamond, size: 14, color: t.info),
                                const SizedBox(width: 4),
                                Text(
                                  '-${formatNumber(pool.jewelCost)}',
                                  style: GoogleFonts.nunito(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          InfoRow(
                            label: 'Balance saat ini',
                            t: t,
                            value: Text(
                              formatNumber(balance),
                              style: GoogleFonts.nunito(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Divider(
                            height: 20,
                            color: t.textPrimary.withValues(alpha: 0.1),
                          ),
                          InfoRow(
                            label: 'Sisa balance',
                            t: t,
                            value: Text(
                              formatNumber(remaining),
                              style: GoogleFonts.nunito(
                                color: remaining >= 0 ? t.info : t.error,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kemungkinan Hadiah',
                      style: GoogleFonts.nunito(
                        color: t.mutedText,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...pool.rewards.map((reward) {
                      final color = _parseColor(reward.color);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color ?? t.mutedText,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reward.displayLabel,
                                style: GoogleFonts.nunito(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '${reward.percentage}%',
                              style: GoogleFonts.nunito(
                                color: t.mutedText,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    label: 'Batal',
                    child: Bounceable(
                      onTap: isPending ? null : onClose,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: t.bgSurface2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: t.textPrimary, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: t.textPrimary,
                              offset: const Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.nunito(
                            color: t.mutedText,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Semantics(
                    label: remaining >= 0
                        ? 'Beli Sekarang'
                        : 'Saldo Tidak Cukup',
                    child: Bounceable(
                      onTap: isPending ? null : onConfirm,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isPending ? t.bgSurface2 : t.primary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: t.textPrimary, width: 2),
                          boxShadow: isPending
                              ? null
                              : [
                                  BoxShadow(
                                    color: t.textPrimary,
                                    offset: const Offset(3, 3),
                                    blurRadius: 0,
                                  ),
                                ],
                        ),
                        child: Text(
                          isPending ? 'Memproses...' : 'Beli Sekarang',
                          style: GoogleFonts.nunito(
                            color: isPending ? t.mutedText : t.primaryContent,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
