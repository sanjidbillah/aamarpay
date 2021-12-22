import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'web_view.dart';
import 'dart:convert';

enum eventState { initial, success, error }
enum paymentStatus { SUCCESS, CANCEL, FAIL }
typedef PaymentStatus<T> = void Function(T value);
typedef IsLoadingStaus<T> = void Function(T value);
typedef ReadUrl<T> = void Function(T value);
typedef ReadError<T> = void Function(T value);

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
  final PaymentStatus<paymentStatus>? onPaymentStatus;
  final IsLoadingStaus<bool>? onLoadingState;
  final ReadUrl<String>? onReturnUrl;
  final ReadError<String>? onErrorMessage;
  final Status<eventState>? onStatusEvent;
  final String? customerAddress1;
  final String? customerAddress2;
  final String? customerCity;
  final String? customerState;
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
      this.onPaymentStatus,
      this.onLoadingState,
      required this.child,
      this.onReturnUrl,
      this.onErrorMessage,
      this.onStatusEvent,
      this.customerAddress1,
      this.customerAddress2,
      this.customerCity,
      this.customerState,
      this.customerPostCode});

  @override
  _AamarpayState createState() => _AamarpayState();
}

class _AamarpayState<T> extends State<Aamarpay> {
  void paymentHandler(paymentStatus value) {
    widget.onPaymentStatus?.call(value);
  }

  void loadingHandler(bool value) {
    widget.onLoadingState?.call(value);
  }

  void urlHandler(String value) {
    widget.onReturnUrl?.call(value);
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
          String url =
              "${widget.isSandBox ? _sandBoxUrl : _productionUrl}$value";

          Future.delayed(Duration(milliseconds: 200), () async {
            if (value != null) {
              loadingHandler(false);
              Route route =
                  MaterialPageRoute(builder: (context) => AAWebView(url));
              Navigator.push(context, route).then((value) {
                if (value.split('/').contains("confirm") ||
                    value.split('/').contains("success")) {
                  urlHandler(value);
                  paymentHandler(paymentStatus.SUCCESS);
                } else if (value.split('/').contains("cancel")) {
                  urlHandler(value);
                  paymentHandler(paymentStatus.CANCEL);
                } else if (value.split("/").contains("fail")) {
                  urlHandler(value);
                  paymentHandler(paymentStatus.FAIL);
                } else {
                  urlHandler(value);
                  paymentHandler(paymentStatus.FAIL);
                }
              });
            }
          });
        });
      },
    );
  }

  Future _getPayment() async {
    try {
      widget.onStatusEvent?.call(eventState.initial);
      http.Response response = await http.post(
          Uri.parse(
              "${widget.isSandBox ? _sandBoxUrl : _productionUrl}/index.php"),
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
            "cus_add1": widget.customerAddress1 ?? 'Address 1',
            "cus_add2": widget.customerAddress2 ?? 'Address 2',
            "cus_city": widget.customerCity ?? 'City',
            "cus_state": widget.customerState ?? "State",
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
        try {
          String url = res.substring(startIndex + start.length, endIndex);
          widget.onStatusEvent?.call(eventState.success);
          return url;
        } catch (e) {
          Map<String, dynamic> keyMap = jsonDecode(response.body);
          String errorText = keyMap.isNotEmpty
              ? keyMap.values.toList()[0]
              : 'Unknown error, please try again';
          throw CustomException(errorText);
        }
      } else if (response.statusCode == 400) {
        throw CustomException('Bad request! , please try again');
      } else if (response.statusCode == 401) {
        throw CustomException('Unauthorized! , please try again');
      } else if (response.statusCode == 404) {
        throw CustomException('Page not found! , please try again');
      } else if (response.statusCode == 500) {
        throw CustomException('Internal server error! , please try again');
      } else {
        throw CustomException('Unknown error, please try again');
      }
    } catch (error) {
      widget.onStatusEvent?.call(eventState.error);
      if (error is CustomException) {
        widget.onErrorMessage?.call(error.toString());
      } else {
        widget.onErrorMessage?.call('Unknown error, please try again');
      }
    }
  }
}

abstract class PaymentException implements Exception {
  const PaymentException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'Exception';
}

class CustomException extends PaymentException {
  const CustomException([String? message]) : super(message);
}
