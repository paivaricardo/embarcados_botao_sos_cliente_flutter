import 'package:embarcados_botao_sos_cliente_flutter/main_sos_button_home_page.dart';
import 'package:embarcados_botao_sos_cliente_flutter/service/mqtt_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Conectar ao broker MQTT
  await MqttService().connect();

  // Realizar o subscribe no tópico do botão de SOS
  MqttService().subscribe("sos_acionado");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Botão SOS',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: const MainSOSButtonHomePage(title: 'Serviço de SOS'),
    );
  }
}