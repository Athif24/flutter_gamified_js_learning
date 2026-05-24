import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/bloom_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/error_helper.dart';
import 'game_3d_button.dart';

IconData iconForError(Object e) {
  return switch (categorizeError(e)) {
    ApiErrorType.network    => Icons.wifi_off_rounded,
    ApiErrorType.timeout    => Icons.timer_off_rounded,
    ApiErrorType.server     => Icons.dns_rounded,
    ApiErrorType.auth       => Icons.lock_rounded,
    ApiErrorType.validation => Icons.warning_rounded,
    ApiErrorType.unknown    => Icons.error_outline_rounded,
  };
}

class ErrorBody extends StatelessWidget {
  final BloomTheme t;
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorBody({
    super.key,
    required this.t,
    this.title = '',
    this.message,
    this.onRetry,
    this.icon = Icons.cloud_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.isNotEmpty ? title : AppStrings.retry;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: t.mutedText),
          const SizedBox(height: 12),
          Text(
            displayTitle,
            style: GoogleFonts.nunito(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message!,
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 22),
            Semantics(
              button: true,
              label: AppStrings.retry,
              child: Game3DButton(
                label: AppStrings.retry,
                color: t.primary,
                shadowColor: t.textPrimary,
                textColor: t.primaryContent,
                horizontalPadding: 16,
                onTap: onRetry,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
