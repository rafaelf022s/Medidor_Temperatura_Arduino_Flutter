import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:fl_chart/fl_chart.dart'; // Importar biblioteca de gráficos

// Modelo para representar a leitura de temperatura
class Temperatura {
  final int id;
  final double valor;
  final String dataHora;

  Temperatura({required this.id, required this.valor, required this.dataHora});

  // Função para converter o JSON em um objeto Temperatura
  factory Temperatura.fromJson(Map<String, dynamic> json) {
    return Temperatura(
      id: int.tryParse(json['id'])!,
      valor: double.tryParse(json['valor'])!,
      dataHora: json['data_hora'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leitura de Temperaturas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TemperaturaScreen(),
    );
  }
}

class TemperaturaScreen extends StatefulWidget {
  @override
  _TemperaturaScreenState createState() => _TemperaturaScreenState();
}

class _TemperaturaScreenState extends State<TemperaturaScreen> {
  // ValueNotifier que notificará mudanças na lista de temperaturas
  ValueNotifier<List<Temperatura>> temperaturasNotifier = ValueNotifier([]);

  // Função para fazer a requisição HTTP ao endpoint PHP
  Future<void> fetchTemperaturas() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.100/api/teste/ler_temperatura.php'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Temperatura> temperaturas = data.map((item) => Temperatura.fromJson(item)).toList();

        // Atualiza o ValueNotifier com a nova lista de temperaturas
        temperaturasNotifier.value = temperaturas;
      } else {
        throw Exception('Falha ao carregar dados de temperatura');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // Chama a função para buscar os dados a cada 10 segundos
    Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchTemperaturas();
    });

    // Faz a primeira chamada logo ao iniciar o app
    fetchTemperaturas();
  }

  @override
  void dispose() {
    temperaturasNotifier.dispose(); // Limpar o ValueNotifier quando o widget for destruído
    super.dispose();
  }

  // Função para criar a lista de pontos para o gráfico de linha
  List<FlSpot> _generateSpots(List<Temperatura> temperaturas) {
    List<FlSpot> spots = [];
    for (int i = 0; i < temperaturas.length; i++) {
      spots.add(FlSpot(i.toDouble(), temperaturas[i].valor));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leituras de Temperaturas'),
      ),
      body: ValueListenableBuilder<List<Temperatura>>(
        valueListenable: temperaturasNotifier,
        builder: (context, temperaturas, _) {
          if (temperaturas.isEmpty) {
            return const Center(child: CircularProgressIndicator()); // Exibe um indicador de carregamento
          }
          return Column(
            children: [
              // Adiciona o gráfico de linha
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _generateSpots(temperaturas),
                        isCurved: true,
                        barWidth: 2,
                        color: Colors.blue,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: temperaturas.length,
                  itemBuilder: (context, index) {
                    final temperatura = temperaturas[index];
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID ${temperatura.id} '),
                          Text('Temperatura: ${temperatura.valor} °C'),
                        ],
                      ),
                      subtitle: Text('Data: ${temperatura.dataHora}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
