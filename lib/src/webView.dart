import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class webView extends StatefulWidget {
  var Url;

  webView(this.Url);

  @override
  _webViewState createState() => _webViewState();
}

class _webViewState extends State<webView> {
  var isloading = true;
  final Completer<InAppWebViewController> _completer =
      Completer<InAppWebViewController>();
  bool _isLoadingPage;

  @override
  void initState() {
    super.initState();

    _isLoadingPage = true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            InAppWebView(
              onWebViewCreated: (InAppWebViewController webViewController) {
                _completer.complete(webViewController);
              },
              onLoadStart: (InAppWebViewController controller, String url) {
                setState(() {
                  _isLoadingPage = true;
                });
                if (url.split('/').contains("confirm") ||
                    url.split('/').contains("cancel") ||
                    url.split('/').contains("fail")) {
                  Navigator.pop(context, url);
                }
              },
              onProgressChanged:
                  (InAppWebViewController controller, int url) {},
              onLoadStop: (InAppWebViewController controller, String url) {
                setState(() {
                  _isLoadingPage = false;
                });
              },
              initialUrl: '${widget.Url}',
            ),
            _isLoadingPage
                ? Center(child: CircularProgressIndicator())
                : Container(),
          ],
        ),
      ),
    );
  }
}
