import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(new MaterialApp(
      home: new HomePage(),
    ));

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  String _textString = '0';

  void _convertTo(String result) {
    setState(() {
      _textString = result;
    });
  }

//   final TextEditingController _userController = new TextEditingController();

// final String url = 'https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?valcode=[CURRENCY]&date=20190815&json';
  List data;

  @override
  void initState() {
    super.initState();
    this.getJsonData();
  }

  String _value = 'USD';

  void _onPressed(String value) {
    setState(() {
      _value = value;
//       print(_value);
    });
  }

  Future<String> getJsonData() async {
    var currentDay = new DateFormat("yyyyMMdd").format(new DateTime.now());

    Uri uri = new Uri.https(
        "bank.gov.ua",
        "/NBUStatService/v1/statdirectory/exchange",
        {"valcode": _value, "date": currentDay, "json": ""});

//   print(uri.toString());
    var response = await http.get(uri, headers: {"Accept": "application/json"});

//  print(response.body);

    setState(() {
      var convertDataToJson = json.decode(response.body);
      data = convertDataToJson;
    });

    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Hryvnia To"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.autorenew),
              onPressed: () {
                getJsonData();
              })
        ],
      ),
      body: new ListView.builder(
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (BuildContext context, int index) {
          String moneyName = data[index]['txt'];
          String moneyCurrency = data[index]['rate'].toString();
          String moneyCurrencyDate = data[index]['exchangedate'].toString();
          return new Container(
            child: new Center(
              child: new Container(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    new Container(
                        child: new Row(children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          onPressed: () {
                            _onPressed('USD');
                            getJsonData();
                          },
                          child: new Text('USD'),
                        ),
                      ),
                      Expanded(
                        child: RaisedButton(
                          onPressed: () {
                            _onPressed('EUR');
                            getJsonData();
                          },
                          child: new Text('EUR'),
                        ),
                      ),
                      Expanded(
                        child: RaisedButton(
                          onPressed: () {
                            _onPressed('PLN');
                            getJsonData();
                          },
                          child: new Text('PLN'),
                        ),
                      )
                    ])),
                    new Card(
                        child: new Container(
                      child: new Text(moneyName + ' ' + moneyCurrency),
                      padding: const EdgeInsets.all(20.0),
                    )),
                    new Container(
                        child: new Container(
                      child: new Text(
                        moneyCurrencyDate,
                        textAlign: TextAlign.left,
                      ),
                      padding: const EdgeInsets.all(20.0),
                    )),
                    new Container(
                        child: new Container(
                      child: new TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Enter Value'),
                        keyboardType: TextInputType.number,
                        onChanged: (text) {
                          var hryvna = int.parse(text);
                          var currencyMoney = data[index]['rate'];
                          var result = hryvna / currencyMoney;

                          _convertTo(result.toStringAsFixed(2));
                        },
                      ),
                      padding: const EdgeInsets.all(20.0),
                    )),
                    new Container(
                        child: new Container(
                      child: new Text(
                        _textString,
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.5,
                      ),
                      padding: const EdgeInsets.all(20.0),
                    )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
