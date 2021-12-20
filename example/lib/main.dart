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
  String amount = "";

  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                icon: Icon(Icons.money),
                hintText: 'Amount',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  amount = value;
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            Aamarpay(
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
              transactionAmount: _amountController.text,
              transactionID: "hhf88bjgjiiny",
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
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
