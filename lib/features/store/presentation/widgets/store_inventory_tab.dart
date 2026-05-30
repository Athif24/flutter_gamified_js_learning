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
import '../widgets/mystery_box_reveal_overlay.dart';
import '../widgets/store_skeleton.dart';
import '../widgets/store_empty_state.dart';
import '../widgets/store_inventory_card.dart';
import '../widgets/store_dialogs.dart';

class StoreInventoryTab extends ConsumerStatefulWidget {
  const StoreInventoryTab({super.key});

  @override
  ConsumerState<StoreInventoryTab> createState() => _StoreInventoryTabState();
}

class _StoreInventoryTabState extends ConsumerState<StoreInventoryTab> {
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
              borderRadius: BorderRadius.circular(S.scale(context, 12)),
            ),
          ),
        );
      }
      return;
    }

    final buildContext = context;

    Future<void> showOverlay() async {
      final result = await ref.read(rewardPoolDsProvider).openPool(pool.id);
      if (!buildContext.mounted) return;

      // Invalidate inventory to get updated quantity
      ref.invalidate(inventoryProvider);

      // Check if user can open again based on updated quantity
      final canOpenAgain = await _checkCanOpenAgain(pool.name);

      if (!buildContext.mounted) return;

      // Navigate to full screen overlay
      await Navigator.of(buildContext).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => MysteryBoxRevealOverlay(
            result: result,
            poolName: pool.name,
            poolIcon: pool.icon,
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
              borderRadius: BorderRadius.circular(S.scale(context, 12)),
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
          error: (_, __) => ErrorBody(t: t, title: AppStrings.errLoadInventory),
          data: (items) {
            final sorted = List<InventoryItem>.from(items)
              ..sort((a, b) {
                if (a.acquiredAt == null && b.acquiredAt == null) return 0;
                if (a.acquiredAt == null) return 1;
                if (b.acquiredAt == null) return -1;
                return b.acquiredAt!.compareTo(a.acquiredAt!);
              });
            return sorted.isEmpty
                ? StoreEmptyState(
                    t: t,
                    emoji: '📦',
                    title: 'Inventori kosong',
                    subtitle: 'Beli item di Shop untuk mulai mengumpulkan!',
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(S.scale(context, 20)),
                    itemCount: sorted.length,
                    itemBuilder: (_, i) => Padding(
                      padding: EdgeInsets.only(bottom: S.scale(context, 14)),
                      child: StoreInventoryCard(
                        item: sorted[i],
                        t: t,
                        ref: ref,
                        onUse: (inv, si) {
                          final storeItem = inv.item;
                          if (storeItem == null) return;
                          showDialog(
                            context: context,
                            builder: (ctx) => StoreUseDialog(
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