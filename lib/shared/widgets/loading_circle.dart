import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';
import '../themes/theme_provider.dart';

class LoadingCircle extends StatelessWidget {
  final BloomTheme t;

  const LoadingCircle({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: S.scale(context, 40),
        height: S.scale(context, 40),
        child: CircularProgressIndicator(
          color: t.accent,
          strokeWidth: S.scale(context, 3),
        ),
      ),
    );
  }
}
