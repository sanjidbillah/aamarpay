import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:aamarpay/aamarpay.dart';

void main() {
  runApp(MaterialApp(home: MyPay()));
}

class MyPay extends StatefulWidget {
  const MyPay({super.key});

  @override
  MyPayState createState() => MyPayState();
}

class MyPayState extends State<MyPay> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Aamarpay(
          // This will return a payment url based on failUrl,cancelUrl,successUrl
          returnUrl: (String url) {
            if (kDebugMode) {
              print(url);
            }
          },
          // This will return the payment loading status
          isLoading: (bool loading) {
            setState(() {
              isLoading = loading;
            });
          },
          // This will return the payment state with a message
          status: (EventState event, String message) {
            if (kDebugMode) {
              print(event);
            }
            if (event == EventState.success) {}
          },
          cancelUrl: "example.com/payment/cancel",
          successUrl: "example.com/payment/confirm",
          failUrl: "example.com/payment/fail",
          customerEmail: "masumbillahsanjid@gmail.com",
          customerMobile: "01834760591",
          customerName: "Masum Billah Sanjid",
          // That is the test signature key. But when you go to the production you must use your own signature key
          signature: "37da1e291ac2612ee91cd9736e4ce4f5",
          // That is the test storeID. But when you go to the production you must use your own storeID
          storeID: "subeasy",
          // Use transactionAmountFromTextField when you pass amount with TextEditingController
          // transactionAmountFromTextField: amountTextEditingController,
          transactionAmount: "200",
          //The transactionID must be unique for every payment
          transactionID: "${DateTime.now().millisecondsSinceEpoch}",
          description: "test",
          // When the application goes to the producation the isSandbox must be false
          isSandBox: false,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                  color: Colors.orange,
                  height: 50,
                  child: Center(
                    child: Text(
                      "Payment",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
