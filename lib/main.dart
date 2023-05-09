import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

enum City {
  london,
  stockholm,
  tokyo,
}

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
    const Duration(seconds: 1),
    () => {
      City.london: 'sunny',
      City.stockholm: 'cloudy',
      City.tokyo: 'rainy',
    }[city]!,
  );
}

// UI writes to and reads from this
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);
const unkownWeatherEmoji = 'shrug';
// UI reads this
final weatherProvider = FutureProvider<WeatherEmoji>(
  (ref) {
    final city = ref.watch(currentCityProvider);
    if (city != null) {
      return getWeather(city);
    }
    return unkownWeatherEmoji;
  },
);

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(
      weatherProvider,
    );
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Weather',
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            currentWeather.when(
              data: (data) => Text(
                data,
                style: const TextStyle(
                  fontSize: 40,
                ),
              ),
              error: (_, __) => const Text('Error'),
              loading: () => const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: City.values.length,
                itemBuilder: (context, index) {
                  final city = City.values[index];
                  final isSelected = city == ref.watch(currentCityProvider);
                  return ListTile(
                    title: Text(
                      city.toString(),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.greenAccent,
                          )
                        : null,
                    onTap: () => ref
                        .read(
                          currentCityProvider.notifier,
                        )
                        .state = city,
                  );
                },
              ),
            ),
          ],
        ));
  }
}
