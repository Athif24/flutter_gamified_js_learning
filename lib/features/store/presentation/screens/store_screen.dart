import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/loading_circle.dart';
import '../../../../shared/providers/gamification_providers.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/store_provider.dart';
import '../../data/models/store_model.dart';

// ════════════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════════════

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

String _fmtDateId(String iso) {
  if (iso.isEmpty) return '';
  try {
    final d = DateTime.parse(iso);
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
               'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${m[d.month - 1]} ${d.year}, '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return iso.substring(0, 10);
  }
}

const _typeBadgeColors = <String, Color>{
  'life_refill': Color(0xFFEF4444),
  'full_lives': Color(0xFFEF4444),
  'streak_freeze': Color(0xFF3B82F6),
  'power_up': Color(0xFFF59E0B),
  'cosmetic': Color(0xFF8B5CF6),
};

const _sourceBadgeColors = <String, Color>{
  'lesson': Color(0xFF22C55E),
  'quiz': Color(0xFF3B82F6),
  'badge': Color(0xFFF59E0B),
  'level_up': Color(0xFF8B5CF6),
  'event': Color(0xFFEC4899),
  'store': Color(0xFFEF4444),
  'admin': Color(0xFF6B7280),
};

// ════════════════════════════════════════════════════════════════════════════
// MAIN STORE SCREEN
// ════════════════════════════════════════════════════════════════════════════

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<int>(navIndexProvider, (prev, next) {
      if (prev != null && prev != 3 && next == 3) {
        ref.invalidate(storeItemsProvider);
        ref.invalidate(inventoryProvider);
        ref.invalidate(jewelBalanceProvider);
        ref.invalidate(jewelHistoryProvider);
      }
    });

    final t           = ref.watch(currentThemeProvider);
    final tabIdx      = ref.watch(storeTabProvider);
    final jewelsAsync = ref.watch(jewelBalanceProvider);
    final profileAsync = ref.watch(profileProvider);
    final maxJewels   = profileAsync.maybeWhen(
      data: (p) => p.maxJewels, orElse: () => 10000,
    );

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(child: Column(children: [
        // ── Header ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          color: t.bgPrimary,
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [t.accent.withValues(alpha: 0.25), t.info.withValues(alpha: 0.12)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: t.textPrimary.withValues(alpha: 0.25), width: 2),
                boxShadow: [
                  BoxShadow(color: t.border, offset: const Offset(4, 4), blurRadius: 0),
                ],
              ),
              child: Stack(children: [
                Positioned(right: -48, top: -48,
                  child: Container(width: 192, height: 192,
                    decoration: BoxDecoration(
                      color: t.bgSurface.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                Positioned(left: -32, bottom: -32,
                  child: Container(width: 128, height: 128,
                    decoration: BoxDecoration(
                      color: t.textHint.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                Column(children: [
                  Row(children: [
                    Icon(Icons.shopping_cart_rounded, size: 24, color: t.accentText),
                    const SizedBox(width: 10),
                    Text('Store', style: GoogleFonts.nunito(
                        color: t.accentText, fontSize: 24,
                        fontWeight: FontWeight.w900))
                        .animate().fadeIn(),
                  ]),
                  const SizedBox(height: 4),
                  Align(alignment: Alignment.centerLeft,
                    child: Text('Tukarkan jewels kamu dengan item-item berguna!',
                        style: GoogleFonts.nunito(
                            color: t.accentText.withValues(alpha: 0.8), fontSize: 14))
                        .animate().fadeIn(delay: 150.ms),
                  ),
                  const SizedBox(height: 14),
                  jewelsAsync.maybeWhen(
                    data: (j) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: t.bgSurface.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.accentText.withValues(alpha: 0.15)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.diamond, size: 24, color: Color(0xFF60A5FA)),
                        const SizedBox(width: 8),
                        Flexible(child: Text(
                          _fmt(j.balance),
                          style: GoogleFonts.nunito(
                            color: t.accentText,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )),
                        const SizedBox(width: 4),
                        Text('/ ${_fmt(maxJewels)}',
                            style: GoogleFonts.nunito(
                              color: t.accentText.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            )),
                        const SizedBox(width: 8),
                        Text('JEWELS', style: GoogleFonts.nunito(
                            color: t.accentText.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 1.2)),
                      ]),
                    ).animate().fadeIn(delay: 100.ms),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ]),
              ]),
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
                    t: t, icon: icons[i], label: labels[i],
                    idx: i, cur: tabIdx, ref: ref,
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
                    color: t.border,
                    offset: const Offset(0, 1),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ]),
        ),

        // ── Content ────────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            onRefresh: () {
              ref.invalidate(storeItemsProvider);
              ref.invalidate(inventoryProvider);
              ref.invalidate(jewelBalanceProvider);
              ref.invalidate(jewelHistoryProvider);
              return Future<void>.value();
            },
            child: switch(tabIdx) {
              1     => const _InventoryTab(),
              2     => const _JewelHistoryTab(),
              _     => const _ShopTab(),
            },
          ),
        ),
      ])),
    );
  }
}

