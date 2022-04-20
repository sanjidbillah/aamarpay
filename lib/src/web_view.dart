import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AAWebView extends StatefulWidget {
  final String url;
  const AAWebView({Key? key, required this.url}) : super(key: key);

  @override
  State<AAWebView> createState() => _AAWebViewState();
}

class _AAWebViewState extends State<AAWebView> {
  int loadingPercentage = 0;
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
                if (url.split('/').contains("confirm") ||
                    url.split('/').contains("cancel") ||
                    url.split('/').contains("fail")) {
                  Navigator.pop(context, url);
                }
              },
              onProgress: (pos) {
                setState(() {
                  loadingPercentage = pos;
                });
              },
              initialUrl: widget.url,
            ),
            if (loadingPercentage != 100)
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white24,
                child: Center(
                  child: Text(
                    "$loadingPercentage %",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
