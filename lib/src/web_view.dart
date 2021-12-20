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
  double pageProgress = 0;

  @override
  void initState() {
    super.initState();
    _isLoadingPage = true;
  }

  @override
  Widget build(BuildContext context) {
    DateTime timeBackpessed = DateTime.now();
    return WillPopScope(
      onWillPop: () async {
        InAppWebViewController controller = await _completer.future;
        var canGoBack = await controller.canGoBack();
        if (canGoBack) {
          controller.goBack();
          return false;
        } else {
          final difference = DateTime.now().difference(timeBackpessed);
          timeBackpessed = DateTime.now();
          if (difference >= Duration(seconds: 2)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Press back again to exit payment',
                  textAlign: TextAlign.center,
                ),
                duration: Duration(seconds: 2),
              ),
            );
            return false;
          } else {
            return true;
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: <Widget>[
              pageProgress < 1.0 && _isLoadingPage
                  ? LinearProgressIndicator(
                      value: pageProgress,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      backgroundColor: Colors.transparent,
                      minHeight: 6,
                    )
                  : Container(),
              Expanded(
                child: InAppWebView(
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
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      pageProgress = progress / 100;
                    });
                  },
                  onLoadStop: (InAppWebViewController controller, Uri? url) {
                    setState(() {
                      _isLoadingPage = false;
                    });
                  },
                  initialUrlRequest: URLRequest(
                    url: Uri.parse('${widget.url}'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
