import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';
import '../themes/theme_provider.dart';

class SlowLoadingIndicator extends StatelessWidget {
  final bool visible;
  final BloomTheme t;

  const SlowLoadingIndicator({
    super.key,
    required this.visible,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !visible,
        child: LinearProgressIndicator(
          minHeight: S.scale(context, 4),
          backgroundColor: t.bgSurface2,
          valueColor: AlwaysStoppedAnimation<Color>(t.accent),
        ),
      ),
    );
  }
}
