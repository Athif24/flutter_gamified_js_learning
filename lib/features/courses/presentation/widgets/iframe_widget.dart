import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IframeWidget extends StatefulWidget {
  final String src;
  const IframeWidget({super.key, required this.src});

  @override
  State<IframeWidget> createState() => _IframeWidgetState();
}

class _IframeWidgetState extends State<IframeWidget> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(widget.src));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      WebViewWidget(controller: _controller),
      if (_loading)
        const Center(child: CircularProgressIndicator()),
    ]);
  }
}
