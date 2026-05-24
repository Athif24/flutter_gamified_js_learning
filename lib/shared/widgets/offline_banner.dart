import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/connectivity_provider.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: t.error,
              child: Row(
                children: [
                  Icon(Icons.wifi_off_rounded, color: t.errorContent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Koneksi terputus',
                      style: GoogleFonts.nunito(
                        color: t.errorContent,
                        fontSize: 13,
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
