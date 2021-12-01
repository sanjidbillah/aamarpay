import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'web_view.dart';

enum eventState { initial, success, error }
typedef PaymentStatus<T> = void Function(T value);
typedef IsLoadingStaus<T> = void Function(T value);
typedef ReadUrl<T> = void Function(T value);

typedef Status<T> = void Function(T value);

class Aamarpay extends StatefulWidget {
  final bool isSandBox;
  final String successUrl;
  final String failUrl;
  final String cancelUrl;
  final String storeID;
  final String transactionID;
  final String transactionAmount;
  final String signature;
  final String? description;
  final String? customerName;
  final String? customerEmail;
  final String customerMobile;
  final PaymentStatus<String>? paymentStatus;
  final IsLoadingStaus<bool>? isLoading;
  final ReadUrl<String>? returnUrl;
  final Status<eventState>? status;
  final String? customerAddress1;
  final String? customerAddress2;
  final String? customerCity;
  final String? customerState;
  final String? customerPostCode;
  final Widget child;

  Aamarpay(
      {required this.isSandBox,
      required this.successUrl,
      required this.failUrl,
      required this.cancelUrl,
      required this.storeID,
      required this.transactionID,
      required this.transactionAmount,
      required this.signature,
      this.description,
      required this.customerName,
      required this.customerEmail,
      required this.customerMobile,
      this.paymentStatus,
      this.isLoading,
      required this.child,
      this.returnUrl,
      this.status,
      this.customerAddress1,
      this.customerAddress2,
      this.customerCity,
      this.customerState,
      this.customerPostCode});

  @override
  _AamarpayState createState() => _AamarpayState();
}

class _AamarpayState<T> extends State<Aamarpay> {
  void paymentHandler(String value) {
    widget.paymentStatus?.call(value);
  }

  void loadingHandler(bool value) {
    widget.isLoading?.call(value);
  }

  void urlHandler(String value) {
    widget.returnUrl?.call(value);
  }

  String _sandBoxUrl = 'https://sandbox.aamarpay.com';
  String _productionUrl = 'https://secure.aamarpay.com';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: widget.child,
      onTap: () {
        loadingHandler(true);
        _getPayment().then((value) {
          String url = "${widget.isSandBox?_sandBoxUrl:_productionUrl}$value";

          Future.delayed(Duration(milliseconds: 200), () async {
            Route route =
                MaterialPageRoute(builder: (context) => AAWebView(url));
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
    );
  }

  Future _getPayment() async {
    try {
      widget.status?.call(eventState.initial);
      http.Response response =
          await http.post(Uri.parse("${widget.isSandBox?_sandBoxUrl:_productionUrl}/index.php"), body: {
        "store_id": widget.storeID.toString(),
        "tran_id": widget.transactionID.toString(),
        "success_url": widget.successUrl,
        "fail_url": widget.failUrl,
        "cancel_url": widget.cancelUrl,
        "amount": widget.transactionAmount.toString(),
        "currency": "BDT",
        "signature_key": widget.signature,
        "desc": widget.description ?? 'Empty',
        "cus_name": widget.customerName ?? 'Customer name',
        "cus_email": widget.customerEmail ?? 'nomail@mail.com',
        "cus_add1": widget.customerAddress1 ?? 'Dhaka',
        "cus_add2": widget.customerAddress2 ?? 'Dhaka',
        "cus_city": widget.customerCity ?? 'Dhaka',
        "cus_state": widget.customerState ?? "Dhaka",
        "cus_postcode": widget.customerPostCode ?? '0',
        "cus_country": "Bangladesh",
        "cus_phone": widget.customerMobile.toString(),
      });
      print(response.body);
      if (response.statusCode == 200) {
        String res = response.body;

        String start = 'action="';
        String end = "\">";
        final startIndex = res.indexOf(start);
        final endIndex = res.indexOf(end, startIndex + start.length);
        res.substring(startIndex + start.length, endIndex);
        widget.status?.call(eventState.success);
        return res.substring(startIndex + start.length, endIndex);
      } else {
        widget.status?.call(eventState.error);
        throw Exception();
      }
    } catch (e) {
      widget.status?.call(eventState.error);
      throw e;
    }
  }
}
