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
    return temperaturas.map((temp) => FlSpot(temp.id.toDouble(), temp.valor)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Estação Meteorológica',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Temperatura>>(
        valueListenable: temperaturasNotifier,
        builder: (context, temperaturas, _) {
          if (temperaturas.isEmpty) {
            return const Center(child: CircularProgressIndicator()); // Exibe um indicador de carregamento
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Adiciona o gráfico de linha
                const SizedBox(height: 10,),
                SizedBox(
                  height: 300,
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Container(
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      value.toInt().toString(), // Mostrar o ID no eixo X
                                      style: const TextStyle(color: Colors.black, fontSize: 10),
                                    )
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(1), // Mostrar a temperatura no eixo Y direito
                                    style: const TextStyle(color: Colors.black, fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              // Desativar os títulos do lado esquerdo
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              // Desativar os títulos do lado esquerdo
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              bottom: BorderSide(color: Colors.black, width: 2), // Borda inferior
                              right: BorderSide(color: Colors.black, width: 2), // Borda direita
                            ),
                          ),
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
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Legenda:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('Eixo X: ID das Leituras'),
                const Text('Eixo Y: Valor da Temperatura (°C)'),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: temperaturas.length,
                    itemBuilder: (context, index) {
                      final temperatura = temperaturas[index];
                      return Card(
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID ${temperatura.id} '),
                              Text('Temperatura: ${temperatura.valor} °C'),
                            ],
                          ),
                          subtitle: Text('Data: ${temperatura.dataHora}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
