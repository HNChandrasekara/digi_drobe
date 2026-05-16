import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ThreeJsViewer extends StatefulWidget {
  final String src;
  final Color backgroundColor;

  const ThreeJsViewer({
    super.key,
    required this.src,
    this.backgroundColor = Colors.transparent,
  });

  @override
  State<ThreeJsViewer> createState() => _ThreeJsViewerState();
}

class _ThreeJsViewerState extends State<ThreeJsViewer> {
  late final WebViewController _controller;
  bool _isLoadingHTML = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.backgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoadingHTML = false;
            });
            // Once the shell is ready, send the 3D model URL to javascript!
            _loadModelInViewer(widget.src);
          },
        ),
      );

    _loadHtmlFromAssets();
  }

  @override
  void didUpdateWidget(covariant ThreeJsViewer oldWidget) {
    if (oldWidget.src != widget.src && !_isLoadingHTML) {
      _loadModelInViewer(widget.src);
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadHtmlFromAssets() async {
    final String htmlContent = await rootBundle.loadString(
      'assets/threejs/index.html',
    );
    await _controller.loadHtmlString(htmlContent);
  }

  void _loadModelInViewer(String url) {
    // Escape string just in case
    final jsCode = "if (window.loadModel) { loadModel('\$url'); }";
    _controller.runJavaScript(jsCode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: _isLoadingHTML
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}
