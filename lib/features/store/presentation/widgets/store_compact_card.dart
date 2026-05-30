import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/services/sound_service.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/models/store_model.dart';

const _typeBadgeColors = <String, Color>{
  'life_refill': Color(0xFFEF4444),
  'full_lives': Color(0xFFEF4444),
  'xp_boost': Color(0xFFF59E0B),
  'streak_freeze': Color(0xFF3B82F6),
  'double_xp': Color(0xFF8B5CF6),
  'mystery_box': Color(0xFFA855F7),
};

class StoreCompactCard extends ConsumerWidget {
  final StoreItem item;
  final BloomTheme t;
  final WidgetRef ref;
  final int balance;
  final void Function(StoreItem) onBuy;

  const StoreCompactCard({
    super.key,
    required this.item,
    required this.t,
    required this.ref,
    required this.balance,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAfford = balance >= item.price;

    return Container(
      padding: EdgeInsets.all(S.scale(context, 14)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(S.scale(context, 16)),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: S.scale(context, 44),
                height: S.scale(context, 44),
                decoration: BoxDecoration(
                  color: t.bgSurface2,
                  borderRadius: BorderRadius.circular(S.scale(context, 10)),
                  border: Border.all(
                    color: t.textPrimary,
                    width: S.scale(context, 1.5),
                  ),
                ),
                child: Center(
                  child: item.icon.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: item.icon,
                          width: S.scale(context, 26),
                          height: S.scale(context, 26),
                          fit: BoxFit.contain,
                          placeholder: (_, __) => Icon(
                            Icons.inventory_2_rounded,
                            size: S.scale(context, 22),
                            color: t.mutedText,
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.inventory_2_rounded,
                            size: S.scale(context, 22),
                            color: t.mutedText,
                          ),
                        )
                      : Text(
                          item.icon,
                          style: TextStyle(fontSize: S.scale(context, 22)),
                        ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: S.scale(context, 5),
                  vertical: S.scale(context, 2),
                ),
                decoration: BoxDecoration(
                  color: (_typeBadgeColors[item.type] ?? t.mutedText)
                      .withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(S.scale(context, 4)),
                  border: Border.all(
                    color: (_typeBadgeColors[item.type] ?? t.mutedText)
                        .withValues(alpha: 0.5),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    itemTypeLabels[item.type] ?? item.type,
                    style: GoogleFonts.nunito(
                      color: _typeBadgeColors[item.type] ?? t.mutedText,
                      fontSize: S.scale(context, 9),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 10)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.name,
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: S.scale(context, 13),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: S.scale(context, 3)),
          if (item.description != null && item.description!.isNotEmpty)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.description!,
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontSize: S.scale(context, 10),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                itemTypeDescriptions[item.type] ?? '',
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontSize: S.scale(context, 10),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Spacer(),
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.diamond,
                    size: S.scale(context, 12),
                    color: t.info,
                  ),
                  SizedBox(width: S.scale(context, 3)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatNumber(item.price),
                      style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: S.scale(context, 12),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Semantics(
                label: canAfford ? 'Beli ${item.name}' : 'Saldo Tidak Cukup',
                child: Bounceable(
                  onTap: canAfford
                      ? () {
                          ref.read(soundProvider).playClick();
                          onBuy(item);
                        }
                      : null,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: S.scale(context, 36),
                      minHeight: S.scale(context, 36),
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal: S.scale(context, 10),
                      vertical: S.scale(context, 6),
                    ),
                    decoration: BoxDecoration(
                      color: canAfford ? t.primary : t.bgSurface2,
                      borderRadius:
                          BorderRadius.circular(S.scale(context, 10)),
                      border: Border.all(
                        color: t.textPrimary,
                        width: S.scale(context, 2),
                      ),
                      boxShadow: canAfford
                          ? [
                              BoxShadow(
                                color: t.textPrimary,
                                offset: Offset(
                                  S.scale(context, 3),
                                  S.scale(context, 3),
                                ),
                                blurRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_cart_rounded,
                          size: S.scale(context, 14),
                          color: canAfford ? t.primaryContent : t.mutedText,
                        ),
                        SizedBox(width: S.scale(context, 4)),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Beli',
                            style: GoogleFonts.nunito(
                              color: canAfford ? t.primaryContent : t.mutedText,
                              fontWeight: FontWeight.w800,
                              fontSize: S.scale(context, 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}