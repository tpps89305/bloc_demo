import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_demo/weather/models/weather.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;

class ThemeCubit extends HydratedCubit {
  ThemeCubit() : super(defaultColor);

  static const defaultColor = Colors.blue;

  updateTheme(Weather? weather) {
    if (weather != null) emit(weather.toColor);
  }

  @override
  fromJson(Map<String, dynamic> json) {
    return Color(int.parse(json['color'] as String));
  }

  @override
  Map<String, dynamic>? toJson(state) {
    return <String, String>{'color': '${state.value}'};
  }
}

extension on Weather {
  Color get toColor {
    switch (condition) {
      case WeatherCondition.clear:
        return Colors.orangeAccent;
      case WeatherCondition.snowy:
        return Colors.lightBlueAccent;
      case WeatherCondition.cloudy:
        return Colors.blueGrey;
      case WeatherCondition.rainy:
        return Colors.indigoAccent;
      case WeatherCondition.unknown:
        return ThemeCubit.defaultColor;
    }
  }
}
