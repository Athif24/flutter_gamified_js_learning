import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../shared/providers/gamification_providers.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../shared/presentation/providers/fetch_state_providers.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/store_provider.dart';
import '../providers/reward_pool_provider.dart';
import '../../data/models/store_model.dart';
import '../../data/models/reward_pool_model.dart';
import '../widgets/mystery_box_card.dart';
import '../widgets/mystery_box_buy_dialog.dart';
import '../widgets/mystery_box_reveal_overlay.dart';
import '../widgets/store_skeleton.dart';

// ════════════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════════════

String _fmtDateId(String iso) {
  if (iso.isEmpty) return '';
  try {
    final d = DateTime.parse(iso);
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}, '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return iso.substring(0, 10);
  }
}

const _typeBadgeColors = <String, Color>{
  'life_refill': Color(0xFFEF4444),
  'full_lives': Color(0xFFEF4444),
  'xp_boost': Color(0xFFF59E0B),
  'streak_freeze': Color(0xFF3B82F6),
  'double_xp': Color(0xFF8B5CF6),
  'mystery_box': Color(0xFFA855F7),
};

const _sourceBadgeColors = <String, Color>{
  'lesson': Color(0xFF22C55E),
  'quiz': Color(0xFF3B82F6),
  'badge': Color(0xFFF59E0B),
  'level_up': Color(0xFF8B5CF6),
  'event': Color(0xFFEC4899),
  'store': Color(0xFFEF4444),
  'admin': Color(0xFF6B7280),
  'mystery_box': Color(0xFFA855F7),
};

RewardPool? _findMatchingPool(List<RewardPool> pools, String storeItemName) {
  final name = storeItemName.toLowerCase();
  for (final p in pools) {
    final poolName = p.name.toLowerCase();
    if (poolName == name) return p;
  }
  for (final p in pools) {
    final poolName = p.name.toLowerCase();
    if (poolName.contains(name) || name.contains(poolName)) return p;
  }
  return null;
}

