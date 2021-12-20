import 'package:flutter/material.dart';
import 'package:aamarpay/aamarpay.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyPay(),
    ),
  );
}

class MyPay extends StatefulWidget {
  const MyPay({Key? key}) : super(key: key);

  @override
  _MyPayState createState() => _MyPayState();
}

class _MyPayState extends State<MyPay> {
  bool onLoadingState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Aamarpay(
          onReturnUrl: (url) {
            print(url);
          },
          onLoadingState: (v) {
            setState(() {
              onLoadingState = v;
            });
          },
          onErrorMessage: (msg) {
            print(msg);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
              ),
            );
          },
          onPaymentStatus: (status) {
            print(status);
          },
          onStatusEvent: (eventState event) {
            if (event == eventState.error) {
              setState(() {
                onLoadingState = false;
              });
            }
          },
          cancelUrl: "example.com/payment/cancel",
          successUrl: "example.com/payment/confirm",
          failUrl: "example.com/payment/fail",
          customerEmail: "masumbillahsanjid@gmail.com",
          customerMobile: "01834760591",
          customerName: "Masum Billah Sanjid",
          signature: "dbb74894e82415a2f7ff0ec3a97e4183",
          storeID: "aamarpaytest",
          transactionAmount: "100",
          transactionID: "transactionID",
          description: "test",
          isSandBox: true,
          child: onLoadingState
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  color: Colors.orange,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "Payment",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
