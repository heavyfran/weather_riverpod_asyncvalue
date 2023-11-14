import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/constants.dart';
import '../../extensions/async_value_xx.dart';
import '../../models/current_weather/app_weather.dart';
import '../../models/current_weather/current_weather.dart';
import '../../models/custom_error/custom_error.dart';
import '../../widgets/error_dialog.dart';
import '../search/search_page.dart';
import '../temp_settings/temp_settings_page.dart';
import 'providers/theme_provider.dart';
import 'providers/theme_state.dart';
import 'providers/weather_provider.dart';
import 'widgets/show_weather.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? city;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CurrentWeather?>>(
      weatherProvider,
      (previous, next) {
        next.whenOrNull(
          data: (CurrentWeather? currentWeather) {
            if (currentWeather == null) {
              return;
            }
            final weather = AppWeather.fromCurrentWeather(currentWeather);

            if (weather.temp < kWarmOrNot) {
              ref.read(themeProvider.notifier).changeTheme(const DarkTheme());
            } else {
              ref.read(themeProvider.notifier).changeTheme(const LightTheme());
            }
          },
          error: (error, stackTrace) {
            errorDialog(context, (error as CustomError).errMsg);
          },
        );
      },
    );

    final weatherState = ref.watch(weatherProvider);
    print(weatherState.toStr);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            onPressed: () async {
              city = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
              print('city: $city');
              if (city != null) {
                ref.read(weatherProvider.notifier).fetchWeather(city!);
              }
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TempSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ShowWeather(weatherState: weatherState),
      floatingActionButton: FloatingActionButton(
        onPressed: city == null
            ? null
            : () {
                ref.read(weatherProvider.notifier).fetchWeather(city!);
              },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
