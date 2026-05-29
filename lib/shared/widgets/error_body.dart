import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/bloom_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/error_helper.dart';
import '../../core/utils/responsive_utils.dart';
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
          Icon(icon, size: S.scale(context, 56), color: t.mutedText),
          SizedBox(height: S.scale(context, 12)),
          Text(
            displayTitle,
            style: GoogleFonts.nunito(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: S.font(context, 16),
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null && message!.isNotEmpty) ...[
            SizedBox(height: S.scale(context, 8)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: S.scale(context, 32)),
              child: Text(
                message!,
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontSize: S.font(context, 12),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (onRetry != null) ...[
            SizedBox(height: S.scale(context, 22)),
            Semantics(
              button: true,
              label: AppStrings.retry,
              child: Game3DButton(
                label: AppStrings.retry,
                color: t.primary,
                shadowColor: t.textPrimary,
                textColor: t.primaryContent,
                horizontalPadding: S.scale(context, 16),
                onTap: onRetry,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
