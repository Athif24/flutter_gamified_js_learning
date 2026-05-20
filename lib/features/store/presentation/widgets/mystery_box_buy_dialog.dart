import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../data/models/reward_pool_model.dart';

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

class MysteryBoxBuyDialog extends StatelessWidget {
  final RewardPool pool;
  final int balance;
  final bool isPending;
  final VoidCallback onClose;
  final VoidCallback onConfirm;
  final BloomTheme t;

  const MysteryBoxBuyDialog({
    super.key,
    required this.pool,
    required this.balance,
    required this.isPending,
    required this.onClose,
    required this.onConfirm,
    required this.t,
  });

  String get _icon {
    if (pool.icon != null && pool.icon!.isNotEmpty) return pool.icon!;
    if (pool.name.toLowerCase().contains('legendary')) return '👑';
    if (pool.name.toLowerCase().contains('premium')) return '🎀';
    return '🎁';
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = balance - pool.jewelCost;

    return AlertDialog(
      scrollable: true,
      backgroundColor: t.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: t.textPrimary.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      title: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: _icon.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: _icon,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Icon(Icons.card_giftcard, size: 24, color: Colors.grey),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.card_giftcard, size: 24, color: Colors.grey),
                  )
                : Text(_icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Beli ${pool.name}?',
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hadiah yang didapat bersifat acak. Jewels tidak bisa dikembalikan setelah pembelian.',
            style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.bgPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _infoRow(
                  'Harga',
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond,
                          size: 14, color: Color(0xFF60A5FA)),
                      const SizedBox(width: 4),
                      Text(
                        '-${_fmt(pool.jewelCost)}',
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
                    _fmt(balance),
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                Divider(
                    height: 20,
                    color: t.textPrimary.withValues(alpha: 0.1)),
                _infoRow(
                  'Sisa balance',
                  Text(
                    _fmt(remaining),
                    style: GoogleFonts.nunito(
                      color: remaining >= 0
                          ? const Color(0xFF60A5FA)
                          : t.error,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reward preview
          Text(
            'Kemungkinan Hadiah',
            style: GoogleFonts.nunito(
              color: t.textHint,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          ...pool.rewards.map((reward) {
            final color = _parseColor(reward.color);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color ?? t.textHint,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reward.displayLabel,
                      style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    '${reward.percentage}%',
                    style: GoogleFonts.nunito(
                      color: t.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                label: 'Batal',
                child: Bounceable(
                  onTap: isPending ? null : onClose,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: t.bgSurface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: t.border, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: t.border,
                          offset: const Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.nunito(
                        color: t.textHint,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              Semantics(
                label: remaining >= 0 ? 'Beli Sekarang' : 'Saldo Tidak Cukup',
                child: Bounceable(
                  onTap: isPending ? null : onConfirm,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isPending ? t.bgSurface2 : t.accent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: t.border, width: 2),
                      boxShadow: isPending
                          ? null
                          : [
                              BoxShadow(
                                color: t.border,
                                offset: const Offset(2, 2),
                                blurRadius: 0,
                              )
                            ],
                    ),
                    child: Text(
                      isPending ? 'Memproses...' : 'Beli Sekarang',
                      style: GoogleFonts.nunito(
                        color: isPending ? t.textHint : t.accentText,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            color: t.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        value,
      ],
    );
  }
}