class _TabBtn extends ConsumerWidget {
  final BloomTheme t;
  final IconData icon;
  final String label;
  final int idx, cur;
  final WidgetRef ref;
  const _TabBtn({required this.t, required this.icon, required this.label,
    required this.idx, required this.cur, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final sel = idx == cur;
    return Bounceable(
      onTap: () => ref.read(storeTabProvider.notifier).state = idx,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? t.accent : t.bgSurface,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: t.textPrimary.withValues(alpha: 0.25), width: 2),
          boxShadow: [
            BoxShadow(
              color: t.border,
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: sel ? t.accentText : t.textPrimary),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.nunito(
            color: sel ? t.accentText : t.textPrimary,
            fontWeight: FontWeight.w800, fontSize: 14,
          )),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SHOP TAB
// ════════════════════════════════════════════════════════════════════════════

class _ShopTab extends ConsumerWidget {
  const _ShopTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);
    final itemsAsync = ref.watch(storeItemsProvider);
    final balanceAsync = ref.watch(jewelBalanceProvider);
    final balance = balanceAsync.maybeWhen(data: (j) => j.balance, orElse: () => 0);

    return itemsAsync.when(
      loading: () => LoadingCircle(t: t),
      error: (e, _) => _EmptyState(t: t,
          emoji: '🔧', title: 'Gagal memuat item',
          subtitle: e.toString().replaceAll('Exception: ', '')),
      data: (items) => items.isEmpty
          ? _EmptyState(t: t, emoji: '🛒',
              title: 'Belum ada item tersedia',
              subtitle: 'Check back later untuk item baru!')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ShopCard(item: items[i], t: t, ref: ref, balance: balance)
                    .animate().fadeIn(delay: (80 * i).ms),
              ),
            ),
    );
  }
}

class _ShopCard extends ConsumerWidget {
  final StoreItem item;
  final BloomTheme t;
  final WidgetRef ref;
  final int balance;

  const _ShopCard({
    required this.item, required this.t,
    required this.ref, required this.balance,
  });

