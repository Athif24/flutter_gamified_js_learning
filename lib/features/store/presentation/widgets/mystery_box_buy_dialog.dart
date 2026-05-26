import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/game_3d_button.dart';
import '../../../../shared/widgets/info_row.dart';
import '../../../../core/utils/accessibility.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/models/reward_pool_model.dart';
import '../../../../shared/providers/gamification_providers.dart';
import '../providers/reward_pool_provider.dart';
import '../providers/store_provider.dart';

class MysteryBoxBuyDialog extends ConsumerWidget {
  final RewardPool pool;
  final int balance;
  final BloomTheme t;
  final WidgetRef ref;

  const MysteryBoxBuyDialog({
    super.key,
    required this.pool,
    required this.balance,
    required this.t,
    required this.ref,
  });

  String get _icon {
    if (pool.icon != null && pool.icon!.isNotEmpty) return pool.icon!;
    if (pool.name.toLowerCase().contains('legendary')) return '👑';
    if (pool.name.toLowerCase().contains('premium')) return '🎀';
    return '🎁';
  }

  Color? _parseColor(String? hex) => parseColor(hex);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = balance - pool.jewelCost;
    final ValueNotifier<bool> isPending = ValueNotifier(false);
    final w = MediaQuery.of(context).size.width;
    final rs = (double px) => px * (w / 390).clamp(0.8, 1.3);

    return StatefulBuilder(
      builder: (_, setLocalState) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: rs(400)),
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
              padding: EdgeInsets.fromLTRB(rs(24), rs(24), rs(24), rs(16)),
              child: Row(
                children: [
                  Container(
                        width: rs(36),
                        height: rs(36),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(rs(8)),
                          border: Border.all(color: t.textPrimary, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(rs(6)),
                          child: _icon.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: _icon,
                                  width: rs(36),
                                  height: rs(36),
                                  fit: BoxFit.contain,
                                  placeholder: (_, __) => Container(
                                    color: t.bgSurface2,
                                    child: Icon(
                                      Icons.card_giftcard,
                                      size: rs(20),
                                      color: t.mutedText,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: t.bgSurface2,
                                    child: Icon(
                                      Icons.card_giftcard,
                                      size: rs(20),
                                      color: t.mutedText,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: t.bgSurface2,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _icon,
                                    style: TextStyle(fontSize: rs(20)),
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
                  SizedBox(width: rs(8)),
                  Expanded(
                    child: Text(
                      'Beli ${pool.name}?',
                      style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: rs(18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: rs(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hadiah yang didapat bersifat acak. Jewels tidak bisa dikembalikan setelah pembelian.',
                      style: GoogleFonts.nunito(
                        color: t.mutedText,
                        fontSize: rs(13),
                      ),
                    ),
                    SizedBox(height: rs(16)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(rs(16)),
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
                                Icon(Icons.diamond, size: rs(14), color: t.info),
                                SizedBox(width: rs(4)),
                                Text(
                                  '-${formatNumber(pool.jewelCost)}',
                                  style: GoogleFonts.nunito(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: rs(13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: rs(8)),
                          InfoRow(
                            label: 'Balance saat ini',
                            t: t,
                            value: Text(
                              formatNumber(balance),
                              style: GoogleFonts.nunito(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: rs(13),
                              ),
                            ),
                          ),
                          Divider(
                            height: rs(20),
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
                                fontSize: rs(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: rs(16)),
                    Text(
                      'Kemungkinan Hadiah',
                      style: GoogleFonts.nunito(
                        color: t.mutedText,
                        fontSize: rs(10),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: rs(8)),
                    ...pool.rewards.map((reward) {
                      final color = _parseColor(reward.color);
                      return Padding(
                        padding: EdgeInsets.only(bottom: rs(6)),
                        child: Row(
                          children: [
                            Container(
                              width: rs(8),
                              height: rs(8),
                              decoration: BoxDecoration(
                                color: color ?? t.mutedText,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: rs(8)),
                            Expanded(
                              child: Text(
                                reward.displayLabel,
                                style: GoogleFonts.nunito(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: rs(13),
                                ),
                              ),
                            ),
                            Text(
                              '${reward.percentage}%',
                              style: GoogleFonts.nunito(
                                color: t.mutedText,
                                fontWeight: FontWeight.w700,
                                fontSize: rs(12),
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
            SizedBox(height: rs(16)),
            Padding(
              padding: EdgeInsets.fromLTRB(rs(24), 0, rs(24), rs(24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Game3DButton(
                      label: 'Batal',
                      color: t.secondary,
                      shadowColor: t.textPrimary,
                      textColor: t.secondaryContent,
                      horizontalPadding: 14,
                      verticalPadding: 10,
                      onTap: isPending.value ? null : () => Navigator.of(context).pop(),
                    ),
                  ),
                  SizedBox(width: rs(12)),
                  Expanded(
                    child: Game3DButton(
                      label: remaining >= 0
                          ? AppStrings.buyNow
                          : 'Saldo Tidak Cukup',
                      color: remaining >= 0 ? t.primary : t.bgSurface2,
                      shadowColor: t.textPrimary,
                      textColor: remaining >= 0
                          ? t.primaryContent
                          : t.mutedText,
                      horizontalPadding: 14,
                      verticalPadding: 10,
                      isLoading: isPending.value,
                      onTap: remaining < 0 || isPending.value
                          ? null
                          : () async {
                              setLocalState(() => isPending.value = true);
                              try {
                                await ref.read(rewardPoolDsProvider).buyPool(pool.id);
                                invalidateGamificationProviders(ref);
                                ref.invalidate(storeItemsProvider);
                                ref.invalidate(inventoryProvider);
                                ref.invalidate(rewardPoolsProvider);
                                ref.invalidate(jewelBalanceProvider);
                                ref.invalidate(jewelHistoryProvider);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Berhasil membeli ${pool.name}!',
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      backgroundColor: t.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  setLocalState(() => isPending.value = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        sanitizeErrorMessage(e),
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w600,
                                        ),                                                
                                      ),
                                      backgroundColor: t.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
