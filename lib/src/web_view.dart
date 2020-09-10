import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyView extends StatefulWidget {
  final url;

  MyView(this.url);

  @override
  _MyViewState createState() => _MyViewState();
}

class _MyViewState extends State<MyView> {
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
              initialUrl: '${widget.url}',
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
