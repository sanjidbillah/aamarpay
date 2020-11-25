# aamarpay

[aamarPay](https://aamarpay.com/) is an online payment gateway service for Bangladesh. Committed to provide best payment experience online for business. Lowest fee and fast checkout will give you good experience of receiving payment online.

![aamarpay](https://i.imgur.com/lAiUw6j.png)

## Requirements 

- Android: `minSdkVersion 17` 
## How to use: 
In the `dependencies`: section of your `pubspec.yaml`, add the following line:
```
dependencies:
     aamarpay: ^0.0.7
```
install packages from the command line:

```
$ flutter pub get
```
Now in your Dart code, you can use:
```
import 'package:flutter/material.dart';
import 'package:aamarpay/aamarpay.dart';

void main() {
  runApp(MaterialApp(
    home: MyPay(),
  ));
}

class MyPay extends StatefulWidget {
  @override
  _MyPayState createState() => _MyPayState();
}

class _MyPayState extends State<MyPay> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AamarpayData(
            returnUrl: (url) {
              print(url);
            },
            isLoading: (v) {
              setState(() {
                isLoading = v;
              });
            },
            paymentStatus: (status) {
              print(status);
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
            transactionID: "doflutter",
            description: "asgsg",
            url: "https://sandbox.aamarpay.com",
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    color: Colors.orange,
                    height: 50,
                    child: Center(
                        child: Text(
                      "Payment",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                  )),
      ),
    );
  }
}


```



- Remember that transaction ID is Unique.



## Check Payment Status

```
 paymentStatus: (Paymentstatus) {
              print(Paymentstatus);
            },
```
## Read return url

```
 returnUrl: (url) {
              print(url);
            },
```
## Read button press event
```
isLoading: (v) {
              setState(() {
                isLoading = v;
              });
            },
```

Find more details in [aamarPay](https://aamarpay.com/) 
