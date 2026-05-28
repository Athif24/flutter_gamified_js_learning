import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/responsive_utils.dart';

Color darken(Color c, double amt) {
  final h = HSLColor.fromColor(c);
  return h.withLightness((h.lightness - amt).clamp(0.0, 1.0)).toColor();
}

class Game3DButton extends StatefulWidget {
  final String? label;
  final Widget? child;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final VoidCallback? onTap;
  final bool isLoading;
  final double horizontalPadding;
  final double verticalPadding;

  const Game3DButton({
    super.key,
    this.label,
    this.child,
    required this.color,
    required this.shadowColor,
    required this.textColor,
    this.onTap,
    this.isLoading = false,
    this.horizontalPadding = 28,
    this.verticalPadding = 13,
  }) : assert(
         label != null || child != null,
         'Either label or child must be provided',
       );

  @override
  State<Game3DButton> createState() => _Game3DButtonState();
}

class _Game3DButtonState extends State<Game3DButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null && !widget.isLoading;
    final faceColor = isDisabled ? const Color(0xFFE5E5E5) : widget.color;
    final shadow = isDisabled ? const Color(0xFFC0C0C0) : widget.shadowColor;
    final txtColor = isDisabled ? const Color(0xFF666666) : widget.textColor;

    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(0, _pressed ? 2.0 : 0.0, 0),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: widget.horizontalPadding,
          vertical: widget.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: faceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _pressed ? Colors.transparent : shadow,
            width: 2,
          ),
          boxShadow: _pressed
              ? null
              : [
                  BoxShadow(
                    color: shadow,
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: widget.isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: txtColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.label ?? '',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: S.font(context, 14),
                          color: txtColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : (widget.child ??
                  FittedBox(
                    fit: BoxFit.scaleDown,
                      child: Text(
                        widget.label!,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: S.font(context, 14),
                          color: txtColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                  )),
      ),
    );
  }
}