import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AAWebView extends StatefulWidget {
  final url;

  AAWebView(this.url);

  @override
  _AAWebViewState createState() => _AAWebViewState();
}

class _AAWebViewState extends State<AAWebView> {
  final Completer<InAppWebViewController> _completer =
      Completer<InAppWebViewController>();
  late bool _isLoadingPage;

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
                onLoadStart: (InAppWebViewController controller, Uri? url) {
                  setState(() {
                    _isLoadingPage = true;
                  });
                  if (url.toString().split('/').contains("confirm") ||
                      url.toString().split('/').contains("cancel") ||
                      url.toString().split('/').contains("fail")) {
                    Navigator.pop(context, url.toString());
                  }
                },
                onProgressChanged:
                    (InAppWebViewController controller, int url) {},
                onLoadStop: (InAppWebViewController controller, Uri? url) {
                  setState(() {
                    _isLoadingPage = false;
                  });
                },
                initialUrlRequest: URLRequest(
                  url: Uri.parse('${widget.url}'),
                )),
            _isLoadingPage
                ? Center(child: CircularProgressIndicator())
                : Container(),
          ],
        ),
      ),
    );
  }
}
