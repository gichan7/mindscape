import 'dart:convert';

class SensorData {
  final int time;
  final double temperature;
  final double humidity;

  SensorData({
    required this.time,
    required this.temperature,
    required this.humidity,
  });

  factory SensorData.fromJson(String str) => SensorData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SensorData.fromMap(Map<String, dynamic> json) => SensorData(
    time: json["time"],
    temperature: json["temperature"]?.toDouble(),
    humidity: json["humidity"]?.toDouble(),
  );

  static List<SensorData> listFromMap(List<dynamic> list) =>
      list.map((e) => SensorData.fromMap(e as Map<String, dynamic>)).toList();

  Map<String, dynamic> toMap() => {
    "time": time,
    "temperature": temperature,
    "humidity": humidity,
  };
}
