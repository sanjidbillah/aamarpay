import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'web_view.dart';

typedef PaymentStatus<T> = void Function(T value);
typedef isLoadingStaus<T> = void Function(T value);
typedef readUrl<T> = void Function(T value);

class AamarpayData<T> extends StatefulWidget {
  final url;
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
  final PaymentStatus<String> paymentStatus;
  final isLoadingStaus<bool> isLoading;
  final readUrl<dynamic> returnUrl;
  final customerAddress1;
  final customerAddress2;
  final customerCity;
  final customerState;
  final customerPostCode;
  final Widget child;

  AamarpayData(
      {@required this.url,
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
      this.returnUrl,
      this.customerAddress1,
      this.customerAddress2,
      this.customerCity,
      this.customerState,
      this.customerPostCode});

  @override
  _AamarpayDataState<T> createState() => _AamarpayDataState<T>();
}

class _AamarpayDataState<T> extends State<AamarpayData<T>> {
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
              var url = "${widget.url}$value";

              Future.delayed(Duration(milliseconds: 200), () async {
                Route route =
                    MaterialPageRoute(builder: (context) => MyView(url));
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
      ],
    );
  }

  Future getPayment() async {
    http.Response response = await http.post("${widget.url}/index.php", body: {
      "store_id": widget.storeID.toString(),
      "tran_id": widget.transactionID.toString(),
      "success_url": widget.successUrl,
      "fail_url": widget.failUrl,
      "cancel_url": widget.cancelUrl,
      "amount": widget.transactionAmount.toString(),
      "currency": "BDT",
      "signature_key": widget.signature,
      "desc": widget.description == null ? "Nothing" : widget.description,
      "cus_name": widget.customerName,
      "cus_email": widget.customerEmail,
      "cus_add1":
          widget.customerAddress1 == null ? "Dhaka" : widget.customerAddress1,
      "cus_add2":
          widget.customerAddress2 == null ? "Dhaka" : widget.customerAddress2,
      "cus_city": widget.customerCity == null ? "Dhaka" : widget.customerCity,
      "cus_state":
          widget.customerState == null ? "Dhaka" : widget.customerState,
      "cus_postcode": widget.customerPostCode == null
          ? "1206"
          : widget.customerPostCode.toString(),
      "cus_country": "Bangladesh",
      "cus_phone": widget.customerMobile.toString(),
    });
    if (response.statusCode == 200) {
      String mydata = response.body;

      var start = 'action="';
      var end = "\">";
      final startIndex = mydata.indexOf(start);
      final endIndex = mydata.indexOf(end, startIndex + start.length);
      mydata.substring(startIndex + start.length, endIndex);

      return mydata.substring(startIndex + start.length, endIndex);
    } else {
      throw response.body;
    }
  }
}
