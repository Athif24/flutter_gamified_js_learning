import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../providers/store_provider.dart';
import '../../data/models/store_model.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t          = ref.watch(currentThemeProvider);
    final tabIdx     = ref.watch(storeTabProvider);
    final jewelsAsync= ref.watch(jewelBalanceProvider);
    final tabs       = ['Shop', 'Inventory', 'Jewel History'];

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(child: Column(children: [
        // ── Header ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [t.accent.withOpacity(0.2), t.info.withOpacity(0.1)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Column(children: [
            Row(children: [
              const Text('🛒', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text('Store', style: GoogleFonts.nunito(
                  color: t.textPrimary, fontSize: 22,
                  fontWeight: FontWeight.w900))
                  .animate().fadeIn(),
              const Spacer(),
              jewelsAsync.maybeWhen(
                data: (j) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: t.info.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: t.info.withOpacity(0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('💎', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('${j.balance} JEWELS', style: GoogleFonts.nunito(
                        color: t.info, fontWeight: FontWeight.w900,
                        fontSize: 12)),
                  ]),
                ).animate().fadeIn(delay: 100.ms),
                orElse: () => const SizedBox.shrink(),
              ),
            ]),
            const SizedBox(height: 4),
            Align(alignment: Alignment.centerLeft,
              child: Text('Tukarkan jewels kamu dengan item-item berguna!',
                  style: GoogleFonts.nunito(
                      color: t.textSecondary, fontSize: 12))
                  .animate().fadeIn(delay: 150.ms),
            ),
            const SizedBox(height: 14),

            // Tabs
            Row(children: tabs.asMap().entries.map((e) {
              final sel = e.key == tabIdx;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Bounceable(
                  onTap: () =>
                      ref.read(storeTabProvider.notifier).state = e.key,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? t.accent : t.bgSurface2,
                      borderRadius: BorderRadius.circular(50),
                      border: sel ? null : Border.all(color: t.border),
                    ),
                    child: Text(e.value, style: GoogleFonts.nunito(
                      color: sel ? t.accentText : t.textSecondary,
                      fontWeight: FontWeight.w700, fontSize: 13,
                    )),
                  ),
                ),
              );
            }).toList()),
            const SizedBox(height: 14),
          ]),
        ),

        // ── Content ────────────────────────────────────────────────────
        Expanded(child: switch(tabIdx) {
          1     => _InventoryTab(t: t, ref: ref),
          2     => _JewelHistoryTab(t: t, ref: ref),
          _     => _ShopTab(t: t, ref: ref),
        }),
      ])),
    );
  }
}

// ── Shop tab ──────────────────────────────────────────────────────────────────

class _ShopTab extends StatelessWidget {
  final BloomTheme t;
  final WidgetRef ref;
  const _ShopTab({required this.t, required this.ref});

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(storeItemsProvider);
    return itemsAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.accent)),
      error: (e, _) => _EmptyState(t: t,
          emoji: '🔧', title: 'Gagal memuat item',
          subtitle: e.toString().replaceAll('Exception: ', '')),
      data: (items) => items.isEmpty
          ? _EmptyState(t: t, emoji: '🛒',
              title: 'Belum ada item tersedia',
              subtitle: 'Check back later untuk item baru!')
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 14,
                crossAxisSpacing: 14, childAspectRatio: 0.85,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => _ItemCard(item: items[i], t: t, ref: ref)
                  .animate().fadeIn(delay: (60 * i).ms),
            ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final StoreItem item;
  final BloomTheme t;
  final WidgetRef ref;
  const _ItemCard({required this.item, required this.t, required this.ref});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: t.bgSurface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: t.border),
    ),
    child: Column(children: [
      Text(item.icon, style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 8),
      Text(item.name, style: GoogleFonts.nunito(
          color: t.textPrimary, fontWeight: FontWeight.w700,
          fontSize: 13), textAlign: TextAlign.center),
      if (item.description != null) ...[
        const SizedBox(height: 4),
        Text(item.description!, style: GoogleFonts.nunito(
            color: t.textSecondary, fontSize: 10),
            textAlign: TextAlign.center, maxLines: 2),
      ],
      const Spacer(),
      Bounceable(
        onTap: () async {
          try {
            await ref.read(storeDsProvider).buyItem(item.id);
            // ref.refresh(jewelBalanceProvider);
            ref.invalidate(jewelBalanceProvider);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Berhasil membeli ${item.name}!',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                backgroundColor: t.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', ''),
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                backgroundColor: t.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
            }
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: t.accent, borderRadius: BorderRadius.circular(50)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('💎', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text('${item.price}', style: GoogleFonts.nunito(
                color: t.accentText, fontWeight: FontWeight.w800,
                fontSize: 12)),
          ]),
        ),
      ),
    ]),
  );
}

