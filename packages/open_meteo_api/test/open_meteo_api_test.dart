import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:open_meteo_api/src/open_meteo_api_client.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  group("OpenMeteoApiClient", () {
    late http.Client httpClient;
    late OpenMeteoApiClient apiClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      apiClient = OpenMeteoApiClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require an httpClient', () {
        expect(OpenMeteoApiClient(), isNotNull);
      });
    });

    group('locationSearch', () {
      const query = 'mock-query';
      test('makes corrent http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any()))
            .thenAnswer((invocation) async => response);
        try {
          await apiClient.locationSearch(query);
        } catch (_) {}
        // 執行 apiClient.locationSearch(query) 後，確認此方法已呼叫過一次。
        verify(
          () => httpClient.get(Uri.https(
            'geocoding-api.open-meteo.com',
            '/v1/search',
            {'name': query, 'count': '1'},
          )),
        ).called(1);
      });

      test('throws LocationRequestFailure on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any()))
            .thenAnswer((invocation) async => response);
        expect(
          () async => apiClient.locationSearch(query),
          throwsA(isA<LocationNotFoundFailure>()),
        );
      });

      test('throws LocationNotFoundFailure on empty response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{"results" : []}');
        when(() => httpClient.get(any()))
            .thenAnswer((invocation) async => response);
        await expectLater(apiClient.locationSearch(query),
            throwsA(isA<LocationNotFoundFailure>()));
      });

      test('returns Location on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('''
{
  "results": [
    {
      "id": 4887398,
      "name": "Chicago",
      "latitude": 41.85003,
      "longitude": -87.65005
    }
  ]
}
''');
        when(() => httpClient.get(any()))
            .thenAnswer((invocation) async => response);
        final actual = await apiClient.locationSearch(query);
        expect(
            actual,
            isA<Location>()
                .having((p0) => p0.name, 'name', 'Chicago')
                .having((p0) => p0.id, 'id', 4887398)
                .having((p0) => p0.latitude, 'latitude', 41.85003)
                .having((p0) => p0.longitude, 'longitude', -87.65005));
      });
    });

    group('getWeather', () {
      const double latitude = 41.85003;
      const double longitude = -87.6500;
      const query = 'mock-query';

      test('makes corrent http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any()))
            .thenAnswer((invocation) async => response);
        try {
          await apiClient.getWeather(latitude: latitude, longitude: longitude);
        } catch (_) {}
        // 執行 apiClient.locationSearch(query) 後，確認此方法已呼叫過一次。
        verify(
          () => httpClient.get(
            Uri.https(
              'api.open-meteo.com',
              '/v1/forecast',
              {
                'latitude': '$latitude',
                'longitude': '$longitude',
                'current_weather': 'true',
              },
            ),
          ),
        ).called(1);
      });

      test('throws LocationRequestFailure on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any()))
            .thenAnswer((invocation) async => response);
        expect(
          () async => await apiClient.getWeather(
              latitude: latitude, longitude: longitude),
          throwsA(isA<WeatherNotFoundFailure>()),
        );
      });

      test('throws LocationNotFoundFailure on empty response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{"results" : []}');
        when(() => httpClient.get(any()))
            .thenAnswer((invocation) async => response);
        expect(
          () async => await apiClient.getWeather(
              latitude: latitude, longitude: longitude),
          throwsA(isA<WeatherNotFoundFailure>()),
        );
      });

      test('returns weather on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('''
{
"latitude": 43,
"longitude": -87.875,
"generationtime_ms": 0.2510547637939453,
"utc_offset_seconds": 0,
"timezone": "GMT",
"timezone_abbreviation": "GMT",
"elevation": 189,
"current_weather": {
"temperature": 15.3,
"windspeed": 25.8,
"winddirection": 310,
"weathercode": 63,
"time": "2022-09-12T01:00"
}
}
''');
        when(() => httpClient.get(any()))
            .thenAnswer((invocation) async => response);
        final actual = await apiClient.getWeather(
            latitude: latitude, longitude: longitude);
        expect(
            actual,
            isA<Weather>()
                .having((p0) => p0.temperature, 'temperature', 15.3)
                .having((p0) => p0.weatherCode, 'weatherCode', 63.0));
      });
    });
  });
}
