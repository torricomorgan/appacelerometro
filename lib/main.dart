// @dart=2.9
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sensors/sensors.dart';

 //flutter run --no-sound-null-safety

void main()=>runApp(MiApp());

class MiApp extends StatelessWidget {
  const MiApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Mi App",
      home: Inicio(),
    );
  }
}

class Inicio extends StatefulWidget {
  Inicio({Key key}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  List<double> _accelerometerValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Future<String> sendData(var e) async{
    DateTime fechahora = DateTime.now();
    String fechaformato = DateFormat('yyyy-MM-ddTHH:mm:ss').format(fechahora);
    var response = await http.post(
      Uri.encodeFull("https://apiproductormatias.azurewebsites.net/api/data"),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode(<String, String>{
        "NameDevice":"Huawei Mate 20",
        "EventDateTime":fechaformato,
        "Event":e.toString()})
      );
      print(response.body);
    return response.body;
  }
  @override
  Widget build(BuildContext context) {
    final List<String> accelerometer = _accelerometerValues.map((double v) => v.toStringAsFixed(1)).toList();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Acelerometro'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                accelerometer.toString(),
                style: TextStyle(fontSize: 25),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),

              new ElevatedButton(
                onPressed: (){
                  sendData(accelerometer); 
                },
                child: new Text("Enviar datos")
              ),
              
            ],
          ),
        ),
      ),
    );
  }
   @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
  }
}