// ── Inventory tab ─────────────────────────────────────────────────────────────

class _InventoryTab extends StatelessWidget {
  final BloomTheme t;
  final WidgetRef ref;
  const _InventoryTab({required this.t, required this.ref});

  @override
  Widget build(BuildContext context) {
    final invAsync = ref.watch(inventoryProvider);
    return invAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.accent)),
      error: (_, __) => _EmptyState(t: t, emoji: '📦',
          title: 'Inventori kosong', subtitle: 'Belum ada item yang dimiliki'),
      data: (items) => items.isEmpty
          ? _EmptyState(t: t, emoji: '📦',
              title: 'Inventori kosong',
              subtitle: 'Beli item dari Shop dan gunakan di sini')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (_, i) => _InventoryTile(item: items[i], t: t)
                  .animate().fadeIn(delay: (60 * i).ms),
            ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  final InventoryItem item;
  final BloomTheme t;
  const _InventoryTile({required this.item, required this.t});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: t.bgSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: t.border),
    ),
    child: Row(children: [
      Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: t.bgSurface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(item.item.icon,
            style: const TextStyle(fontSize: 26))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.item.name, style: GoogleFonts.nunito(
              color: t.textPrimary, fontWeight: FontWeight.w700,
              fontSize: 14)),
          Text('x${item.quantity}', style: GoogleFonts.nunito(
              color: t.textSecondary, fontSize: 12)),
        ],
      )),
      if (!item.isUsed)
        Bounceable(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: t.accent, borderRadius: BorderRadius.circular(50)),
            child: Text('Gunakan', style: GoogleFonts.nunito(
                color: t.accentText, fontWeight: FontWeight.w800,
                fontSize: 12)),
          ),
        ),
    ]),
  );
}

// ── Jewel history tab ─────────────────────────────────────────────────────────

class _JewelHistoryTab extends StatelessWidget {
  final BloomTheme t;
  final WidgetRef ref;
  const _JewelHistoryTab({required this.t, required this.ref});

  @override
  Widget build(BuildContext context) {
    final histAsync = ref.watch(jewelHistoryProvider);
    return histAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.accent)),
      error: (_, __) => _EmptyState(t: t, emoji: '📜',
          title: 'Belum ada riwayat', subtitle: ''),
      data: (list) => list.isEmpty
          ? _EmptyState(t: t, emoji: '📜',
              title: 'Belum ada riwayat', subtitle: '')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final tx = list[i];
                final isEarn = tx.type == 'earn' || tx.amount > 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: t.bgSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.border),
                  ),
                  child: Row(children: [
                    Text(isEarn ? '📈' : '📉',
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx.description ?? tx.type,
                            style: GoogleFonts.nunito(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(tx.createdAt, style: GoogleFonts.nunito(
                            color: t.textSecondary, fontSize: 11)),
                      ],
                    )),
                    Text(isEarn ? '+${tx.amount}' : '${tx.amount}',
                        style: GoogleFonts.nunito(
                            color: isEarn ? t.success : t.error,
                            fontWeight: FontWeight.w900, fontSize: 16)),
                  ]),
                ).animate().fadeIn(delay: (50 * i).ms);
              },
            ),
    );
  }
}

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