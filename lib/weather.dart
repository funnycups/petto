import 'package:ipapi/ipapi.dart';
import 'package:ipapi/models/geo_data.dart';
import 'package:open_meteo/open_meteo.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';

//import 'package:public_ip_address/public_ip_address.dart';
//Not using this package since it is unstable

Future<String> getWeather() async {
  const weather = WeatherApi();
  //IpAddress ipAddress = IpAddress();
  final GeoData? geoData = await IpApi.getData();
  //print(geoData?.lat);
  //print(geoData?.lon);
  final response = await weather.request(
      latitude: geoData?.lat ?? 0,
      longitude: geoData?.lon ?? 0,
      current: {WeatherCurrent.weather_code, WeatherCurrent.temperature_2m});
  final temperature =
      response.currentData[WeatherCurrent.temperature_2m]!.value;
  final weatherCode = response.currentData[WeatherCurrent.weather_code]!.value;
  String weatherStr;
  switch (weatherCode) {
    case 0:
    case 1:
      weatherStr = S.current.sunny;
      break;
    case 2:
      weatherStr = S.current.cloudy;
      break;
    case 3:
      weatherStr = S.current.overcast;
      break;
    case 45:
    case 48:
      weatherStr = S.current.fog;
      break;
    case 51:
    case 53:
    case 55:
      weatherStr = S.current.drizzle;
      break;
    case 56:
    case 57:
      weatherStr = S.current.freezingDrizzle;
      break;
    case 61:
      weatherStr = S.current.lightRain;
      break;
    case 63:
      weatherStr = S.current.moderateRain;
      break;
    case 65:
      weatherStr = S.current.heavyRain;
      break;
    case 66:
    case 67:
      weatherStr = S.current.freezingRain;
      break;
    case 71:
      weatherStr = S.current.lightSnow;
      break;
    case 73:
      weatherStr = S.current.moderateSnow;
      break;
    case 75:
      weatherStr = S.current.heavySnow;
      break;
    case 77:
      weatherStr = S.current.sleet;
      break;
    case 80:
      weatherStr = S.current.lightShower;
      break;
    case 81:
      weatherStr = S.current.moderateShower;
      break;
    case 82:
      weatherStr = S.current.heavyShower;
      break;
    case 85:
      weatherStr = S.current.lightSnowShower;
      break;
    case 86:
      weatherStr = S.current.heavySnowShower;
      break;
    case 95:
      weatherStr = S.current.thunderstorm;
      break;
    case 96:
      weatherStr = S.current.thunderstormWithSmallHail;
      break;
    case 99:
      weatherStr = S.current.thunderstormWithLargeHail;
      break;
    default:
      weatherStr = S.current.unknown;
  }
  return S.current.currentWeather(weatherStr, temperature);
}

String getSeason(DateTime date) {
  int month = date.month;
  if (month >= 4 && month <= 5) {
    return S.current.spring;
  } else if (month >= 6 && month <= 9) {
    return S.current.summer;
  } else if (month >= 10 && month <= 11) {
    return S.current.autumn;
  } else {
    return S.current.winter;
  }
}
