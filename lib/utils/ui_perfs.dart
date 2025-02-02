import 'package:shared_preferences/shared_preferences.dart';

class UiPerfs {
  static final UiPerfs singleton = UiPerfs._internal();

  factory UiPerfs() {
    return singleton;
  }

  UiPerfs._internal();

  bool _trainNerdMode = false;
  bool get trainNerdMode => _trainNerdMode;
  set trainNerdMode(bool value) => _setTrainNerdMode(value);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _trainNerdMode = prefs.getBool('trainNerdMode') ?? false;
    _xDripImageMode = prefs.getBool('xDripImageMode') ?? false;
  }

  void _setTrainNerdMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _trainNerdMode = value;
    prefs.setBool('trainNerdMode', value);
  }

  bool _xDripImageMode = false;
  bool get xDripImageMode => _xDripImageMode;
  set xDripImageMode(bool value) => _setxDripImageMode(value);

  void _setxDripImageMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _xDripImageMode = value;
    prefs.setBool('xDripImageMode', value);
  }
}
