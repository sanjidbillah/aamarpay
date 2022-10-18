import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AAWebView extends StatefulWidget {
  final String url;
  final String successUrl;
  final String failUrl;
  final String cancelUrl;
  const AAWebView(
      {Key? key, required this.url, required this.successUrl, required this.failUrl, required this.cancelUrl})
      : super(key: key);

  @override
  State<AAWebView> createState() => _AAWebViewState();
}

class _AAWebViewState extends State<AAWebView> {
  ValueNotifier<int> loadingPercentage = ValueNotifier(0);
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebView(
              javascriptMode: JavascriptMode.unrestricted,
              onPageStarted: (String url) {
                if (url.contains(widget.successUrl) || url.contains(widget.failUrl) || url.contains(widget.cancelUrl)) {
                  Navigator.pop(context, url);
                }
              },
              onProgress: (pos) {
                loadingPercentage.value = pos;
              },
              initialUrl: widget.url,
            ),
            ValueListenableBuilder(
                valueListenable: loadingPercentage,
                builder: (_, percentage, __) {
                  if (percentage == 100) {
                    return SizedBox.shrink();
                  }
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white24,
                    child: Center(
                      child: Text(
                        "$percentage %",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
