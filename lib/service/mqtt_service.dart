import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  final MqttServerClient client;

  factory MqttService() => _instance;

  MqttService._internal() : client = MqttServerClient('test.mosquitto.org', 'BOTAOSOSFLUTTER215151');

  Future<void> connect() async {
    client.logging(on: true);

    final connMess = MqttConnectMessage()
        .withClientIdentifier('BOTAOSOSFLUTTER215151')
        .startClean() // Non-persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('CONECTANDO AO BROKER MQTT MOSQUITTO');
    client.connectionMessage = connMess;

    try {
      await client.connect();
      print('CLIENTE MQTT CONECTADO');
    } on NoConnectionException catch (e) {
      print('Client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('Socket exception - $e');
      client.disconnect();
    }
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
    print("INSCRITO NO TÓPICO " + topic);
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>> messages) {
      for (var message in messages) {
        final String topic = message.topic;
        final MqttPublishMessage payload = message.payload as MqttPublishMessage;
        final String data = MqttPublishPayload.bytesToStringAsString(payload.payload.message!);
        print('Recebida a mensagem: Tópico=$topic, Conteúdo=$data');
      }
    });
  }
}
