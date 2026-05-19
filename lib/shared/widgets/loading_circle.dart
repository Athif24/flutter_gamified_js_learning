import 'package:flutter/material.dart';
import '../themes/theme_provider.dart';

class LoadingCircle extends StatelessWidget {
  final BloomTheme t;

  const LoadingCircle({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          color: t.accent,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
