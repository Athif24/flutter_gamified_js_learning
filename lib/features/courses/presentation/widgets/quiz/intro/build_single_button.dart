import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../shared/widgets/game_3d_button.dart';
import '../../../../../../core/utils/responsive_utils.dart';
import 'action_btn_data.dart';

class BuildSingleButton extends StatelessWidget {
  final BloomTheme t;
  final ActionBtnData btn;

  const BuildSingleButton({super.key, required this.t, required this.btn});

  @override
  Widget build(BuildContext context) {
    final noLives =
        btn.onTap == null && !btn.isLoading && btn.label != 'Kembali';

    return Semantics(
      button: true,
      label: btn.label,
      child: Game3DButton(
        label: noLives ? null : btn.label,
        color: btn.color,
        shadowColor: btn.shadowColor,
        textColor: btn.textColor,
        horizontalPadding: S.scale(context, 16),
        verticalPadding: S.scale(context, 15),
        isLoading: btn.isLoading,
        onTap: btn.onTap,
        child: noLives
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 14,
                    color: const Color(0xFF666666),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Nyawa Habis',
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w800,
                      fontSize: S.font(context, 14),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}