// ════════════════════════════════════════════════════════════════════════════
// MAIN STORE SCREEN
// ════════════════════════════════════════════════════════════════════════════

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen>
    with SilentRefreshMixin<StoreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _silentRefresh());
  }

  Future<void> _silentRefresh() async {
    final fetchState = ref.read(storeFetchProvider.notifier);
    if (!fetchState.shouldRefresh) return;

    silentFetch(
      fetch: () async {
        ref.invalidate(storeItemsProvider);
        ref.invalidate(inventoryProvider);
        ref.invalidate(jewelBalanceProvider);
        ref.invalidate(jewelHistoryProvider);
        ref.invalidate(rewardPoolsProvider);
        await ref.read(storeItemsProvider.future);
      },
      fetchState: fetchState,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(navIndexProvider, (prev, next) {
      if (prev != null && prev != 3 && next == 3) {
        ref.invalidate(storeItemsProvider);
        ref.invalidate(inventoryProvider);
        ref.invalidate(jewelBalanceProvider);
        ref.invalidate(jewelHistoryProvider);
        ref.invalidate(rewardPoolsProvider);
        _silentRefresh();
      }
    });

    final t = ref.watch(currentThemeProvider);
    final tabIdx = ref.watch(storeTabProvider);
    final jewelsAsync = ref.watch(jewelBalanceProvider);
    final profileAsync = ref.watch(profileProvider);
    final maxJewels = profileAsync.maybeWhen(
      data: (p) => p.maxJewels,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            SlowLoadingIndicator(visible: showSlowIndicator, t: t),
            // ── Header ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              color: t.bgPrimary,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: t.primary,
                      borderRadius: BorderRadius.circular(24),
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
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_cart_rounded,
                              size: 24,
                              color: t.primaryContent,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Store',
                              style: GoogleFonts.nunito(
                                color: t.primaryContent,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ).animate().fadeIn(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tukarkan jewels kamu dengan item-item berguna!',
                            style: GoogleFonts.nunito(
                              color: t.primaryContent.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ).animate().fadeIn(delay: 150.ms),
                        ),
                        const SizedBox(height: 14),
                        jewelsAsync.when(
                          loading: () => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: t.primaryContent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: t.primaryContent.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.diamond, size: 24, color: t.info),
                                const SizedBox(width: 8),
                                Container(
                                  width: 60,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: t.primaryContent.withValues(
                                      alpha: 0.3,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          error: (_, __) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: t.primaryContent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: t.primaryContent.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.diamond, size: 24, color: t.info),
                                const SizedBox(width: 8),
                                Text(
                                  '-',
                                  style: GoogleFonts.nunito(
                                    color: t.primaryContent,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          data: (j) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: t.primaryContent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: t.primaryContent.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.diamond, size: 24, color: t.info),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      formatNumber(j.balance),
                                      style: GoogleFonts.nunito(
                                        color: t.primaryContent,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (maxJewels > 0) ...[
                                  Text(
                                    '/ ${formatNumber(maxJewels)}',
                                    style: GoogleFonts.nunito(
                                      color: t.primaryContent.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  'JEWELS',
                                  style: GoogleFonts.nunito(
                                    color: t.primaryContent.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 100.ms),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tabs
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final icons = [
                          Icons.shopping_cart_rounded,
                          Icons.inventory_2_rounded,
                          Icons.history_rounded,
                        ];
                        final labels = ['Shop', 'Inventory', 'Jewel History'];
                        return _TabBtn(
                          t: t,
                          icon: icons[i],
                          label: labels[i],
                          idx: i,
                          cur: tabIdx,
                          ref: ref,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: t.border.withAlpha(80),
                      boxShadow: [
                        BoxShadow(
                          color: t.textPrimary,
                          offset: const Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(storeItemsProvider);
                  ref.invalidate(inventoryProvider);
                  ref.invalidate(jewelBalanceProvider);
                  ref.invalidate(jewelHistoryProvider);
                  ref.invalidate(rewardPoolsProvider);
                  await _silentRefresh();
                },
                child: switch (tabIdx) {
                  1 => const _InventoryTab(),
                  2 => const _JewelHistoryTab(),
                  _ => const _ShopTab(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBtn extends ConsumerWidget {
  final BloomTheme t;
  final IconData icon;
  final String label;
  final int idx, cur;
  final WidgetRef ref;
  const _TabBtn({
    required this.t,
    required this.icon,
    required this.label,
    required this.idx,
    required this.cur,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final sel = idx == cur;
    return Bounceable(
      onTap: () => ref.read(storeTabProvider.notifier).state = idx,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? t.primary : t.bgSurface,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: t.textPrimary, width: 2),
          boxShadow: [
            BoxShadow(
              color: t.textPrimary,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: sel ? t.primaryContent : t.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: sel ? t.primaryContent : t.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SHOP TAB
// ════════════════════════════════════════════════════════════════════════════

class _ShopTab extends ConsumerStatefulWidget {
  const _ShopTab();

  @override
  ConsumerState<_ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends ConsumerState<_ShopTab> {
  bool _isBuyingPool = false;

  void _onRegularItemBuy(StoreItem item) {
    showDialog(
      context: context,
      builder: (ctx) => _BuyDialog(
        item: item,
        t: ref.read(currentThemeProvider),
        ref: ref,
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

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => MysteryBoxBuyDialog(
        pool: pool,
        balance: balance,
        isPending: _isBuyingPool,
        onClose: () => Navigator.of(ctx).pop(false),
        onConfirm: () => Navigator.of(ctx).pop(true),
        t: t,
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isBuyingPool = true);
    try {
      final result = await ref.read(rewardPoolDsProvider).buyPool(pool.id);
      invalidateGamificationProviders(ref);
      ref.invalidate(storeItemsProvider);
      ref.invalidate(inventoryProvider);
      ref.invalidate(rewardPoolsProvider);
      ref.invalidate(jewelBalanceProvider);
      ref.invalidate(jewelHistoryProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Berhasil membeli ${pool.name}!',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          backgroundColor: t.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sanitizeErrorMessage(e),
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: t.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isBuyingPool = false);
    }
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
          return _EmptyState(
            t: t,
            emoji: '🛒',
            title: 'Belum ada item tersedia',
            subtitle: 'Check back later untuk item baru!',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── SPECIAL ITEMS: Horizontal Carousel ──
            if (hasMysteryBoxes) ...[
              Row(
                children: [
                  Icon(Icons.card_giftcard_rounded, size: 20, color: t.accent),
                  const SizedBox(width: 8),
                  Text(
                    'Special Items',
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (_, constraints) {
                  final cardWidth = constraints.maxWidth > 600 ? 280.0 : 240.0;
                  return SizedBox(
                    height: 300,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: pools.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (_, i) => SizedBox(
                        width: cardWidth,
                        height: 300,
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
              const SizedBox(height: 24),
            ],

            // ── ITEMS: Responsive Grid ──
            if (hasRegularItems) ...[
              Text(
                'Items',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 12),
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
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: regularItems.length,
                    itemBuilder: (_, i) => _CompactShopCard(
                      item: regularItems[i],
                      t: t,
                      ref: ref,
                      balance: balance,
                      onBuy: _onRegularItemBuy,
                    ).animate().fadeIn(delay: (60 * i).ms),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// COMPACT SHOP CARD (2-column grid)
// ════════════════════════════════════════════════════════════════════════════

class _CompactShopCard extends ConsumerWidget {
  final StoreItem item;
  final BloomTheme t;
  final WidgetRef ref;
  final int balance;
  final void Function(StoreItem) onBuy;

  const _CompactShopCard({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + badge row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: t.bgSurface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: t.textPrimary, width: 1.5),
                ),
                child: Center(
                  child: item.icon.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: item.icon,
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => Icon(
                            Icons.inventory_2_rounded,
                            size: 22,
                            color: t.mutedText,
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.inventory_2_rounded,
                            size: 22,
                            color: t.mutedText,
                          ),
                        )
                      : Text(item.icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: (_typeBadgeColors[item.type] ?? t.mutedText)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: (_typeBadgeColors[item.type] ?? t.mutedText)
                        .withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  itemTypeLabels[item.type] ?? item.type,
                  style: GoogleFonts.nunito(
                    color: _typeBadgeColors[item.type] ?? t.mutedText,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Name
          Text(
            item.name,
            style: GoogleFonts.nunito(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),

          // Description (compact)
          if (item.description != null && item.description!.isNotEmpty)
            Text(
              item.description!,
              style: GoogleFonts.nunito(color: t.mutedText, fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else
            Text(
              itemTypeDescriptions[item.type] ?? '',
              style: GoogleFonts.nunito(color: t.mutedText, fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const Spacer(),

          // Price + Buy button
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.diamond, size: 12, color: t.info),
                  const SizedBox(width: 3),
                  Text(
                    formatNumber(item.price),
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Semantics(
                label: canAfford ? 'Beli ${item.name}' : 'Saldo Tidak Cukup',
                child: Bounceable(
                  onTap: canAfford ? () => onBuy(item) : null,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: canAfford ? t.primary : t.bgSurface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: t.textPrimary, width: 2),
                      boxShadow: canAfford
                          ? [
                              BoxShadow(
                                color: t.textPrimary,
                                offset: const Offset(3, 3),
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
                          size: 14,
                          color: canAfford ? t.primaryContent : t.mutedText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Beli',
                          style: GoogleFonts.nunito(
                            color: canAfford ? t.primaryContent : t.mutedText,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
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

// ════════════════════════════════════════════════════════════════════════════
// BUY DIALOG
// ════════════════════════════════════════════════════════════════════════════

class _BuyDialog extends ConsumerWidget {
  final StoreItem item;
  final BloomTheme t;
  final WidgetRef ref;
  final int balance;
  final VoidCallback onDismiss;

  const _BuyDialog({
    required this.item,
    required this.t,
    required this.ref,
    required this.balance,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = balance - item.price;

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
              child: Text(
                'Konfirmasi Pembelian',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pastikan kamu yakin dengan pembelian ini. Jewels tidak bisa dikembalikan.',
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
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: t.bgSurface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: t.textPrimary,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: item.icon.startsWith('http')
                                      ? CachedNetworkImage(
                                          imageUrl: item.icon,
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.contain,
                                          placeholder: (_, __) => Icon(
                                            Icons.inventory_2_rounded,
                                            size: 24,
                                            color: t.mutedText,
                                          ),
                                          errorWidget: (_, __, ___) => Icon(
                                            Icons.inventory_2_rounded,
                                            size: 24,
                                            color: t.mutedText,
                                          ),
                                        )
                                      : Text(
                                          item.icon,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: GoogleFonts.nunito(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      itemTypeLabels[item.type] ?? item.type,
                                      style: GoogleFonts.nunito(
                                        color: t.mutedText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _infoRow(
                            'Harga',
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.diamond, size: 14, color: t.info),
                                const SizedBox(width: 4),
                                Text(
                                  '-${formatNumber(item.price)}',
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
                          _infoRow(
                            'Balance saat ini',
                            Text(
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
                          _infoRow(
                            'Sisa balance',
                            Text(
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
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        item.description!,
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
                  Bounceable(
                    onTap: onDismiss,
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
                  Bounceable(
                    onTap: remaining < 0
                        ? null
                        : () async {
                            try {
                              await ref.read(storeDsProvider).buyItem(item.id);
                              invalidateGamificationProviders(ref);
                              ref.invalidate(storeItemsProvider);
                              ref.invalidate(inventoryProvider);
                              ref.invalidate(jewelBalanceProvider);
                              ref.invalidate(jewelHistoryProvider);
                              if (context.mounted) {
                                final messenger = ScaffoldMessenger.of(context);
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                final messenger = ScaffoldMessenger.of(context);
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
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
                        color: remaining >= 0 ? t.primary : t.bgSurface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: t.textPrimary, width: 2),
                        boxShadow: remaining >= 0
                            ? [
                                BoxShadow(
                                  color: t.textPrimary,
                                  offset: const Offset(3, 3),
                                  blurRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        remaining >= 0
                            ? AppStrings.buyNow
                            : AppStrings.insufficientBalance,
                        style: GoogleFonts.nunito(
                          color: remaining >= 0
                              ? t.primaryContent
                              : t.mutedText,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
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

  Widget _infoRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            color: t.mutedText,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        value,
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// INVENTORY TAB
// ════════════════════════════════════════════════════════════════════════════

class _InventoryTab extends ConsumerStatefulWidget {
  const _InventoryTab();

  @override
  ConsumerState<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends ConsumerState<_InventoryTab> {
  Future<void> _openMysteryBox(
    InventoryItem invItem,
    StoreItem storeItem,
  ) async {
    final t = ref.read(currentThemeProvider);
    final pools = ref
        .read(rewardPoolsProvider)
        .maybeWhen(data: (p) => p, orElse: () => <RewardPool>[]);

    final pool = _findMatchingPool(pools, storeItem.name);

    if (pool == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pool tidak ditemukan untuk ${storeItem.name}',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: t.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    final selectedPool = pool;
    final buildContext = context;

    Future<void> showOverlay() async {
      final result = await ref
          .read(rewardPoolDsProvider)
          .openPool(selectedPool.id);
      if (!buildContext.mounted) return;

      // Invalidate inventory to get updated quantity
      ref.invalidate(inventoryProvider);

      // Check if user can open again based on updated quantity
      final canOpenAgain = await _checkCanOpenAgain(selectedPool.name);

      if (!buildContext.mounted) return;

      // Navigate to full screen overlay
      await Navigator.of(buildContext).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => MysteryBoxRevealOverlay(
            result: result,
            poolName: selectedPool.name,
            poolIcon: selectedPool.icon,
            onDismiss: () => Navigator.of(buildContext).pop(),
            onOpenAgain: showOverlay,
            canOpenAgain: canOpenAgain,
            t: t,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }

    try {
      await showOverlay();

      // Refresh after overlay closes
      if (mounted) {
        ref.invalidate(inventoryProvider);
        ref.invalidate(jewelBalanceProvider);
        ref.invalidate(jewelHistoryProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sanitizeErrorMessage(e),
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
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
  }

  Future<bool> _checkCanOpenAgain(String poolName) async {
    try {
      final inventory = await ref.read(inventoryProvider.future);
      return inventory.any(
        (inv) =>
            inv.item?.type == 'mystery_box' &&
            inv.item?.name == poolName &&
            inv.quantity > 0,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final invAsync = ref.watch(inventoryProvider);

    return Stack(
      children: [
        invAsync.when(
          loading: () => StoreSkeleton(t: t, tabId: 1),
          error: (_, __) => ErrorBody(
            t: t,
            title: AppStrings.errLoadInventory,
          ),
          data: (items) {
            final sorted = List<InventoryItem>.from(items)
              ..sort((a, b) {
                if (a.acquiredAt == null && b.acquiredAt == null) return 0;
                if (a.acquiredAt == null) return 1;
                if (b.acquiredAt == null) return -1;
                return b.acquiredAt!.compareTo(a.acquiredAt!);
              });
            return sorted.isEmpty
                ? _EmptyState(
                    t: t,
                    emoji: '📦',
                    title: 'Inventori kosong',
                    subtitle: 'Beli item di Shop untuk mulai mengumpulkan!',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: sorted.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _InventoryCard(
                        item: sorted[i],
                        t: t,
                        ref: ref,
                        onUse: (inv, si) {
                          final storeItem = inv.item;
                          if (storeItem == null) return;
                          showDialog(
                            context: context,
                            builder: (ctx) => _UseDialog(
                              invItem: inv,
                              storeItem: storeItem,
                              t: t,
                              ref: ref,
                            ),
                          );
                        },
                        onOpenMysteryBox: _openMysteryBox,
                      ).animate().fadeIn(delay: (80 * i).ms),
                    ),
                  );
          },
        ),
      ],
    );
  }
}

class _InventoryCard extends ConsumerWidget {
  final InventoryItem item;
  final BloomTheme t;
  final WidgetRef ref;
  final void Function(InventoryItem, StoreItem) onUse;
  final void Function(InventoryItem, StoreItem) onOpenMysteryBox;

  const _InventoryCard({
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
      padding: const EdgeInsets.all(20),
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
        borderRadius: BorderRadius.circular(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: t.bgSurface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: t.textPrimary, width: 1.5),
                ),
                child: Center(
                  child: storeItem.icon.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: storeItem.icon,
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => Icon(
                            Icons.inventory_2_rounded,
                            size: 28,
                            color: t.mutedText,
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.inventory_2_rounded,
                            size: 28,
                            color: t.mutedText,
                          ),
                        )
                      : Text(
                          storeItem.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: typeColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      itemTypeLabels[storeItem.type] ?? storeItem.type,
                      style: GoogleFonts.nunito(
                        color: typeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: t.textPrimary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'x${item.quantity}',
                      style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            storeItem.name,
            style: GoogleFonts.nunito(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _itemEffectDesc(storeItem),
            style: GoogleFonts.nunito(color: t.mutedText, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: t.textPrimary.withValues(alpha: 0.1)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Diperoleh: ${_fmtDateId(item.acquiredAt ?? '')}',
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (canUse)
                Semantics(
                  label: isMysteryBox
                      ? 'Buka Mystery Box'
                      : 'Gunakan ${storeItem.name}',
                  child: Bounceable(
                    onTap: () => isMysteryBox
                        ? _onOpenMysteryBox(context)
                        : _onUse(context),
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: t.primary,
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isMysteryBox
                                ? Icons.card_giftcard_rounded
                                : Icons.bolt_rounded,
                            size: 14,
                            color: t.primaryContent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isMysteryBox ? 'Buka' : 'Gunakan',
                            style: GoogleFonts.nunito(
                              color: t.primaryContent,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: t.textPrimary, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.block_rounded, size: 14, color: t.mutedText),
                      const SizedBox(width: 4),
                      Text(
                        storeItem.isConsumable
                            ? 'Habis'
                            : 'Tidak bisa digunakan',
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
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

class _UseDialog extends ConsumerWidget {
  final InventoryItem invItem;
  final StoreItem storeItem;
  final BloomTheme t;
  final WidgetRef ref;

  const _UseDialog({
    required this.invItem,
    required this.storeItem,
    required this.t,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = invItem.quantity - 1;

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
              child: Text(
                'Gunakan Item?',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item ini akan digunakan dan quantity akan berkurang 1.',
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
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: t.bgSurface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: t.textPrimary,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: storeItem.icon.startsWith('http')
                                      ? CachedNetworkImage(
                                          imageUrl: storeItem.icon,
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.contain,
                                          placeholder: (_, __) => Icon(
                                            Icons.inventory_2_rounded,
                                            size: 24,
                                            color: t.mutedText,
                                          ),
                                          errorWidget: (_, __, ___) => Icon(
                                            Icons.inventory_2_rounded,
                                            size: 24,
                                            color: t.mutedText,
                                          ),
                                        )
                                      : Text(
                                          storeItem.icon,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      storeItem.name,
                                      style: GoogleFonts.nunito(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      itemTypeLabels[storeItem.type] ??
                                          storeItem.type,
                                      style: GoogleFonts.nunito(
                                        color: t.mutedText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _infoRow(
                            'Efek',
                            Text(
                              _useEffectDesc(),
                              textAlign: TextAlign.right,
                              style: GoogleFonts.nunito(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Divider(
                            height: 20,
                            color: t.textPrimary.withValues(alpha: 0.1),
                          ),
                          _infoRow(
                            'Quantity setelah pakai',
                            Text(
                              '${invItem.quantity - 1}',
                              style: GoogleFonts.nunito(
                                color: remaining >= 0 ? t.textPrimary : t.error,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (storeItem.description != null &&
                        storeItem.description!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        storeItem.description!,
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Bounceable(
                    onTap: () => Navigator.of(context).pop(),
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
                  if (remaining >= 0) ...[
                    const SizedBox(width: 12),
                    Bounceable(
                      onTap: () async {
                        try {
                          await ref
                              .read(storeDsProvider)
                              .useItem(invItem.itemId.toString());
                          ref.invalidate(inventoryProvider);
                          ref.invalidate(jewelBalanceProvider);
                          ref.invalidate(storeItemsProvider);
                          if (context.mounted) {
                            final messenger = ScaffoldMessenger.of(context);
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            final messenger = ScaffoldMessenger.of(context);
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: t.primary,
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
                          'Gunakan',
                          style: GoogleFonts.nunito(
                            color: t.primaryContent,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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

  Widget _infoRow(String label, Widget value) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            color: t.mutedText,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: value),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// JEWEL HISTORY TAB
// ════════════════════════════════════════════════════════════════════════════

class _JewelHistoryTab extends ConsumerStatefulWidget {
  const _JewelHistoryTab();

  @override
  ConsumerState<_JewelHistoryTab> createState() => _JewelHistoryTabState();
}

class _JewelHistoryTabState extends ConsumerState<_JewelHistoryTab> {
  String _sourceFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final histAsync = ref.watch(jewelHistoryProvider);

    final allTx = histAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <JewelTransaction>[],
    );
    final filtered = _sourceFilter == 'all'
        ? allTx
        : allTx.where((tx) => tx.source == _sourceFilter).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // Dropdown filter
          Row(
            children: [
              Icon(Icons.filter_alt_rounded, size: 16, color: t.mutedText),
              const SizedBox(width: 6),
              Text(
                'Filter:',
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: t.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: t.textPrimary, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sourceFilter,
                    isDense: true,
                    dropdownColor: t.bgSurface,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'all',
                        child: Text('Semua Source'),
                      ),
                      ...jewelSourceLabels.entries.map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _sourceFilter = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child: histAsync.when(
              loading: () => StoreSkeleton(t: t, tabId: 2),
              error: (_, __) => ErrorBody(
                t: t,
                title: 'Belum ada riwayat',
              ),
              data: (list) {
                if (list.isEmpty) {
                  return _EmptyState(
                    t: t,
                    emoji: '📜',
                    title: 'Belum ada riwayat transaksi',
                    subtitle: 'Transaksi jewels kamu akan muncul di sini',
                  );
                }
                if (filtered.isEmpty) {
                  return _EmptyState(
                    t: t,
                    emoji: '🔍',
                    title: 'Tidak ada transaksi',
                    subtitle: '',
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.bgSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.textPrimary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.textPrimary,
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(t.bgSurface2),
                        columnSpacing: 24,
                        dataRowMinHeight: 44,
                        dataRowMaxHeight: 56,
                        columns: [
                          DataColumn(
                            label: Text(
                              'Tanggal',
                              style: GoogleFonts.nunito(
                                color: t.mutedText,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Source',
                              style: GoogleFonts.nunito(
                                color: t.mutedText,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Amount',
                              style: GoogleFonts.nunito(
                                color: t.mutedText,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text(
                              'Balance After',
                              style: GoogleFonts.nunito(
                                color: t.mutedText,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            numeric: true,
                          ),
                        ],
                        rows: filtered.map((tx) {
                          final isEarn = tx.amount >= 0;
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  _fmtDateId(tx.createdAt),
                                  style: GoogleFonts.nunito(
                                    color: t.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (_sourceBadgeColors[tx.source] ??
                                                t.mutedText)
                                            .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    jewelSourceLabels[tx.source] ?? tx.source,
                                    style: GoogleFonts.nunito(
                                      color:
                                          _sourceBadgeColors[tx.source] ??
                                          t.mutedText,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${isEarn ? '+' : ''}${formatNumber(tx.amount)}',
                                  style: GoogleFonts.nunito(
                                    color: isEarn ? t.success : t.error,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.diamond,
                                      size: 14,
                                      color: t.info,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      formatNumber(tx.balanceAfter ?? 0),
                                      style: GoogleFonts.nunito(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SHARED
// ════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final BloomTheme t;
  final String emoji, title, subtitle;
  const _EmptyState({
    required this.t,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 14),
        Text(
          title,
          style: GoogleFonts.nunito(
            color: t.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.nunito(color: t.mutedText, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    ),
  );
}
