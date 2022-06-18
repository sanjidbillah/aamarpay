import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'web_view.dart';

enum EventState { initial, success, error }

typedef PaymentStatus<T> = void Function(T value);
typedef IsLoadingStaus<T> = void Function(T value);
typedef ReadUrl<T> = void Function(T value);

typedef Status<A, B> = void Function(A status, B message);

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
  final Status<EventState, String>? status;
  final String? customerAddress1;
  final String? customerAddress2;
  final String? customerCity;
  final String? customerState;
  final String? customerPostCode;
  final Widget child;

  Aamarpay({
    required this.isSandBox,
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
    this.customerPostCode,
  });

  @override
  _AamarpayState createState() => _AamarpayState();
}

class _AamarpayState<T> extends State<Aamarpay> {
  void _paymentHandler(String value) {
    widget.paymentStatus?.call(value);
  }

  void _loadingHandler(bool value) {
    widget.isLoading?.call(value);
  }

  void _urlHandler(String value) {
    widget.returnUrl?.call(value);
  }

  String _sandBoxUrl = 'https://sandbox.aamarpay.com';
  String _productionUrl = 'https://secure.aamarpay.com';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: widget.child,
      onTap: () {
        _loadingHandler(true);
        _getPayment().then((url) {
          Future.delayed(Duration(milliseconds: 200), () async {
            Route route =
                MaterialPageRoute(builder: (context) => AAWebView(url: url));
            Navigator.push(context, route).then((value) {
              if (value.split('/').contains("confirm")) {
                _paymentHandler("success");

                _loadingHandler(false);
              } else if (value.split('/').contains("cancel")) {
                _paymentHandler("cancel");

                _loadingHandler(false);
              } else if (value.split("/").contains("fail")) {
                _paymentHandler("fail");
                _loadingHandler(false);
              } else {
                _paymentHandler("fail");
                _loadingHandler(false);
              }
              _urlHandler(value);
            });
          });
        }).catchError((onError) {
          widget.status?.call(EventState.error, onError.message);
        });
      },
    );
  }

  Future _getPayment() async {
    widget.status?.call(EventState.initial, EventState.initial.name);
    http.Response response = await http.post(
      Uri.parse("${widget.isSandBox ? _sandBoxUrl : _productionUrl}/index.php"),
      body: {
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
        "type": "json"
      },
    );

    try {
      if (response.statusCode == 200) {
        widget.status?.call(EventState.success, EventState.success.name);
        return jsonDecode(response.body)['payment_url'];
      } else {
        throw Exception(_parseExceptionMessage(response.body));
      }
    } catch (e) {
      throw Exception(_parseExceptionMessage(response.body));
    }
  }

  _parseExceptionMessage(String data) {
    try {
      dynamic _res = jsonDecode(data);
      if (_res.runtimeType.toString() ==
          "_InternalLinkedHashMap<String, dynamic>") {
        return _res.values.toList()[0];
      } else {
        return _res;
      }
    } catch (e) {
      return 'Unknown please contact with aamarPay';
    }
  }
}
