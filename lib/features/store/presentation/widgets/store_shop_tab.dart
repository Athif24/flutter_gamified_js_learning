import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/store_model.dart';
import '../../data/models/reward_pool_model.dart';
import '../providers/store_provider.dart';
import '../providers/reward_pool_provider.dart';
import '../widgets/mystery_box_card.dart';
import '../widgets/store_skeleton.dart';
import '../widgets/store_empty_state.dart';
import '../widgets/store_compact_card.dart';
import '../widgets/store_dialogs.dart';

class StoreShopTab extends ConsumerStatefulWidget {
  const StoreShopTab({super.key});

  @override
  ConsumerState<StoreShopTab> createState() => _StoreShopTabState();
}

class _StoreShopTabState extends ConsumerState<StoreShopTab> {
  static const double _cardAspectRatio = 0.78;

  bool _isBuyingPool = false;

  void _onRegularItemBuy(StoreItem item) {
    showDialog(
      context: context,
      builder: (ctx) => StoreBuyDialog(
        item: item,
        t: ref.read(currentThemeProvider),
        balance: ref
            .read(jewelBalanceProvider)
            .maybeWhen(data: (j) => j.balance, orElse: () => 0),
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Future<void> _onPoolBuy(RewardPool pool) async {
    final t = ref.read(currentThemeProvider);
    final balance = ref
        .read(jewelBalanceProvider)
        .maybeWhen(data: (j) => j.balance, orElse: () => 0);

    setState(() => _isBuyingPool = true);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          MysteryBoxBuyDialog(pool: pool, balance: balance, t: t),
    );
    if (mounted) setState(() => _isBuyingPool = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final itemsAsync = ref.watch(storeItemsProvider);
    final poolsAsync = ref.watch(rewardPoolsProvider);
    final balanceAsync = ref.watch(jewelBalanceProvider);
    final balance = balanceAsync.maybeWhen(
      data: (j) => j.balance,
      orElse: () => 0,
    );

    return itemsAsync.when(
      loading: () => StoreSkeleton(t: t, tabId: 0),
      error: (e, _) => ErrorBody(
        t: t,
        icon: iconForError(e),
        title: AppStrings.errLoadStoreItems,
        message: sanitizeErrorMessage(e),
      ),
      data: (items) {
        final pools = poolsAsync.maybeWhen(
          data: (p) => p,
          orElse: () => <RewardPool>[],
        );
        final regularItems = items
            .where((i) => i.type != 'mystery_box')
            .toList();
        final hasMysteryBoxes = pools.isNotEmpty;
        final hasRegularItems = regularItems.isNotEmpty;

        if (!hasMysteryBoxes && !hasRegularItems) {
          return StoreEmptyState(
            t: t,
            emoji: '🛒',
            title: 'Belum ada item tersedia',
            subtitle: 'Check back later untuk item baru!',
          );
        }

        final childWidgets = <Widget>[];
        if (hasMysteryBoxes) {
          childWidgets.addAll([
            Row(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    size: S.scale(context, 20),
                    color: t.accent,
                  ),
                ),
                SizedBox(width: S.scale(context, 8)),
                Text(
                  'Special Items',
                  style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: S.scale(context, 16),
                  ),
                ).animate().fadeIn(),
              ],
            ),
            SizedBox(height: S.scale(context, 12)),
            LayoutBuilder(
              builder: (_, constraints) {
                final cardWidth = constraints.maxWidth > 600 ? S.scale(context, 280) : S.scale(context, 240);
                return SizedBox(
                  height: S.scale(context, 300),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: pools.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(width: S.scale(context, 14)),
                    itemBuilder: (_, i) => SizedBox(
                      width: cardWidth,
                      height: S.scale(context, 300),
                      child: MysteryBoxCard(
                        pool: pools[i],
                        balance: balance,
                        isPending: _isBuyingPool,
                        onBuy: () => _onPoolBuy(pools[i]),
                        t: t,
                      ).animate().fadeIn(delay: (100 * i).ms),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: S.scale(context, 24)),
          ]);
        }

        if (hasRegularItems) {
          childWidgets.addAll([
            Row(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.shopping_cart_rounded,
                    size: S.scale(context, 16),
                    color: t.accent,
                  ),
                ),
                SizedBox(width: S.scale(context, 8)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Items',
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: S.scale(context, 16),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(),
            SizedBox(height: S.scale(context, 12)),
            LayoutBuilder(
              builder: (_, constraints) {
                final crossAxisCount = constraints.maxWidth > 600
                    ? (constraints.maxWidth > 900 ? 4 : 3)
                    : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: S.scale(context, 14),
                    crossAxisSpacing: S.scale(context, 14),
                    childAspectRatio: _cardAspectRatio,
                  ),
                  itemCount: regularItems.length,
                  itemBuilder: (_, i) => StoreCompactCard(
                    item: regularItems[i],
                    t: t,
                    ref: ref,
                    balance: balance,
                    onBuy: _onRegularItemBuy,
                  ).animate().fadeIn(delay: (60 * i).ms),
                );
              },
            ),
          ]);
        }

        return ListView.builder(
          padding: EdgeInsets.all(S.scale(context, 20)),
          itemCount: childWidgets.length,
          itemBuilder: (_, i) => childWidgets[i],
        );
      },
    );
  }
}