  void _onBuy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _BuyDialog(item: item, t: t, ref: ref, balance: balance),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAfford = balance >= item.price;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.textPrimary.withValues(alpha: 0.25), width: 2),
        boxShadow: [
          BoxShadow(color: t.border, offset: const Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.textPrimary.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: item.icon.startsWith('http')
                  ? Image.network(item.icon, width: 32, height: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(Icons.inventory_2_rounded,
                          size: 28, color: t.textHint))
                  : Text(item.icon, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (_typeBadgeColors[item.type] ?? t.textHint).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: (_typeBadgeColors[item.type] ?? t.textHint).withValues(alpha: 0.35)),
            ),
            child: Text(
              itemTypeLabels[item.type] ?? item.type,
              style: GoogleFonts.nunito(
                color: _typeBadgeColors[item.type] ?? t.textHint,
                fontSize: 11, fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Text(item.name, style: GoogleFonts.nunito(
            color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        if (item.description != null && item.description!.isNotEmpty)
          Text(item.description!, style: GoogleFonts.nunito(
              color: t.textSecondary, fontSize: 12),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        if (item.effectValue != null && item.effectValue! > 0) ...[
          const SizedBox(height: 2),
          Text('Effect: +${item.effectValue}', style: GoogleFonts.nunito(
              color: t.textHint, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 12),
        Divider(height: 1, color: t.textPrimary.withValues(alpha: 0.1)),
        const SizedBox(height: 10),
        Row(children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.diamond, size: 16, color: Color(0xFF60A5FA)),
            const SizedBox(width: 4),
            Text(_fmt(item.price), style: GoogleFonts.nunito(
                color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
          ]),
          const Spacer(),
          if (item.ownedQuantity > 0)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text('Owned: ${item.ownedQuantity}', style: GoogleFonts.nunito(
                  color: t.textHint, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          Bounceable(
            onTap: canAfford ? () => _onBuy(context) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: canAfford ? t.accent : t.bgSurface2,
                borderRadius: BorderRadius.circular(50),
                boxShadow: canAfford
                    ? [BoxShadow(color: t.border, offset: const Offset(2, 2), blurRadius: 0)]
                    : null,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shopping_cart_rounded, size: 14,
                    color: canAfford ? t.accentText : t.textHint),
                const SizedBox(width: 4),
                Text('Beli', style: GoogleFonts.nunito(
                  color: canAfford ? t.accentText : t.textHint,
                  fontWeight: FontWeight.w800, fontSize: 12,
                )),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _BuyDialog extends ConsumerWidget {
  final StoreItem item;
  final BloomTheme t;
  final WidgetRef ref;
  final int balance;

  const _BuyDialog({
    required this.item, required this.t,
    required this.ref, required this.balance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = balance - item.price;

    return AlertDialog(
      backgroundColor: t.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: t.textPrimary.withValues(alpha: 0.25), width: 2)),
      title: Text('Konfirmasi Pembelian', style: GoogleFonts.nunito(
            color: t.textPrimary, fontWeight: FontWeight.w900, fontSize: 18)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text('Pastikan kamu yakin dengan pembelian ini. Jewels tidak bisa dikembalikan.',
            style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.bgPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: t.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: t.textPrimary.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: item.icon.startsWith('http')
                      ? Image.network(item.icon, width: 28, height: 28, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(Icons.inventory_2_rounded, size: 24,
                              color: t.textHint))
                      : Text(item.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: GoogleFonts.nunito(
                      color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(itemTypeLabels[item.type] ?? item.type, style: GoogleFonts.nunito(
                      color: t.textSecondary, fontSize: 12)),
                ],
              )),
            ]),
            const SizedBox(height: 14),
            _infoRow('Harga',
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.diamond, size: 14, color: Color(0xFF60A5FA)),
                const SizedBox(width: 4),
                Text('-${_fmt(item.price)}', style: GoogleFonts.nunito(
                    color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 8),
            _infoRow('Balance saat ini',
              Text(_fmt(balance), style: GoogleFonts.nunito(
                  color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
            Divider(height: 20, color: t.textPrimary.withValues(alpha: 0.1)),
            _infoRow('Sisa balance',
              Text(_fmt(remaining), style: GoogleFonts.nunito(
                  color: remaining >= 0 ? const Color(0xFF60A5FA) : t.error,
                  fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ]),
        ),
        if (item.description != null && item.description!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(item.description!, style: GoogleFonts.nunito(
              color: t.textSecondary, fontSize: 13)),
        ],
      ]),
      actions: [
        Bounceable(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Batal', style: GoogleFonts.nunito(
                color: t.textHint, fontWeight: FontWeight.w700)),
          ),
        ),
        Bounceable(
          onTap: remaining < 0 ? null : () async {
            try {
              await ref.read(storeDsProvider).buyItem(item.id);
              invalidateGamificationProviders(ref);
              ref.invalidate(storeItemsProvider);
              ref.invalidate(inventoryProvider);
              if (context.mounted) {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(context).pop();
                messenger.showSnackBar(SnackBar(
                  content: Text('Berhasil membeli ${item.name}!',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  backgroundColor: t.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              }
            } catch (e) {
              if (context.mounted) {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(context).pop();
                messenger.showSnackBar(SnackBar(
                  content: Text(e.toString().replaceAll('Exception: ', ''),
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                  backgroundColor: t.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: remaining >= 0 ? t.accent : t.bgSurface2,
              borderRadius: BorderRadius.circular(50),
              boxShadow: remaining >= 0
                  ? [BoxShadow(color: t.border, offset: const Offset(2, 2), blurRadius: 0)]
                  : null,
            ),
            child: Text(
              remaining >= 0 ? 'Beli Sekarang' : 'Saldo Tidak Cukup',
              style: GoogleFonts.nunito(
                color: remaining >= 0 ? t.accentText : t.textHint,
                fontWeight: FontWeight.w800, fontSize: 13,
              )),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, Widget value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.nunito(
          color: t.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
      value,
    ]);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// INVENTORY TAB
// ════════════════════════════════════════════════════════════════════════════

class _InventoryTab extends ConsumerWidget {
  const _InventoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);
    final invAsync = ref.watch(inventoryProvider);

    return invAsync.when(
      loading: () => LoadingCircle(t: t),
      error: (_, __) => _EmptyState(t: t, emoji: '📦',
          title: 'Gagal memuat inventori', subtitle: ''),
      data: (items) => items.isEmpty
          ? _EmptyState(t: t, emoji: '📦',
              title: 'Inventori kosong',
              subtitle: 'Beli item di Shop untuk mulai mengumpulkan!')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _InventoryCard(item: items[i], t: t, ref: ref)
                    .animate().fadeIn(delay: (80 * i).ms),
              ),
            ),
    );
  }
}

class _InventoryCard extends ConsumerWidget {
  final InventoryItem item;
  final BloomTheme t;
  final WidgetRef ref;
  const _InventoryCard({required this.item, required this.t, required this.ref});

  void _onUse(BuildContext context) {
    final storeItem = item.item;
    if (storeItem == null) return;
    showDialog(
      context: context,
      builder: (ctx) => _UseDialog(invItem: item, storeItem: storeItem, t: t, ref: ref),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeItem = item.item;
    if (storeItem == null) return const SizedBox.shrink();

    final canUse = storeItem.isConsumable && item.quantity > 0;
    final typeColor = _typeBadgeColors[storeItem.type] ?? t.textHint;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.textPrimary.withValues(alpha: 0.25), width: 2),
        boxShadow: [
          BoxShadow(color: t.border, offset: const Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.textPrimary.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: storeItem.icon.startsWith('http')
                  ? Image.network(storeItem.icon, width: 32, height: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(Icons.inventory_2_rounded,
                          size: 28, color: t.textHint))
                  : Text(storeItem.icon, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: typeColor.withValues(alpha: 0.35)),
              ),
              child: Text(
                itemTypeLabels[storeItem.type] ?? storeItem.type,
                style: GoogleFonts.nunito(
                  color: typeColor,
                  fontSize: 11, fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: t.textPrimary.withValues(alpha: 0.25)),
              ),
              child: Text('x${item.quantity}',
                  style: GoogleFonts.nunito(
                      color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ]),
        ]),
        const SizedBox(height: 12),
        Text(storeItem.name, style: GoogleFonts.nunito(
            color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        Text(_itemEffectDesc(storeItem), style: GoogleFonts.nunito(
            color: t.textSecondary, fontSize: 12),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 12),
        Divider(height: 1, color: t.textPrimary.withValues(alpha: 0.1)),
        const SizedBox(height: 10),
        Row(children: [
          Text('Diperoleh: ${_fmtDateId(item.acquiredAt ?? '')}',
              style: GoogleFonts.nunito(color: t.textHint, fontSize: 10,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          if (canUse)
            Bounceable(
              onTap: () => _onUse(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: t.accent,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(color: t.border, offset: const Offset(2, 2), blurRadius: 0),
                  ],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.bolt, size: 14, color: t.accentText),
                  const SizedBox(width: 4),
                  Text('Gunakan', style: GoogleFonts.nunito(
                      color: t.accentText, fontWeight: FontWeight.w800, fontSize: 12)),
                ]),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                  color: t.bgSurface2, borderRadius: BorderRadius.circular(50)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.block_rounded, size: 14, color: t.textHint),
                const SizedBox(width: 4),
                Text(
                  storeItem.isConsumable ? 'Habis' : 'Tidak bisa digunakan',
                  style: GoogleFonts.nunito(
                      color: t.textHint, fontWeight: FontWeight.w800, fontSize: 11)),
              ]),
            ),
        ]),
      ]),
    );
  }

  String _itemEffectDesc(StoreItem si) {
    if (si.description != null && si.description!.isNotEmpty) return si.description!;
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
    required this.invItem, required this.storeItem,
    required this.t, required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = invItem.quantity - 1;

    return AlertDialog(
      backgroundColor: t.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: t.textPrimary.withValues(alpha: 0.25), width: 2)),
      title: Text('Gunakan Item?', style: GoogleFonts.nunito(
            color: t.textPrimary, fontWeight: FontWeight.w900, fontSize: 18)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        const SizedBox(height: 6),
        Text('Item ini akan digunakan dan quantity akan berkurang 1.',
            style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.bgPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: t.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: t.textPrimary.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: storeItem.icon.startsWith('http')
                      ? Image.network(storeItem.icon, width: 28, height: 28, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(Icons.inventory_2_rounded, size: 24,
                              color: t.textHint))
                      : Text(storeItem.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(storeItem.name, style: GoogleFonts.nunito(
                      color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(itemTypeLabels[storeItem.type] ?? storeItem.type, style: GoogleFonts.nunito(
                      color: t.textSecondary, fontSize: 12)),
                ],
              )),
            ]),
            const SizedBox(height: 14),
            _infoRow('Efek',
              Text(_useEffectDesc(),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.nunito(
                      color: t.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            Divider(height: 20, color: t.textPrimary.withValues(alpha: 0.1)),
            _infoRow('Quantity setelah pakai',
              Text('${invItem.quantity - 1}', style: GoogleFonts.nunito(
                  color: remaining >= 0 ? t.textPrimary : t.error,
                  fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ]),
        ),
        if (storeItem.description != null && storeItem.description!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(storeItem.description!, style: GoogleFonts.nunito(
              color: t.textSecondary, fontSize: 13)),
        ],
      ]),
      actions: [
        Bounceable(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Batal', style: GoogleFonts.nunito(
                color: t.textHint, fontWeight: FontWeight.w700)),
          ),
        ),
        if (remaining >= 0)
          Bounceable(
            onTap: () async {
              try {
                await ref.read(storeDsProvider).useItem(invItem.itemId.toString());
                ref.invalidate(inventoryProvider);
                ref.invalidate(jewelBalanceProvider);
                ref.invalidate(storeItemsProvider);
                if (context.mounted) {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.of(context).pop();
                  messenger.showSnackBar(SnackBar(
                    content: Text('Berhasil menggunakan ${storeItem.name}!',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                    backgroundColor: t.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                }
              } catch (e) {
                if (context.mounted) {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.of(context).pop();
                  messenger.showSnackBar(SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', ''),
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                    backgroundColor: t.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: t.accent,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(color: t.border, offset: const Offset(2, 2), blurRadius: 0),
                ],
              ),
              child: Text('Gunakan',
                style: GoogleFonts.nunito(
                  color: t.accentText, fontWeight: FontWeight.w800, fontSize: 13,
                )),
            ),
          ),
      ],
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
    return Row(children: [
      Text(label, style: GoogleFonts.nunito(
          color: t.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(width: 8),
      Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child: value,
        ),
      ),
    ]);
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
      data: (list) => list, orElse: () => <JewelTransaction>[],
    );
    final filtered = _sourceFilter == 'all'
        ? allTx
        : allTx.where((tx) => tx.source == _sourceFilter).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(children: [
        // Dropdown filter
        Row(children: [
          Icon(Icons.filter_alt_rounded, size: 16, color: t.textSecondary),
          const SizedBox(width: 6),
          Text('Filter:', style: GoogleFonts.nunito(
              color: t.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: t.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.textPrimary.withValues(alpha: 0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sourceFilter,
                isDense: true,
                dropdownColor: t.bgSurface,
                style: GoogleFonts.nunito(
                    color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('Semua Source')),
                  ...jewelSourceLabels.entries.map((e) =>
                    DropdownMenuItem(value: e.key, child: Text(e.value))),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _sourceFilter = v);
                },
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // Table
        Expanded(
          child: histAsync.when(
            loading: () => LoadingCircle(t: t),
            error: (_, __) => _EmptyState(t: t, emoji: '📜',
                title: 'Belum ada riwayat', subtitle: ''),
            data: (list) {
              if (list.isEmpty) {
                return _EmptyState(t: t, emoji: '📜',
                    title: 'Belum ada riwayat transaksi',
                    subtitle: 'Transaksi jewels kamu akan muncul di sini');
              }
              if (filtered.isEmpty) {
                return _EmptyState(t: t, emoji: '🔍',
                    title: 'Tidak ada transaksi', subtitle: '');
              }
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: t.bgSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: t.textPrimary.withValues(alpha: 0.25)),
                    ),
                    child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(t.bgSurface2),
                    columnSpacing: 24,
                    dataRowMinHeight: 44,
                    dataRowMaxHeight: 56,
                    columns: [
                      DataColumn(label: Text('Tanggal', style: GoogleFonts.nunito(
                          color: t.textSecondary, fontWeight: FontWeight.w700, fontSize: 12))),
                      DataColumn(label: Text('Source', style: GoogleFonts.nunito(
                          color: t.textSecondary, fontWeight: FontWeight.w700, fontSize: 12))),
                      DataColumn(label: Text('Amount', style: GoogleFonts.nunito(
                          color: t.textSecondary, fontWeight: FontWeight.w700, fontSize: 12)),
                          numeric: true),
                      DataColumn(label: Text('Balance After', style: GoogleFonts.nunito(
                          color: t.textSecondary, fontWeight: FontWeight.w700, fontSize: 12)),
                          numeric: true),
                    ],
                    rows: filtered.map((tx) {
                      final isEarn = tx.amount >= 0;
                      return DataRow(cells: [
                        DataCell(Text(_fmtDateId(tx.createdAt),
                            style: GoogleFonts.nunito(
                                color: t.textPrimary, fontSize: 12, fontWeight: FontWeight.w600))),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (_sourceBadgeColors[tx.source] ?? t.textHint).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            jewelSourceLabels[tx.source] ?? tx.source,
                            style: GoogleFonts.nunito(
                              color: _sourceBadgeColors[tx.source] ?? t.textHint,
                              fontSize: 11, fontWeight: FontWeight.w800,
                            ),
                          ),
                        )),
                        DataCell(Text(
                          '${isEarn ? '+' : ''}${_fmt(tx.amount)}',
                          style: GoogleFonts.nunito(
                            color: isEarn ? t.success : t.error,
                            fontWeight: FontWeight.w900, fontSize: 13,
                          ),
                          textAlign: TextAlign.right,
                        )),
                        DataCell(Row(mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end, children: [
                          const Icon(Icons.diamond, size: 14, color: Color(0xFF60A5FA)),
                          const SizedBox(width: 4),
                          Text(
                            _fmt(tx.balanceAfter ?? 0),
                            style: GoogleFonts.nunito(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w800, fontSize: 13,
                            ),
                          ),
                        ])),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            );
            },
          ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SHARED
// ════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final BloomTheme t;
  final String emoji, title, subtitle;
  const _EmptyState({required this.t, required this.emoji,
      required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(emoji, style: const TextStyle(fontSize: 56)),
      const SizedBox(height: 14),
      Text(title, style: GoogleFonts.nunito(
          color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
      if (subtitle.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(subtitle, style: GoogleFonts.nunito(
            color: t.textSecondary, fontSize: 13),
            textAlign: TextAlign.center),
      ],
    ],
  ));
}
