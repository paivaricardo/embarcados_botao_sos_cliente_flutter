import 'dart:html';

import 'package:embarcados_botao_sos_cliente_flutter/service/mqtt_service.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MainSOSButtonHomePage extends StatefulWidget {
  const MainSOSButtonHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MainSOSButtonHomePage> createState() => _MainSOSButtonHomePageState();
}

class _MainSOSButtonHomePageState extends State<MainSOSButtonHomePage> {

  String mensagem = "Quando o botão de SOS for ativado, a mensagem aparecerá aqui.";
  bool sosAtivado = false;
  DateTime? sosActivationTime;
  Color backgroundColor = Colors.white;
  Color textColor = Colors.black;
  final MqttService _mqttService = MqttService();

  void ativarSOS() {
    setState(() {
      sosAtivado = true;
      sosActivationTime = DateTime.now();
      mensagem = 'SOS ACIONADO';
      backgroundColor = Colors.red;
      textColor = Colors.white;
    });
  }

  void desativarSOS() {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString('SOS FALSE');
    _mqttService.client.publishMessage('sos_acionado', MqttQos.atLeastOnce, builder.payload!);

    setState(() {
      sosAtivado = false;
      mensagem = 'Quando o botão de SOS for ativado, a mensagem aparecerá aqui.';
      backgroundColor = Colors.white;
      textColor = Colors.black;
    });
  }

  @override
  void initState() {
    super.initState();
    _mqttService.client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>> messages) {
      for (var messagemMQTT in messages) {
        final String topic = messagemMQTT.topic;
        final MqttPublishMessage payload = messagemMQTT.payload as MqttPublishMessage;
        final String data = MqttPublishPayload.bytesToStringAsString(payload.payload.message);

        if (topic == 'sos_acionado') {
          if (data == 'SOS TRUE' && !sosAtivado) {
            ativarSOS();
          } else if (data == 'SOS FALSE' && sosAtivado) {
            setState(() {
              mensagem = "Quando o botão de SOS for ativado, a mensagem aparecerá aqui.";
              backgroundColor = Colors.white;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (sosAtivado)
              Text(
                mensagem,
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: textColor),
                textAlign: TextAlign.center,
              ),
            if (!sosAtivado)
            Text(
              mensagem,
              style: TextStyle(fontSize: 18, color: textColor),
              textAlign: TextAlign.center,
            ),
            if (sosAtivado)
              Text(
                  "Hora da ativação: $sosActivationTime",
                style: TextStyle(fontSize: 18, color: textColor),
              ),
            if (sosAtivado)
              ElevatedButton(
                onPressed: desativarSOS,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                child: const Text('Desativar SOS', style: TextStyle(color: Colors.black),),
              ),
          ],
        ),
      ),
    ),
    );
  }
}