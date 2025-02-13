import 'package:flutter/material.dart';
import 'package:sensor/widget/sensor_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WhiteScreen(),
    );
  }
}

class WhiteScreen extends StatelessWidget {
  const WhiteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WhaTap Sensor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24, // 폰트 크기 증가
            fontWeight: FontWeight.bold, // 굵은 폰트 적용
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: SensorDataChart(),
      backgroundColor: Colors.white,
    );
  }
}
