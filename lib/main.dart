import 'package:bloc_demo/theme/cubit/theme_cubit.dart';
import 'package:bloc_demo/weather/weather_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:weather_repository/weather_repository.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getTemporaryDirectory(),
  );

  runApp(MainApp(weatherRepository: WeatherRepository()));
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required WeatherRepository weatherRepository,
  }) : _weatherRepository = weatherRepository;

  final WeatherRepository _weatherRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _weatherRepository,
      child: BlocProvider(
        create: (_) => ThemeCubit(),
        child: const WeatherAppView(),
      ),
    );
  }
}

class WeatherAppView extends StatelessWidget {
  const WeatherAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<ThemeCubit, Color>(builder: (context, color) {
      return MaterialApp(
        theme: ThemeData(
          primaryColor: color,
          textTheme: GoogleFonts.rajdhaniTextTheme(textTheme),
          appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.rajdhaniTextTheme(textTheme)
                .apply(bodyColor: Colors.white)
                .titleLarge,
          ),
        ),
        home: const WeatherPage(),
      );
    });
  }
}
