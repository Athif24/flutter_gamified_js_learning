import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/services/sound_service.dart';
import '../providers/store_provider.dart';

class StoreTabBtn extends ConsumerWidget {
  final BloomTheme t;
  final IconData icon;
  final String label;
  final int idx, cur;
  final WidgetRef ref;

  const StoreTabBtn({
    super.key,
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
      onTap: () {
        ref.read(soundProvider).playClick();
        ref.read(storeTabProvider.notifier).state = idx;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: S.scale(context, 16),
          vertical: S.scale(context, 8),
        ),
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
            Icon(
              icon,
              size: S.scale(context, 16),
              color: sel ? t.primaryContent : t.textPrimary,
            ),
            SizedBox(width: S.scale(context, 6)),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: sel ? t.primaryContent : t.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: S.scale(context, 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}