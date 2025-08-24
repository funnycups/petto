// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//
// Project home: https://github.com/funnycups/petto
// Project introduction: https://www.cups.moe/archives/petto.html

import 'package:ipapi/ipapi.dart';
import 'package:ipapi/models/geo_data.dart';
import 'package:open_meteo/open_meteo.dart';
import '../../generated/l10n.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  static WeatherService get instance => _instance;
  
  WeatherService._internal();
  
  Future<String> getWeather() async {
    const weather = WeatherApi();
    final GeoData? geoData = await IpApi.getData();
    
    final response = await weather.request(
      latitude: geoData?.lat ?? 0,
      longitude: geoData?.lon ?? 0,
      current: {WeatherCurrent.weather_code, WeatherCurrent.temperature_2m}
    );
    
    final temperature = 
        response.currentData[WeatherCurrent.temperature_2m]!.value;
    final weatherCode = response.currentData[WeatherCurrent.weather_code]!.value;
    
    String weatherStr = _getWeatherDescription(weatherCode);
    return S.current.currentWeather(weatherStr, temperature);
  }
  
  String _getWeatherDescription(num weatherCode) {
    switch (weatherCode) {
      case 0:
      case 1:
        return S.current.sunny;
      case 2:
        return S.current.cloudy;
      case 3:
        return S.current.overcast;
      case 45:
      case 48:
        return S.current.fog;
      case 51:
      case 53:
      case 55:
        return S.current.drizzle;
      case 56:
      case 57:
        return S.current.freezingDrizzle;
      case 61:
        return S.current.lightRain;
      case 63:
        return S.current.moderateRain;
      case 65:
        return S.current.heavyRain;
      case 66:
      case 67:
        return S.current.freezingRain;
      case 71:
        return S.current.lightSnow;
      case 73:
        return S.current.moderateSnow;
      case 75:
        return S.current.heavySnow;
      case 77:
        return S.current.sleet;
      case 80:
        return S.current.lightShower;
      case 81:
        return S.current.moderateShower;
      case 82:
        return S.current.heavyShower;
      case 85:
        return S.current.lightSnowShower;
      case 86:
        return S.current.heavySnowShower;
      case 95:
        return S.current.thunderstorm;
      case 96:
        return S.current.thunderstormWithSmallHail;
      case 99:
        return S.current.thunderstormWithLargeHail;
      default:
        return S.current.unknown;
    }
  }
  
  static String getSeason(DateTime date) {
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
}