import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/responsive_utils.dart';
import '../themes/theme_provider.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final Widget value;
  final BloomTheme t;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            color: t.mutedText,
            fontWeight: FontWeight.w600,
            fontSize: S.font(context, 13),
          ),
        ),
        value,
      ],
    );
  }
}
