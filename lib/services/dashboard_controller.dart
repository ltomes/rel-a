import 'dart:typed_data';

import 'package:fahrplan/models/android/weather_data.dart';
import 'package:fahrplan/models/g1/dashboard.dart';
import 'package:fahrplan/models/g1/time_weather.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fahrplan/services/xdrip_sgv_service.dart';
import 'package:fahrplan/models/android/xdrip_sgv_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class SgvData {
  final String id;
  final String device;
  final DateTime dateString;
  final int sysTime;
  final int date;
  final int sgv;
  final double delta;
  final String direction;
  final int noise;
  final int filtered;
  final int unfiltered;
  final int rssi;
  final String type;
  final String unitsHint;

  SgvData.fromJsonMap(Map<String, dynamic> json)
      : id = json['_id'],
        device = json['device'],
        dateString = DateTime.parse(json['dateString']),
        sysTime = json['sysTime'] as int,
        date = json['date'],
        sgv = json['sgv'],
        delta = json['delta'].toDouble(),
        direction = json['direction'],
        noise = json['noise'],
        filtered = json['filtered'],
        unfiltered = json['unfiltered'],
        rssi = json['rssi'],
        type = json['type'],
        unitsHint = json['units_hint'];
}

class DashboardController {
  static final DashboardController _singleton = DashboardController._internal();

  List<int> dashboardLayout = DashboardLayout.DASHBOARD_DUAL;

  factory DashboardController() {
    return _singleton;
  }

  DashboardController._internal();

  int _seqId = 0;

  Future<TimeFormat> _getTimeFormatFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final is24h = prefs.getBool('timeIs24h');
    if (is24h == null) {
      return TimeFormat.TWENTY_FOUR_HOUR;
    }
    if (!is24h) {
      return TimeFormat.TWELVE_HOUR;
    }

    return TimeFormat.TWENTY_FOUR_HOUR;
  }

  Future<TemperatureUnit> _getTemperatureUnitFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isCelcius = prefs.getBool('temperatureIsCelcius');
    if (isCelcius == null) {
      return TemperatureUnit.CELSIUS;
    }
    if (!isCelcius) {
      return TemperatureUnit.FAHRENHEIT;
    }

    return TemperatureUnit.CELSIUS;
  }

  Future<List<Uint8List>> updateDashboardCommand() async {
    List<Uint8List> commands = [];
    int temp = 0;
    int weatherIcon = WeatherIcons.NOTHING;
    int? glucose;
    late List<SgvResponse> sgvData;
    final sgvService = SgvService(); // Initialize the service here
    final weather = await WeatherProvider.getWeather();

    if (weather != null) {
      temp = (weather.currentTemp ?? 0) - 273; // currentTemp is in kelvin
      weatherIcon = WeatherIcons.fromOpenWeatherMapConditionCode(
          weather.currentConditionCode ?? 0);
    }
    sgvData = await sgvService.fetchSgvData();
    if (sgvData.isNotEmpty) {
      glucose = (sgvData[sgvData.length-1].sgv ?? 0);
    }
    if (glucose != null) {
      commands.add(TimeAndWeather(
        temperatureUnit: await _getTemperatureUnitFromPreferences(),
        timeFormat: await _getTimeFormatFromPreferences(),
        temperatureInCelsius: temp,
        weatherIcon: weatherIcon,
        glucose: glucose,
      ).buildAddCommand(_seqId++));
    } else {
      commands.add(TimeAndWeather(
        temperatureUnit: await _getTemperatureUnitFromPreferences(),
        timeFormat: await _getTimeFormatFromPreferences(),
        temperatureInCelsius: temp,
        weatherIcon: weatherIcon,
      ).buildAddCommand(_seqId++));
    }

    List<int> dashlayoutCommand =
        DashboardLayout.DASHBOARD_CHANGE_COMMAND.toList();
    dashlayoutCommand.addAll(dashboardLayout);

    commands.add(Uint8List.fromList(dashlayoutCommand));

    return commands;
  }
}
