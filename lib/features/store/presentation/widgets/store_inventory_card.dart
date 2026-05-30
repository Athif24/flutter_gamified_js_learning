import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/game_3d_button.dart';
import '../../data/models/store_model.dart';

const _typeBadgeColors = <String, Color>{
  'life_refill': Color(0xFFEF4444),
  'full_lives': Color(0xFFEF4444),
  'xp_boost': Color(0xFFF59E0B),
  'streak_freeze': Color(0xFF3B82F6),
  'double_xp': Color(0xFF8B5CF6),
  'mystery_box': Color(0xFFA855F7),
};

class StoreInventoryCard extends ConsumerWidget {
  final InventoryItem item;
  final BloomTheme t;
  final WidgetRef ref;
  final void Function(InventoryItem, StoreItem) onUse;
  final void Function(InventoryItem, StoreItem) onOpenMysteryBox;

  const StoreInventoryCard({
    super.key,
    required this.item,
    required this.t,
    required this.ref,
    required this.onUse,
    required this.onOpenMysteryBox,
  });

  void _onUse(BuildContext context) {
    final storeItem = item.item;
    if (storeItem == null) return;
    onUse(item, storeItem);
  }

  void _onOpenMysteryBox(BuildContext context) {
    final storeItem = item.item;
    if (storeItem == null) return;
    onOpenMysteryBox(item, storeItem);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeItem = item.item;
    if (storeItem == null) return const SizedBox.shrink();

    final isMysteryBox = storeItem.type == 'mystery_box';
    final canUse = storeItem.isConsumable && item.quantity > 0;
    final typeColor = _typeBadgeColors[storeItem.type] ?? t.mutedText;

    return Container(
      padding: EdgeInsets.all(S.scale(context, 20)),
      decoration: BoxDecoration(
        color: isMysteryBox ? null : t.bgSurface,
        gradient: isMysteryBox
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                    const Color(0xFFA855F7).withValues(alpha: 0.05),
                    t.bgSurface,
                  ),
                  Color.alphaBlend(
                    const Color(0xFFEC4899).withValues(alpha: 0.05),
                    t.bgSurface,
                  ),
                ],
              )
            : null,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: S.scale(context, 56),
                height: S.scale(context, 56),
                decoration: BoxDecoration(
                  color: t.bgSurface2,
                  borderRadius:
                      BorderRadius.circular(S.scale(context, 12)),
                  border: Border.all(
                    color: t.textPrimary,
                    width: S.scale(context, 1.5),
                  ),
                ),
                child: Center(
                  child: storeItem.icon.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: storeItem.icon,
                          width: S.scale(context, 32),
                          height: S.scale(context, 32),
                          fit: BoxFit.contain,
                          placeholder: (_, __) => Icon(
                            Icons.inventory_2_rounded,
                            size: S.scale(context, 28),
                            color: t.mutedText,
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.inventory_2_rounded,
                            size: S.scale(context, 28),
                            color: t.mutedText,
                          ),
                        )
                      : Text(
                          storeItem.icon,
                          style: TextStyle(fontSize: S.scale(context, 28)),
                        ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: S.scale(context, 8),
                      vertical: S.scale(context, 3),
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(S.scale(context, 6)),
                      border: Border.all(
                        color: typeColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        itemTypeLabels[storeItem.type] ?? storeItem.type,
                        style: GoogleFonts.nunito(
                          color: typeColor,
                          fontSize: S.scale(context, 11),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: S.scale(context, 6)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: S.scale(context, 8),
                      vertical: S.scale(context, 2),
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(S.scale(context, 6)),
                      border: Border.all(
                        color: t.textPrimary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'x${item.quantity}',
                      style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: S.scale(context, 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 12)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              storeItem.name,
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: S.scale(context, 16),
              ),
            ),
          ),
          SizedBox(height: S.scale(context, 4)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _itemEffectDesc(storeItem),
              style: GoogleFonts.nunito(
                color: t.mutedText,
                fontSize: S.scale(context, 12),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: S.scale(context, 12)),
          Divider(
            height: S.scale(context, 1),
            color: t.textPrimary.withValues(alpha: 0.1),
          ),
          SizedBox(height: S.scale(context, 10)),
          Row(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Diperoleh: ${formatDate(item.acquiredAt ?? '')}',
                  style: GoogleFonts.nunito(
                    color: t.mutedText,
                    fontSize: S.scale(context, 10),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              if (canUse)
                Semantics(
                  label: isMysteryBox
                      ? 'Buka Mystery Box'
                      : 'Gunakan ${storeItem.name}',
                  child: Game3DButton(
                    label: isMysteryBox ? 'Buka' : 'Gunakan',
                    color: t.primary,
                    shadowColor: t.textPrimary,
                    textColor: t.primaryContent,
                    horizontalPadding: S.scale(context, 14),
                    verticalPadding: S.scale(context, 6),
                    onTap: () => isMysteryBox
                        ? _onOpenMysteryBox(context)
                        : _onUse(context),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: S.scale(context, 14),
                    vertical: S.scale(context, 7),
                  ),
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius:
                        BorderRadius.circular(S.scale(context, 10)),
                    border: Border.all(
                      color: t.textPrimary,
                      width: S.scale(context, 2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.block_rounded,
                        size: S.scale(context, 14),
                        color: t.mutedText,
                      ),
                      SizedBox(width: S.scale(context, 4)),
                      Text(
                        storeItem.isConsumable
                            ? 'Habis'
                            : 'Tidak bisa digunakan',
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontWeight: FontWeight.w800,
                          fontSize: S.scale(context, 11),
                        ),
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

  String _itemEffectDesc(StoreItem si) {
    if (si.description != null && si.description!.isNotEmpty) {
      return si.description!;
    }
    final base = itemTypeDescriptions[si.type] ?? '';
    if (si.effectValue != null && si.effectValue! > 0) {
      return '$base (+${si.effectValue})';
    }
    return base;
  }
}