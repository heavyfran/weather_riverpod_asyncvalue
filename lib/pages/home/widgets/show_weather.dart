import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/current_weather/app_weather.dart';
import '../../../models/current_weather/current_weather.dart';
import '../../../models/custom_error/custom_error.dart';
import 'select_city.dart';

class ShowWeather extends ConsumerWidget {
  final AsyncValue<CurrentWeather?> weatherState;
  const ShowWeather({
    super.key,
    required this.weatherState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return weatherState.when(
      skipError: true,
      data: (CurrentWeather? weather) {
        print('***** in data callback');

        if (weather == null) {
          return const SelectCity();
        }

        final appWeather = AppWeather.fromCurrentWeather(weather);

        return Center(
          child: Text(
            appWeather.name,
            style: const TextStyle(fontSize: 18),
          ),
        );
      },
      error: (error, stackTrace) {
        print('***** in error callback');
        if (weatherState.value == null) {
          return const SelectCity();
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              (error as CustomError).errMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
