import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/utils/logger.dart';

class TemperatureUnitController extends ChangeNotifier {
  static const String _unitKey = 'temperature_unit';
  String _unit = 'imperial'; // Default to Fahrenheit
  bool _isLoading = true;

  String get unit => _unit;
  bool get isLoading => _isLoading;
  bool get isFahrenheit => _unit == 'imperial';
  bool get isCelsius => _unit == 'metric';
  String get unitSymbol => _unit == 'imperial' ? '°F' : '°C';

  TemperatureUnitController() {
    _loadUnit();
  }

  /// Load saved temperature unit from SharedPreferences
  Future<void> _loadUnit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _unit = prefs.getString(_unitKey) ?? 'imperial';
      logger.d('TemperatureUnitController: Loaded unit = $_unit'); // logger
    } catch (e) {
      _unit = 'imperial';
      logger.e('TemperatureUnitController: Error loading unit: $e'); // logger
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle between Fahrenheit and Celsius
  Future<void> toggleUnit() async {
    _unit = _unit == 'imperial' ? 'metric' : 'imperial';
    logger.d('TemperatureUnitController: Toggled unit to $_unit'); // logger
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_unitKey, _unit);
      logger.d('TemperatureUnitController: Saved unit to SharedPreferences'); // logger
    } catch (e) {
      logger.e('TemperatureUnitController: Error saving unit: $e'); // logger
    }
  }

  /// Set temperature unit directly
  Future<void> setUnit(bool isFahrenheit) async {
    final newUnit = isFahrenheit ? 'imperial' : 'metric';
    if (_unit == newUnit) {
      logger.d('TemperatureUnitController: Unit already set to $newUnit');  // logger
      return;
    }
    
    _unit = newUnit;
    logger.d('TemperatureUnitController: Set unit to $_unit');  // logger
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_unitKey, _unit);
      logger.d('TemperatureUnitController: Saved unit to SharedPreferences'); // logger
    } catch (e) {
      logger.e('TemperatureUnitController: Error saving unit: $e'); // logger
    }
  }
}