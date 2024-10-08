import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weather_app_tutorial/consts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);

  Weather? _weather;
  String _location = "Peshawar";
  String _displayLocation =
      "Peshawar"; // Variable to store the displayed location name
  bool _hasError = false; // Flag to indicate if there was an error

  @override
  void initState() {
    super.initState();
    _fetchWeather(_location);
  }

  void _fetchWeather(String location) {
    _wf.currentWeatherByCityName(location).then((w) {
      setState(() {
        _weather = w;
        _displayLocation = location; // Update the displayed location name
        _hasError = false; // Reset error flag
      });
    }).catchError((e) {
      setState(() {
        _weather = null;
        _hasError = true; // Set error flag
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Error fetching weather for $location. Please enter a valid location."),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/image.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: _buildUI(),
        ),
      ),
    );
  }

  Widget _buildUI() {
    if (_weather == null && !_hasError) {
      return _buildLoadingUI();
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLocationInput(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
          ),
          _buildDateTimeInfo(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          _buildWeatherIcon(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _buildCurrentTemp(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _buildExtraInfo(),
        ],
      ),
    );
  }

  Widget _buildLoadingUI() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLocationInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Enter location',
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.location_city), // Icon inside the TextField
        ),
        onChanged: (value) {
          _location = value; // Update location as user types
        },
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _fetchWeather(value);
          }
        },
      ),
    );
  }

  Widget _buildDateTimeInfo() {
    if (_hasError) {
      return Text(
        "Invalid location. Please try again.",
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      );
    }
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          _displayLocation, // Display the location name
          style: const TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(
            fontSize: 35,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              "  ${DateFormat("d.M.y").format(now)}",
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherIcon() {
    if (_hasError)
      return Container(); // Return an empty container if there's an error
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
            ),
          ),
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTemp() {
    if (_hasError)
      return Container(); // Return an empty container if there's an error
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 90,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildExtraInfo() {
    if (_hasError) return Container();
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      width: MediaQuery.of(context).size.width * 0.80,
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}° C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                "Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}° C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Wind: ${_weather?.windSpeed?.toStringAsFixed(0)}m/s",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                "Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
