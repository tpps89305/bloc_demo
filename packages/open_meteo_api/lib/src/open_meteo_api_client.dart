import 'dart:convert';

import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:http/http.dart' as http;

class LocationNotFoundFailure implements Exception {}

class WeatherNotFoundFailure implements Exception {}

class OpenMeteoApiClient {
  OpenMeteoApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrlWeather = 'api.open-meteo.com';
  static const _baseUrlGeocoding = 'geocoding-api.open-meteo.com';

  final http.Client _httpClient;

  Future<Location> locationSearch(String query) async {
    final request = Uri.https(
      _baseUrlGeocoding,
      '/v1/search',
      {'name': query, 'count': '1'},
    );
    final response = await _httpClient.get(request);

    if (response.statusCode != 200) {
      throw LocationNotFoundFailure();
    }

    final locationJson = jsonDecode(response.body) as Map;

    if (!locationJson.containsKey('results')) throw LocationNotFoundFailure();

    final results = locationJson['results'] as List;

    if (results.isEmpty) throw LocationNotFoundFailure();

    return Location.fromJson(results.first as Map<String, dynamic>);
  }

  Future<Weather> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final request = Uri.https(
      _baseUrlWeather,
      '/v1/forecast',
      {
        'latitude': '$latitude',
        'longitude': '$longitude',
        'current_weather': 'true',
      },
    );
    final response = await _httpClient.get(request);

    if (response.statusCode != 200) {
      throw WeatherNotFoundFailure();
    }

    final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;

    if (!bodyJson.containsKey('current_weather')) {
      throw WeatherNotFoundFailure();
    }

    final weatherJson = bodyJson['current_weather'] as Map<String, dynamic>;

    return Weather.fromJson(weatherJson);
  }
}
