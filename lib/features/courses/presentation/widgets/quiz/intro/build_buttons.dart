import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../shared/widgets/game_3d_button.dart';
import '../../../../../../core/utils/responsive_utils.dart';
import 'action_btn_data.dart';

class BuildButtons extends StatelessWidget {
  final BloomTheme t;
  final Axis axis;
  final List<ActionBtnData> buttons;

  const BuildButtons({
    super.key,
    required this.t,
    required this.axis,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    final list = <Widget>[];
    for (var i = 0; i < buttons.length; i++) {
      final btn = buttons[i];
      final noLives =
          btn.onTap == null && !btn.isLoading && btn.label != 'Kembali';

      if (i > 0) {
        list.add(
          SizedBox(
            width: axis == Axis.horizontal ? 12 : 0,
            height: axis == Axis.vertical ? 10 : 0,
          ),
        );
      }

      final btnWidget = Game3DButton(
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
                  Icon(Icons.lock_rounded, size: 14, color: t.mutedText),
                  const SizedBox(width: 6),
                  Text(
                    'Nyawa Habis',
                    style: GoogleFonts.nunito(
                      color: t.mutedText,
                      fontWeight: FontWeight.w800,
                      fontSize: S.font(context, 14),
                    ),
                  ),
                ],
              )
            : null,
      );

      list.add(
        axis == Axis.horizontal
            ? Expanded(
                child: Semantics(
                  button: true,
                  label: btn.label,
                  child: btnWidget,
                ),
              )
            : Semantics(button: true, label: btn.label, child: btnWidget),
      );
    }

    if (axis == Axis.horizontal) {
      return Row(children: list);
    }
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: list,
      ),
    );
  }
}