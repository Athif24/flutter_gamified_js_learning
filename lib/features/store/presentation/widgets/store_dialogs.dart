import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/game_3d_button.dart';
import '../../../../shared/widgets/info_row.dart';
import '../../../../shared/providers/gamification_providers.dart';
import '../../../../core/utils/accessibility.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/store_model.dart';
import '../../data/models/reward_pool_model.dart';
import '../providers/store_provider.dart';
import '../providers/reward_pool_provider.dart';

class StoreBuyDialog extends ConsumerWidget {
  final StoreItem item;
  final BloomTheme t;
  final WidgetRef ref;
  final int balance;
  final VoidCallback onDismiss;

  StoreBuyDialog({
    super.key,
    required this.item,
    required this.t,
    required this.ref,
    required this.balance,
    required this.onDismiss,
  });

  final ValueNotifier<bool> _isBuying = ValueNotifier(false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = balance - item.price;

    return StatefulBuilder(
      builder: (_, setLocalState) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: S.scale(context, 400)),
          decoration: BoxDecoration(
            color: t.bgSurface,
            borderRadius: BorderRadius.circular(S.scale(context, 20)),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  S.scale(context, 24),
                  S.scale(context, 24),
                  S.scale(context, 24),
                  S.scale(context, 16),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Konfirmasi Pembelian',
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: S.scale(context, 18),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: S.scale(context, 24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pastikan kamu yakin dengan pembelian ini. Jewels tidak bisa dikembalikan.',
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontSize: S.scale(context, 13),
                        ),
                      ),
                      SizedBox(height: S.scale(context, 16)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(S.scale(context, 16)),
                        decoration: BoxDecoration(
                          color: t.bgPrimary,
                          borderRadius:
                              BorderRadius.circular(S.scale(context, 12)),
                          border: Border.all(
                            color: t.textPrimary,
                            width: S.scale(context, 1.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: t.textPrimary,
                              offset: Offset(
                                S.scale(context, 2),
                                S.scale(context, 2),
                              ),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: S.scale(context, 48),
                                  height: S.scale(context, 48),
                                  decoration: BoxDecoration(
                                    color: t.bgSurface,
                                    borderRadius:
                                        BorderRadius.circular(S.scale(context, 10)),
                                    border: Border.all(
                                      color: t.textPrimary,
                                      width: S.scale(context, 1.5),
                                    ),
                                  ),
                                  child: Center(
                                    child: item.icon.startsWith('http')
                                        ? CachedNetworkImage(
                                            imageUrl: item.icon,
                                            width: S.scale(context, 28),
                                            height: S.scale(context, 28),
                                            fit: BoxFit.contain,
                                            placeholder: (_, __) => Icon(
                                              Icons.inventory_2_rounded,
                                              size: S.scale(context, 24),
                                              color: t.mutedText,
                                            ),
                                            errorWidget: (_, __, ___) => Icon(
                                              Icons.inventory_2_rounded,
                                              size: S.scale(context, 24),
                                              color: t.mutedText,
                                            ),
                                          )
                                        : Text(
                                            item.icon,
                                            style: TextStyle(
                                              fontSize: S.scale(context, 24),
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(width: S.scale(context, 12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: GoogleFonts.nunito(
                                          color: t.textPrimary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: S.scale(context, 14),
                                        ),
                                      ),
                                      SizedBox(height: S.scale(context, 2)),
                                      Text(
                                        itemTypeLabels[item.type] ?? item.type,
                                        style: GoogleFonts.nunito(
                                          color: t.mutedText,
                                          fontSize: S.scale(context, 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: S.scale(context, 14)),
                            _infoRow(
                              'Harga',
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.diamond,
                                    size: S.scale(context, 14),
                                    color: t.info,
                                  ),
                                  SizedBox(width: S.scale(context, 4)),
                                  Text(
                                    '-${formatNumber(item.price)}',
                                    style: GoogleFonts.nunito(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: S.scale(context, 13),
                                    ),
                                  ),
                                ],
                              ),
                              context,
                            ),
                            SizedBox(height: S.scale(context, 8)),
                            _infoRow(
                              'Balance saat ini',
                              Text(
                                formatNumber(balance),
                                style: GoogleFonts.nunito(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: S.scale(context, 13),
                                ),
                              ),
                              context,
                            ),
                            Divider(
                              height: S.scale(context, 20),
                              color: t.textPrimary.withValues(alpha: 0.1),
                            ),
                            _infoRow(
                              'Sisa balance',
                              Text(
                                formatNumber(remaining),
                                style: GoogleFonts.nunito(
                                  color: remaining >= 0 ? t.info : t.error,
                                  fontWeight: FontWeight.w800,
                                  fontSize: S.scale(context, 14),
                                ),
                              ),
                              context,
                            ),
                          ],
                        ),
                      ),
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        SizedBox(height: S.scale(context, 10)),
                        Text(
                          item.description!,
                          style: GoogleFonts.nunito(
                            color: t.mutedText,
                            fontSize: S.scale(context, 13),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: S.scale(context, 16)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  S.scale(context, 24),
                  0,
                  S.scale(context, 24),
                  S.scale(context, 24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Game3DButton(
                        label: 'Batal',
                        color: t.secondary,
                        shadowColor: t.textPrimary,
                        textColor: t.secondaryContent,
                        horizontalPadding: S.scale(context, 14),
                        verticalPadding: S.scale(context, 10),
                        onTap: onDismiss,
                      ),
                    ),
                    SizedBox(width: S.scale(context, 12)),
                    Expanded(
                      child: Game3DButton(
                        label: remaining >= 0
                            ? AppStrings.buyNow
                            : AppStrings.insufficientBalance,
                        color: remaining >= 0 ? t.primary : t.bgSurface2,
                        shadowColor: t.textPrimary,
                        textColor: remaining >= 0
                            ? t.primaryContent
                            : t.mutedText,
                        horizontalPadding: S.scale(context, 14),
                        verticalPadding: S.scale(context, 10),
                        isLoading: _isBuying.value,
                        onTap: remaining < 0 || _isBuying.value
                            ? null
                            : () async {
                                setLocalState(() => _isBuying.value = true);
                                try {
                                  await ref
                                      .read(storeDsProvider)
                                      .buyItem(item.id);
                                  invalidateGamificationProviders(ref);
                                  ref.invalidate(storeItemsProvider);
                                  ref.invalidate(inventoryProvider);
                                  ref.invalidate(jewelBalanceProvider);
                                  ref.invalidate(jewelHistoryProvider);
                                  if (context.mounted) {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    Navigator.of(context).pop();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Berhasil membeli ${item.name}!',
                                          style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        backgroundColor: t.success,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            S.scale(context, 12),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    Navigator.of(context).pop();
                                    messenger.showSnackBar(
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
                                          borderRadius: BorderRadius.circular(
                                            S.scale(context, 12),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  setLocalState(() => _isBuying.value = false);
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

  Widget _infoRow(String label, Widget value, BuildContext c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              color: t.mutedText,
              fontWeight: FontWeight.w600,
              fontSize: S.scale(c, 13),
            ),
          ),
        ),
        SizedBox(width: S.scale(c, 8)),
        Flexible(child: value),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════

class StoreUseDialog extends ConsumerWidget {
  final InventoryItem invItem;
  final StoreItem storeItem;
  final BloomTheme t;
  final WidgetRef ref;

  StoreUseDialog({
    super.key,
    required this.invItem,
    required this.storeItem,
    required this.t,
    required this.ref,
  });

  final ValueNotifier<bool> _isUsing = ValueNotifier(false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = invItem.quantity - 1;

    return StatefulBuilder(
      builder: (_, setLocalState) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: S.scale(context, 400)),
          decoration: BoxDecoration(
            color: t.bgSurface,
            borderRadius: BorderRadius.circular(S.scale(context, 20)),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  S.scale(context, 24),
                  S.scale(context, 24),
                  S.scale(context, 24),
                  S.scale(context, 16),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Gunakan Item?',
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: S.scale(context, 18),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: S.scale(context, 24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item ini akan digunakan dan quantity akan berkurang 1.',
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontSize: S.scale(context, 13),
                        ),
                      ),
                      SizedBox(height: S.scale(context, 16)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(S.scale(context, 16)),
                        decoration: BoxDecoration(
                          color: t.bgPrimary,
                          borderRadius:
                              BorderRadius.circular(S.scale(context, 12)),
                          border: Border.all(
                            color: t.textPrimary,
                            width: S.scale(context, 1.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: t.textPrimary,
                              offset: Offset(
                                S.scale(context, 2),
                                S.scale(context, 2),
                              ),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: S.scale(context, 48),
                                  height: S.scale(context, 48),
                                  decoration: BoxDecoration(
                                    color: t.bgSurface,
                                    borderRadius:
                                        BorderRadius.circular(S.scale(context, 10)),
                                    border: Border.all(
                                      color: t.textPrimary,
                                      width: S.scale(context, 1.5),
                                    ),
                                  ),
                                  child: Center(
                                    child: storeItem.icon.startsWith('http')
                                        ? CachedNetworkImage(
                                            imageUrl: storeItem.icon,
                                            width: S.scale(context, 28),
                                            height: S.scale(context, 28),
                                            fit: BoxFit.contain,
                                            placeholder: (_, __) => Icon(
                                              Icons.inventory_2_rounded,
                                              size: S.scale(context, 24),
                                              color: t.mutedText,
                                            ),
                                            errorWidget: (_, __, ___) => Icon(
                                              Icons.inventory_2_rounded,
                                              size: S.scale(context, 24),
                                              color: t.mutedText,
                                            ),
                                          )
                                        : Text(
                                            storeItem.icon,
                                            style: TextStyle(
                                              fontSize: S.scale(context, 24),
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(width: S.scale(context, 12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        storeItem.name,
                                        style: GoogleFonts.nunito(
                                          color: t.textPrimary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: S.scale(context, 14),
                                        ),
                                      ),
                                      SizedBox(height: S.scale(context, 2)),
                                      Text(
                                        itemTypeLabels[storeItem.type] ??
                                            storeItem.type,
                                        style: GoogleFonts.nunito(
                                          color: t.mutedText,
                                          fontSize: S.scale(context, 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: S.scale(context, 14)),
                            _infoRow(
                              'Efek',
                              Text(
                                _useEffectDesc(),
                                textAlign: TextAlign.right,
                                style: GoogleFonts.nunito(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: S.scale(context, 13),
                                ),
                              ),
                              context,
                            ),
                            Divider(
                              height: S.scale(context, 20),
                              color: t.textPrimary.withValues(alpha: 0.1),
                            ),
                            _infoRow(
                              'Quantity setelah pakai',
                              Text(
                                '${invItem.quantity - 1}',
                                style: GoogleFonts.nunito(
                                  color: remaining >= 0
                                      ? t.textPrimary
                                      : t.error,
                                  fontWeight: FontWeight.w800,
                                  fontSize: S.scale(context, 14),
                                ),
                              ),
                              context,
                            ),
                          ],
                        ),
                      ),
                      if (storeItem.description != null &&
                          storeItem.description!.isNotEmpty) ...[
                        SizedBox(height: S.scale(context, 10)),
                        Text(
                          storeItem.description!,
                          style: GoogleFonts.nunito(
                            color: t.mutedText,
                            fontSize: S.scale(context, 13),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: S.scale(context, 16)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  S.scale(context, 24),
                  0,
                  S.scale(context, 24),
                  S.scale(context, 24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Game3DButton(
                        label: 'Batal',
                        color: t.secondary,
                        shadowColor: t.textPrimary,
                        textColor: t.secondaryContent,
                        horizontalPadding: S.scale(context, 14),
                        verticalPadding: S.scale(context, 10),
                        onTap: _isUsing.value
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(width: S.scale(context, 12)),
                    if (remaining >= 0)
                      Expanded(
                        child: Game3DButton(
                          label: 'Gunakan',
                          color: t.primary,
                          shadowColor: t.textPrimary,
                          textColor: t.primaryContent,
                          horizontalPadding: 14,
                          verticalPadding: 10,
                          isLoading: _isUsing.value,
                          onTap: _isUsing.value
                              ? null
                              : () async {
                                  setLocalState(() => _isUsing.value = true);
                                  try {
                                    await ref
                                        .read(storeDsProvider)
                                        .useItem(invItem.itemId.toString());
                                    ref.invalidate(inventoryProvider);
                                    ref.invalidate(jewelBalanceProvider);
                                    ref.invalidate(storeItemsProvider);
                                    if (context.mounted) {
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      Navigator.of(context).pop();
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Berhasil menggunakan ${storeItem.name}!',
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          backgroundColor: t.success,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              S.scale(context, 12),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      Navigator.of(context).pop();
                                      messenger.showSnackBar(
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
                                            borderRadius: BorderRadius.circular(
                                              S.scale(context, 12),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } finally {
                                    setLocalState(() => _isUsing.value = false);
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

  String _useEffectDesc() {
    if (storeItem.description != null && storeItem.description!.isNotEmpty) {
      return storeItem.description!;
    }
    final base = itemTypeDescriptions[storeItem.type] ?? '';
    if (storeItem.effectValue != null && storeItem.effectValue! > 0) {
      return '$base (+${storeItem.effectValue})';
    }
    return base;
  }

  Widget _infoRow(String label, Widget value, BuildContext c) {
    return Row(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              color: t.mutedText,
              fontWeight: FontWeight.w600,
              fontSize: S.scale(c, 13),
            ),
          ),
        ),
        SizedBox(width: S.scale(c, 8)),
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: value),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════

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

    return StatefulBuilder(
      builder: (_, setLocalState) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: S.scale(context, 400)),
          decoration: BoxDecoration(
            color: t.bgSurface,
            borderRadius: BorderRadius.circular(S.scale(context, 20)),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  S.scale(context, 24),
                  S.scale(context, 24),
                  S.scale(context, 24),
                  S.scale(context, 16),
                ),
                child: Row(
                  children: [
                    Container(
                          width: S.scale(context, 36),
                          height: S.scale(context, 36),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              S.scale(context, 8),
                            ),
                            border: Border.all(
                              color: t.textPrimary,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              S.scale(context, 6),
                            ),
                            child: _icon.startsWith('http')
                                ? CachedNetworkImage(
                                    imageUrl: _icon,
                                    width: S.scale(context, 36),
                                    height: S.scale(context, 36),
                                    fit: BoxFit.contain,
                                    placeholder: (_, __) => Container(
                                      color: t.bgSurface2,
                                      child: Icon(
                                        Icons.card_giftcard,
                                        size: S.scale(context, 20),
                                        color: t.mutedText,
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: t.bgSurface2,
                                      child: Icon(
                                        Icons.card_giftcard,
                                        size: S.scale(context, 20),
                                        color: t.mutedText,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: t.bgSurface2,
                                    alignment: Alignment.center,
                                    child: Text(
                                      _icon,
                                      style: TextStyle(
                                        fontSize: S.scale(context, 20),
                                      ),
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
                    SizedBox(width: S.scale(context, 8)),
                    Expanded(
                      child: Text(
                        'Beli ${pool.name}?',
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: S.scale(context, 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: S.scale(context, 24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hadiah yang didapat bersifat acak. Jewels tidak bisa dikembalikan setelah pembelian.',
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontSize: S.scale(context, 13),
                        ),
                      ),
                      SizedBox(height: S.scale(context, 16)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(S.scale(context, 16)),
                        decoration: BoxDecoration(
                          color: t.bgPrimary,
                          borderRadius:
                              BorderRadius.circular(S.scale(context, 12)),
                          border: Border.all(
                            color: t.textPrimary,
                            width: S.scale(context, 1.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: t.textPrimary,
                              offset: Offset(
                                S.scale(context, 2),
                                S.scale(context, 2),
                              ),
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
                                  Icon(
                                    Icons.diamond,
                                    size: S.scale(context, 14),
                                    color: t.info,
                                  ),
                                  SizedBox(width: S.scale(context, 4)),
                                  Text(
                                    '-${formatNumber(pool.jewelCost)}',
                                    style: GoogleFonts.nunito(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: S.scale(context, 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: S.scale(context, 8)),
                            InfoRow(
                              label: 'Balance saat ini',
                              t: t,
                              value: Text(
                                formatNumber(balance),
                                style: GoogleFonts.nunito(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: S.scale(context, 13),
                                ),
                              ),
                            ),
                            Divider(
                              height: S.scale(context, 20),
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
                                  fontSize: S.scale(context, 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: S.scale(context, 16)),
                      Text(
                        'Kemungkinan Hadiah',
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontSize: S.scale(context, 10),
                          fontWeight: FontWeight.w800,
                          letterSpacing: S.scale(context, 1),
                        ),
                      ),
                      SizedBox(height: S.scale(context, 8)),
                      ...pool.rewards.map((reward) {
                        final color = _parseColor(reward.color);
                        return Padding(
                          padding: EdgeInsets.only(bottom: S.scale(context, 6)),
                          child: Row(
                            children: [
                              Container(
                                width: S.scale(context, 8),
                                height: S.scale(context, 8),
                                decoration: BoxDecoration(
                                  color: color ?? t.mutedText,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: S.scale(context, 8)),
                              Expanded(
                                child: Text(
                                  reward.displayLabel,
                                  style: GoogleFonts.nunito(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: S.scale(context, 13),
                                  ),
                                ),
                              ),
                              Text(
                                '${reward.percentage}%',
                                style: GoogleFonts.nunito(
                                  color: t.mutedText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: S.scale(context, 12),
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
              SizedBox(height: S.scale(context, 16)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  S.scale(context, 24),
                  0,
                  S.scale(context, 24),
                  S.scale(context, 24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Game3DButton(
                        label: 'Batal',
                        color: t.secondary,
                        shadowColor: t.textPrimary,
                        textColor: t.secondaryContent,
                        horizontalPadding: S.scale(context, 14),
                        verticalPadding: S.scale(context, 10),
                        onTap: isPending.value
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(width: S.scale(context, 12)),
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
                        horizontalPadding: S.scale(context, 14),
                        verticalPadding: S.scale(context, 10),
                        isLoading: isPending.value,
                        onTap: remaining < 0 || isPending.value
                            ? null
                            : () async {
                                setLocalState(() => isPending.value = true);
                                try {
                                  await ref
                                      .read(rewardPoolDsProvider)
                                      .buyPool(pool.id);
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
                                          borderRadius: BorderRadius.circular(
                                            S.scale(context, 12),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    setLocalState(
                                      () => isPending.value = false,
                                    );
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
                                          borderRadius: BorderRadius.circular(
                                            S.scale(context, 12),
                                          ),
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