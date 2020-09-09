import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'webView.dart';

typedef PaymentStatus<T> = void Function(T value);
typedef isLoadingStaus<T> = void Function(T value);
typedef readUrl<T> = void Function(T value);

class aamarpayData<T> extends StatefulWidget {

  String url;
  final successUrl;
  final failUrl;
  final cancelUrl;
  final storeID;
  final transactionID;
  final transactionAmount;
  final signature;
  final description;
  final customerName;
  final customerEmail;
  final customerMobile;
  PaymentStatus<String> paymentStatus;
  isLoadingStaus<bool> isLoading;
  readUrl<dynamic> returnUrl;
  Widget child;

  aamarpayData({
    @required this.url,
    @required this.successUrl,
    @required this.failUrl,
    @required this.cancelUrl,
    @required this.storeID,
    @required this.transactionID,
    @required this.transactionAmount,
    @required this.signature,
    this.description,
    @required this.customerName,
    @required this.customerEmail,
    @required this.customerMobile,
    this.paymentStatus,
    this.isLoading,
    this.child,
    this.returnUrl
  });


  @override
  _aamarpayDataState<T> createState() => _aamarpayDataState<T>();
}

class _aamarpayDataState<T> extends State<aamarpayData<T>> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void paymentHandler(String value) {
      if (widget.paymentStatus != null) {
        widget.paymentStatus(value);
      }
    }

    void loadingHandler(bool value) {
      if (widget.isLoading != null) {
        widget.isLoading(value);
      }
    }

    void urlHandler(String value) {
      if (widget.returnUrl != null) {
        widget.returnUrl(value);
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 80),

        GestureDetector(
          child: widget.child,
          onTap: () {
            loadingHandler(true);
            getPayment().then((value) {
              var url = "${widget.url}${value}";

              Future.delayed(Duration(milliseconds: 200), () async {
                Route route = MaterialPageRoute(
                    builder: (context) => webView(url));
                Navigator.push(context, route).then((value) {
                  if (value.split('/').contains("confirm")) {
                    urlHandler(value);
                    paymentHandler("success");

                    loadingHandler(false);
                  } else if (value.split('/').contains("cancel")) {
                    urlHandler(value);
                    paymentHandler("cancel");

                    loadingHandler(false);
                  } else if (value.split("/").contains("fail")) {
                    urlHandler(value);
                    paymentHandler("fail");
                    loadingHandler(false);
                  } else {
                    urlHandler(value);
                    paymentHandler("fail");
                    loadingHandler(false);
                  }
                });
              });
            });
          },
        )

      ],);
  }

  Future getPayment() async {
    http.Response response = await http.post("${widget.url}/index.php", body: {
      "store_id": widget.storeID,
      "tran_id": widget.transactionID,
      "success_url": widget.successUrl,
      "fail_url": widget.failUrl,
      "cancel_url": widget.cancelUrl,
      "amount": widget.transactionAmount,
      "currency": "BDT",
      "signature_key": widget.signature,
      "desc": widget.description,
      "cus_name": widget.customerName,
      "cus_email": widget.customerEmail,
      "cus_add1": "Dhaka",
      "cus_add2": "Dhaka",
      "cus_city": "Dhaka",
      "cus_state": "Dhaka",
      "cus_postcode": "1206",
      "cus_country": "Bangladesh",
      "cus_phone": widget.customerMobile,
    });
    if (response.statusCode == 200) {
      String mydata = response.body;
      var start = 'action="';
      var end = "\">";
      final startIndex = mydata.indexOf(start);
      final endIndex = mydata.indexOf(end, startIndex + start.length);
      await mydata.substring(startIndex + start.length, endIndex);

      return mydata.substring(startIndex + start.length, endIndex);
    } else {
      throw response.body;
    }
  }
}
