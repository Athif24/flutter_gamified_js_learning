import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../shared/presentation/providers/fetch_state_providers.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/store_provider.dart';
import '../providers/reward_pool_provider.dart';
import '../widgets/store_tab_btn.dart';
import '../widgets/store_shop_tab.dart';
import '../widgets/store_inventory_tab.dart';
import '../widgets/store_history_tab.dart';

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
        await ref.read(inventoryProvider.future);
        await ref.read(jewelBalanceProvider.future);
        await ref.read(jewelHistoryProvider.future);
        await ref.read(rewardPoolsProvider.future);
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
              padding: EdgeInsets.fromLTRB(
                S.scale(context, 20),
                S.scale(context, 16),
                S.scale(context, 20),
                0,
              ),
              color: t.bgPrimary,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(S.scale(context, 24)),
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
                              size: S.scale(context, 24),
                              color: t.primaryContent,
                            ),
                            SizedBox(width: S.scale(context, 10)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Store',
                                style: GoogleFonts.nunito(
                                  color: t.primaryContent,
                                  fontSize: S.scale(context, 24),
                                  fontWeight: FontWeight.w900,
                                ),
                              ).animate().fadeIn(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tukarkan jewels kamu dengan item-item berguna!',
                            style: GoogleFonts.nunito(
                              color: t.primaryContent.withValues(alpha: 0.8),
                              fontSize: S.scale(context, 14),
                            ),
                          ).animate().fadeIn(delay: 150.ms),
                        ),
                        SizedBox(height: S.scale(context, 14)),
                        jewelsAsync.when(
                          loading: () => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: S.scale(context, 20),
                              vertical: S.scale(context, 12),
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
                                Icon(
                                  Icons.diamond,
                                  size: S.scale(context, 24),
                                  color: t.info,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: S.scale(context, 60),
                                  height: S.scale(context, 24),
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
                            padding: EdgeInsets.symmetric(
                              horizontal: S.scale(context, 20),
                              vertical: S.scale(context, 12),
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
                                Icon(
                                  Icons.diamond,
                                  size: S.scale(context, 24),
                                  color: t.info,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '-',
                                  style: GoogleFonts.nunito(
                                    color: t.primaryContent,
                                    fontWeight: FontWeight.w900,
                                    fontSize: S.scale(context, 24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          data: (j) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: S.scale(context, 20),
                              vertical: S.scale(context, 12),
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
                                Icon(
                                  Icons.diamond,
                                  size: S.scale(context, 24),
                                  color: t.info,
                                ),
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
                                      fontSize: S.scale(context, 12),
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
                                    fontSize: S.scale(context, 12),
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
                  SizedBox(height: S.scale(context, 14)),

                  // Tabs
                  SizedBox(
                    height: S.scale(context, 40),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (_, __) =>
                          SizedBox(width: S.scale(context, 8)),
                      itemBuilder: (_, i) {
                        final icons = [
                          Icons.shopping_cart_rounded,
                          Icons.inventory_2_rounded,
                          Icons.history_rounded,
                        ];
                        final labels = ['Shop', 'Inventory', 'Jewel History'];
                        return StoreTabBtn(
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
                  SizedBox(height: S.scale(context, 10)),
                  Container(
                    height: S.scale(context, 2),
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
                  SizedBox(height: S.scale(context, 14)),
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
                  1 => const StoreInventoryTab(),
                  2 => const StoreHistoryTab(),
                  _ => const StoreShopTab(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}