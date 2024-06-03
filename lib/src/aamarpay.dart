import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'web_view.dart';

enum EventState { success, fail, cancel, error, backButtonPressed }

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
  final String? transactionAmount;
  final TextEditingController? transactionAmountFromTextField;
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
  final String? optA;
  final String? optB;
  final String? optC;
  final String? optD;
  final Widget child;

  Aamarpay({
    required this.isSandBox,
    required this.successUrl,
    required this.failUrl,
    required this.cancelUrl,
    required this.storeID,
    required this.transactionID,
    this.transactionAmount,
    this.transactionAmountFromTextField,
    required this.signature,
    this.description,
    required this.customerName,
    required this.customerEmail,
    required this.customerMobile,
    @Deprecated('Use status function insted of paymentStatus')
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
    this.optA,
    this.optB,
    this.optC,
    this.optD,
  }) : assert((transactionAmount != null ||
                transactionAmountFromTextField != null)
            ? true
            : throw "Add transactionAmount Or transactionAmountFromTextField");

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

  void _urlHandler(String? value) {
    widget.returnUrl
        ?.call(value ?? "No url was found because user pressed back button");
    if (value == null) {
      widget.status
          ?.call(EventState.backButtonPressed, 'User pressed back button');
    }
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
          if (url == null) {
            _loadingHandler(false);
            widget.status?.call(EventState.error, 'error');
          } else {
            Route route = MaterialPageRoute(
                builder: (context) => AAWebView(
                      url: url,
                      successUrl: widget.successUrl,
                      failUrl: widget.failUrl,
                      cancelUrl: widget.cancelUrl,
                    ));
            Navigator.push(context, route).then((value) {
              if (value.toString().contains(widget.successUrl)) {
                _paymentHandler("success");
                widget.status
                    ?.call(EventState.success, 'Payment has been succeeded');
              } else if (value.toString().contains(widget.cancelUrl)) {
                _paymentHandler("cancel");
                widget.status
                    ?.call(EventState.cancel, 'Payment has been canceled');
              } else if (value.toString().contains(widget.failUrl)) {
                _paymentHandler("fail");
                widget.status?.call(EventState.fail, 'Payment has been failed');
              } else {
                _paymentHandler("fail");
                widget.status?.call(EventState.fail, 'Payment has been failed');
              }
              _loadingHandler(false);
              _urlHandler(value);
            });
          }
        }).catchError((onError) {
          _loadingHandler(false);
          widget.status?.call(EventState.error, onError.message);
        });
      },
    );
  }

  Future _getPayment() async {
    http.Response response = await http.post(
      widget.isSandBox
          ? Uri.parse("${_sandBoxUrl}/jsonpost.php")
          : Uri.parse("${_productionUrl}/jsonpost.php"),
      body: json.encode({
        "store_id": widget.storeID,
        "tran_id": widget.transactionID,
        "success_url": widget.successUrl,
        "fail_url": widget.failUrl,
        "cancel_url": widget.cancelUrl,
        "amount": widget.transactionAmount ??
            widget.transactionAmountFromTextField?.text ??
            0,
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
        "cus_phone": widget.customerMobile,
        "opt_a": widget.optA ?? "",
        "opt_b": widget.optB ?? "",
        "opt_c": widget.optC ?? "",
        "opt_d": widget.optD ?? "",
        "type": "json"
      }),
    );
    print(response.body);
    try {
      if (response.statusCode == 200) {
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
