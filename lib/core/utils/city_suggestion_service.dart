import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:weather_app/core/utils/logger.dart';

class City {
  final String name;
  final String country;
  final String code;

  City({required this.name, required this.country, required this.code});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] as String,
      country: json['country'] as String,
      code: json['code'] as String,
    );
  }

  @override
  String toString() => '$name, $country';
}

class CitySuggestionService {
  static final CitySuggestionService _instance =
      CitySuggestionService._internal();

  List<City> _cities = [];
  bool _isInitialized = false;

  factory CitySuggestionService() {
    return _instance;
  }

  CitySuggestionService._internal();

  /// Initialize cities from JSON file
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/cities.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final citiesList = (jsonData['cities'] as List)
          .map((city) => City.fromJson(city as Map<String, dynamic>))
          .toList();
      _cities = citiesList;
      _isInitialized = true;
      logger.i('Loaded ${_cities.length} cities');
    } catch (e) {
      logger.e('Error loading cities: $e');
    }
  }

  /// Get city suggestions based on query
  List<City> getSuggestions(String query) {
    if (query.isEmpty) {
      return _cities;
    }

    final lowerQuery = query.toLowerCase();
    return _cities
        .where(
          (city) =>
              city.name.toLowerCase().contains(lowerQuery) ||
              city.country.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Get top N suggestions
  List<City> getTopSuggestions(String query, {int limit = 10}) {
    final suggestions = getSuggestions(query);

    // Sort by relevance: exact match first, then starts with, then contains
    suggestions.sort((a, b) {
      final aNameMatch = a.name.toLowerCase() == query.toLowerCase() ? 0 : 1;
      final bNameMatch = b.name.toLowerCase() == query.toLowerCase() ? 0 : 1;

      if (aNameMatch != bNameMatch) return aNameMatch.compareTo(bNameMatch);

      final aStartsWith = a.name.toLowerCase().startsWith(query.toLowerCase())
          ? 0
          : 1;
      final bStartsWith = b.name.toLowerCase().startsWith(query.toLowerCase())
          ? 0
          : 1;

      return aStartsWith.compareTo(bStartsWith);
    });

    return suggestions.take(limit).toList();
  }

  /// Check if city exists
  bool cityExists(String cityName) {
    return _cities.any(
      (city) => city.name.toLowerCase() == cityName.toLowerCase(),
    );
  }

  /// Get city by name
  City? getCityByName(String cityName) {
    try {
      return _cities.firstWhere(
        (city) => city.name.toLowerCase() == cityName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
