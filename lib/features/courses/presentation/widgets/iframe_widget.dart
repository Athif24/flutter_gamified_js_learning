import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';

class IframeWidget extends StatefulWidget {
  final String src;
  const IframeWidget({super.key, required this.src});

  @override
  State<IframeWidget> createState() => _IframeWidgetState();
}

class _IframeWidgetState extends State<IframeWidget> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) { setState(() => _loading = false); }
        },
        onWebResourceError: (_) {
          if (mounted) { setState(() {
            _loading = false;
            _hasError = true;
          }); }
        },
      ))
      ..loadRequest(Uri.parse(widget.src));
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(S.scale(context, 24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off_rounded, size: S.scale(context, 48), color: Colors.grey),
              SizedBox(height: S.scale(context, 12)),
              Text(
                'Konten tidak dapat dimuat',
                style: GoogleFonts.nunito(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: S.font(context, 14),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return Stack(children: [
      WebViewWidget(controller: _controller),
      if (_loading)
        const Center(child: CircularProgressIndicator()),
    ]);
  }
}
