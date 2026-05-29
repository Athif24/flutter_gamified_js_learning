import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/connectivity_provider.dart';
import '../../core/utils/responsive_utils.dart';
import '../themes/theme_provider.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);
    final t = ref.watch(currentThemeProvider);

    return isOnline.when(
      data: (online) => online
          ? const SizedBox.shrink()
          : SafeArea(
              top: true,
              bottom: false,
              child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: S.scale(context, 16), vertical: S.scale(context, 8)),
              color: t.error,
              child: Row(
                children: [
                  Icon(Icons.wifi_off_rounded, color: t.errorContent, size: S.font(context, 18)),
                  SizedBox(width: S.scale(context, 10)),
                  Expanded(
                    child: Text(
                      'Koneksi terputus',
                      style: GoogleFonts.nunito(
                        color: t.errorContent,
                        fontSize: S.font(context, 13),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
