import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AAWebView extends StatefulWidget {
  final String url;
  final String successUrl;
  final String failUrl;
  final String cancelUrl;
  const AAWebView({
    Key? key,
    required this.url,
    required this.successUrl,
    required this.failUrl,
    required this.cancelUrl,
  }) : super(key: key);

  @override
  State<AAWebView> createState() => _AAWebViewState();
}

class _AAWebViewState extends State<AAWebView> {
  ValueNotifier<int> loadingPercentage = ValueNotifier(0);
  late WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          loadingPercentage.value = progress;
        },
        onPageStarted: (String url) {
          if (url.contains(widget.successUrl) ||
              url.contains(widget.failUrl) ||
              url.contains(widget.cancelUrl)) {
            Navigator.pop(context, url);
          }
        },
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
      ),
    )
    ..loadRequest(Uri.parse(widget.url));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder(
                valueListenable: loadingPercentage,
                builder: (_, percentage, __) {
                  if (percentage != 100) {
                    return LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[100],
                      color: Colors.blueAccent,
                    );
                  }

                  return SizedBox.shrink();
                }),
            Expanded(
              child: WebViewWidget(
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
