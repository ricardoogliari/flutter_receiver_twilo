import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Lista de SMSs'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Sms {
  String address;
  String body;
  String dateNow;
  Sms(String address, String body) {
    this.address = address;
    this.body = body;

    dateNow = DateTime.now().toString();

    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    dateNow = formatter.format(now);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  var smsList = [];

  static const subscriber = const MethodChannel('flutter.native/sms_receiver');

  _MyHomePageState() {
    subscriber.setMethodCallHandler(myHandler);
  }

  Future myHandler(MethodCall call) {
    print(call.arguments);

    Map<String, dynamic> dataArgs = jsonDecode(call.arguments);

    if (dataArgs["address"] != null) {
      var sms = Sms(
          dataArgs["address"].toString(),
          dataArgs["body"].toString()
      );
      setState(() {
        smsList.add(sms);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: smsList.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return
              FlatButton(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.elliptical(7, 7)),
                    border: Border.all(
                      color: Colors.black
                    )
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          smsList[index].dateNow,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          smsList[index].address,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          smsList[index].body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
          }
      ),
    );
  }
}
