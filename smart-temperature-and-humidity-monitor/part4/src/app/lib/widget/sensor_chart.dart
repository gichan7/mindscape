import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sensor/api/open_api.dart';

import '../model/sensor_data.dart';

const String kToken = 'BO20****************FPHH';
const String kPcode = '10***';
const String kMql = 'CATEGORY sensor\nTAGLOAD\nSELECT';
const int kStartTime = 1738720860000;
const int kEndTime = 1739325660000;

class SensorDataChart extends StatefulWidget {
  const SensorDataChart({super.key});

  @override
  State<SensorDataChart> createState() => _SensorDataChartState();
}


class _SensorDataChartState extends State<SensorDataChart> {


  void apiTest() async {
    final api = WhatapOpenApi(
      token: kToken,
      pcode: kPcode,
    );

    try {
      final result = await api.executeMql(
        mql: kMql,
        startTime: kStartTime,
        endTime: kEndTime,
      );
      if (kDebugMode) {
        print(result);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }


  Future<dynamic> getDataFromAPI() async {
    final api = WhatapOpenApi(
      token: kToken,
      pcode: kPcode,
    );

    try {
      final result = await api.executeMql(
        mql: kMql,
        startTime: kStartTime,
        endTime: kEndTime,
      );
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getDataFromAPI(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final List<SensorData> sensorData =
            SensorData.listFromMap(snapshot.data as List<dynamic>);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '온도 및 습도 모니터링',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                        ),
                        handleBuiltInTouches: true,
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index < 0 || index >= sensorData.length) {
                                return Container();
                              }
                              if (index % 50 != 0) return Container();

                              final time = DateTime.fromMillisecondsSinceEpoch(
                                  sensorData[index].time);
                              String formattedTime =
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  formattedTime,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            },
                            interval: 1,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      ),
                      minX: 0,
                      maxX: (sensorData.length - 1).toDouble(),
                      minY: 15,
                      // 최소값 설정
                      maxY: 40,
                      // 최대값 설정
                      lineBarsData: [
                        // 온도 라인
                        LineChartBarData(
                          spots: List.generate(
                            sensorData.length,
                            (index) => FlSpot(
                              index.toDouble(),
                              sensorData[index].temperature,
                            ),
                          ),
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                        // 습도 라인
                        LineChartBarData(
                          spots: List.generate(
                            sensorData.length,
                            (index) => FlSpot(
                              index.toDouble(),
                              sensorData[index].humidity,
                            ),
                          ),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegend('온도', Colors.red),
                    const SizedBox(width: 20),
                    _buildLegend('습도', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
