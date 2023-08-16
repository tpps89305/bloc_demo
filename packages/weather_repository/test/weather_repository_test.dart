import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart' as open_meteo_api;
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

class MockOpenMeteoAliClient extends Mock
    implements open_meteo_api.OpenMeteoApiClient {}

class MockLocation extends Mock implements open_meteo_api.Location {}

class MockWeather extends Mock implements open_meteo_api.Weather {}

void main() {
  group('WeatherRepository', () {
    late open_meteo_api.OpenMeteoApiClient weatherApiClient;
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherApiClient = MockOpenMeteoAliClient();
      weatherRepository = WeatherRepository(
        weatherApiClient: weatherApiClient,
      );
    });

    group('constructor', () {
      test('instantiates internal weather api client when not injected', () {
        expect(WeatherRepository(), isNotNull);
      });
    });

    group('getWeather', () {
      const city = 'chicago';
      const latitude = 41.85003;
      const longitude = 87.65005;

      test('calls locationSearch with correct city', () async {
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(() => weatherApiClient.locationSearch(city)).called(1);
      });

      test('throws when locationSearch fails', () {
        final exception = Exception('oops');
        when(() => weatherApiClient.locationSearch(any())).thenThrow(exception);
        expect(
            () async => weatherRepository.getWeather(city), throwsA(exception));
      });

      test('calls getWeather with correct latitude/longitude', () async {
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weatherApiClient.locationSearch(any()))
            .thenAnswer((invocation) async => location);
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(
          () => weatherApiClient.getWeather(
              latitude: latitude, longitude: longitude),
        ).called(1);
      });

      test('throws when getWeather fail', () {
        final exception = Exception('oops');
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weatherApiClient.locationSearch(any()))
            .thenAnswer((invocation) async => location);
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenThrow(exception);
        expect(
          () async => weatherRepository.getWeather(city),
          throwsA(exception),
        );
      });

      test('returns correct weather on success (clear)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(0);
        when(() => weatherApiClient.locationSearch(any()))
            .thenAnswer((invocation) async => location);

        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((invocation) async => weather);
        final actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          const Weather(
            location: city,
            temperature: 42.42,
            condition: WeatherCondition.clear,
          ),
        );
      });
    });
  });
}
