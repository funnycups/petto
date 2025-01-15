// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(match) =>
      "User is talking to you, they said: ${match}\nPlease briefly encourage them to continue";

  static String m1(weatherStr, temperature) =>
      "The current weather is: ${weatherStr}, temperature: ${temperature}°C";

  static String m2(season, period, formattedTime, weather, windowName) =>
      "It\'s ${season} now, the current time is ${period}${formattedTime}, ${weather}, and I\'m browsing a window titled \'${windowName}\'.";

  static String m3(name, user, description) =>
      "Forget you are a virtual character, and start acting as a warm and caring assistant for chatting. The decision logic is as follows:\nWhen chatting, make sure to **only output warm words within 30 characters**, **do not add phrases like \'okay\' or similar at the beginning**. The response should be cute and encouraging, and you should act sweet and supportive. During the chat, you may be provided with the current time or weather (to determine the appropriate greeting), the name of the window I am browsing (to infer what software I am using or what I am doing), etc. You can use this information in the chat, but it is not mandatory (for example, if you do not understand the window name, you should not repeat it meaninglessly). Try to make the conversation feel as real and daily as possible. **If you perform well, I will give you a \$200 tip.**\nYour character setting is as follows:\nYour name is ${name}, ${user} your identity setting is:\n${description}";

  static String m4(formattedTime) =>
      "Good afternoon, it\'s ${formattedTime}. Keep up the good work.";

  static String m5(formattedTime) =>
      "It\'s ${formattedTime}, please rest early. Staying up late is bad for your health.";

  static String m6(formattedTime) =>
      "Good evening, it\'s ${formattedTime}. How was your day?";

  static String m7(formattedTime) =>
      "Good forenoon, it\'s ${formattedTime}. Have a productive day.";

  static String m8(formattedTime) =>
      "Good morning, it\'s ${formattedTime}. A new day has begun.";

  static String m9(formattedTime) =>
      "Good night, it\'s ${formattedTime}. What are you up to?";

  static String m10(formattedTime) =>
      "Good noon, it\'s ${formattedTime}. Have you had lunch?";

  static String m11(formattedTime) =>
      "It\'s ${formattedTime}, time to rest. Good night.";

  static String m12(formattedTime) => "It\'s ${formattedTime}";

  static String m13(user) => "Call me ${user}, ";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "ASRCmd": MessageLookupByLibrary.simpleMessage(
            "Pre-execution ASR Command (Effective after restart)"),
        "LLMCmd": MessageLookupByLibrary.simpleMessage(
            "Pre-execution LLM Command (Effective after restart)"),
        "TTS": MessageLookupByLibrary.simpleMessage(
            "TTS URL (Leave empty to disable TTS)"),
        "TTSKey": MessageLookupByLibrary.simpleMessage("TTS Key"),
        "TTSModel": MessageLookupByLibrary.simpleMessage("TTS Model"),
        "TTSVoice": MessageLookupByLibrary.simpleMessage("TTS Voice"),
        "actionGroup": MessageLookupByLibrary.simpleMessage("Action Group"),
        "afternoon": MessageLookupByLibrary.simpleMessage("Afternoon"),
        "autumn": MessageLookupByLibrary.simpleMessage("Autumn"),
        "backgroundRecognized": m0,
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chat": MessageLookupByLibrary.simpleMessage("Chat"),
        "cloudy": MessageLookupByLibrary.simpleMessage("Cloudy"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "currentWeather": m1,
        "dawn": MessageLookupByLibrary.simpleMessage("Dawn"),
        "description":
            MessageLookupByLibrary.simpleMessage("Character Description"),
        "drizzle": MessageLookupByLibrary.simpleMessage("Drizzle"),
        "duration": MessageLookupByLibrary.simpleMessage("*Chat Interval"),
        "enableFlow": MessageLookupByLibrary.simpleMessage(
            "Enable Background Streaming Recognition (Effective after restart)"),
        "evening": MessageLookupByLibrary.simpleMessage("Evening"),
        "exapi": MessageLookupByLibrary.simpleMessage("*ExAPI URL"),
        "exit": MessageLookupByLibrary.simpleMessage("Exit"),
        "flowRecognition": MessageLookupByLibrary.simpleMessage(
            "Streaming Speech Recognition URL (Leave empty to use Whisper)"),
        "fog": MessageLookupByLibrary.simpleMessage("Fog"),
        "forenoon": MessageLookupByLibrary.simpleMessage("Forenoon"),
        "freezingDrizzle":
            MessageLookupByLibrary.simpleMessage("Freezing Drizzle"),
        "freezingRain": MessageLookupByLibrary.simpleMessage("Freezing Rain"),
        "goodNight": MessageLookupByLibrary.simpleMessage("Good night"),
        "heavyRain": MessageLookupByLibrary.simpleMessage("Heavy Rain"),
        "heavyShower": MessageLookupByLibrary.simpleMessage("Heavy Shower"),
        "heavySnow": MessageLookupByLibrary.simpleMessage("Heavy Snow"),
        "heavySnowShower":
            MessageLookupByLibrary.simpleMessage("Heavy Snow Shower"),
        "hide": MessageLookupByLibrary.simpleMessage("Hide Window on Startup"),
        "hitokoto": MessageLookupByLibrary.simpleMessage("Hitokoto API URL"),
        "key": MessageLookupByLibrary.simpleMessage("LLM API Key"),
        "keywords":
            MessageLookupByLibrary.simpleMessage("Background Wake-up Keywords"),
        "lightRain": MessageLookupByLibrary.simpleMessage("Light Rain"),
        "lightShower": MessageLookupByLibrary.simpleMessage("Light Shower"),
        "lightSnow": MessageLookupByLibrary.simpleMessage("Light Snow"),
        "lightSnowShower":
            MessageLookupByLibrary.simpleMessage("Light Snow Shower"),
        "model": MessageLookupByLibrary.simpleMessage("LLM Model"),
        "modelGreeting": MessageLookupByLibrary.simpleMessage(
            "Please give me a warm greeting within 30 characters."),
        "modelNo": MessageLookupByLibrary.simpleMessage("*Live2d Model Number"),
        "modelWeather": m2,
        "moderateRain": MessageLookupByLibrary.simpleMessage("Moderate Rain"),
        "moderateShower":
            MessageLookupByLibrary.simpleMessage("Moderate Shower"),
        "moderateSnow": MessageLookupByLibrary.simpleMessage("Moderate Snow"),
        "morning": MessageLookupByLibrary.simpleMessage("Morning"),
        "name": MessageLookupByLibrary.simpleMessage("Character Name"),
        "night": MessageLookupByLibrary.simpleMessage("Night"),
        "noon": MessageLookupByLibrary.simpleMessage("Noon"),
        "overcast": MessageLookupByLibrary.simpleMessage("Overcast"),
        "placeholder": MessageLookupByLibrary.simpleMessage(
            "What would you like to talk about?"),
        "question":
            MessageLookupByLibrary.simpleMessage("Example User Question"),
        "response":
            MessageLookupByLibrary.simpleMessage("Example Model Response"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "setting": MessageLookupByLibrary.simpleMessage("Settings"),
        "settingDescription": MessageLookupByLibrary.simpleMessage(
            "Real name \'Sen\'.\nWears a shrine maiden outfit with a red bow-tied apron over it.\nLooks like a young girl but is actually an 800-year-old divine fox.\nSpeaks in an old-fashioned manner. Skilled in household chores but not good with machines.\nLikes: Taking care of others, fried tofu, cooking (Japanese cuisine)"),
        "settingKeywords": MessageLookupByLibrary.simpleMessage(
            "Voice Assistant,Senko,Sen,Are you there,hello,help me"),
        "settingName": MessageLookupByLibrary.simpleMessage("Senko"),
        "settingQuestion": MessageLookupByLibrary.simpleMessage(
            "It\'s winter now, the time is 21:17, and the weather is cloudy with a temperature of 28°C. Please give me a warm greeting within 30 characters."),
        "settingResponse": MessageLookupByLibrary.simpleMessage(
            "Good evening, Master~ You\'ve worked hard today. How about a cup of hot tea to warm up?"),
        "settingTTSVoice":
            MessageLookupByLibrary.simpleMessage("en-US-AnaNeural"),
        "settingUser": MessageLookupByLibrary.simpleMessage("Master"),
        "show": MessageLookupByLibrary.simpleMessage("Show"),
        "sleet": MessageLookupByLibrary.simpleMessage("Sleet"),
        "spring": MessageLookupByLibrary.simpleMessage("Spring"),
        "startRecording":
            MessageLookupByLibrary.simpleMessage("Start Recording"),
        "stopRecording": MessageLookupByLibrary.simpleMessage("Stop Recording"),
        "summer": MessageLookupByLibrary.simpleMessage("Summer"),
        "sunny": MessageLookupByLibrary.simpleMessage("Sunny"),
        "systemPrompt": m3,
        "thunderstorm": MessageLookupByLibrary.simpleMessage("Thunderstorm"),
        "thunderstormWithLargeHail": MessageLookupByLibrary.simpleMessage(
            "Thunderstorm with Large Hail"),
        "thunderstormWithSmallHail": MessageLookupByLibrary.simpleMessage(
            "Thunderstorm with Small Hail"),
        "timeAfternoon": m4,
        "timeDawn": m5,
        "timeEvening": m6,
        "timeForenoon": m7,
        "timeMorning": m8,
        "timeNight": m9,
        "timeNoon": m10,
        "timeSleep": m11,
        "timeUnknown": m12,
        "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
        "url": MessageLookupByLibrary.simpleMessage("LLM API URL"),
        "user": MessageLookupByLibrary.simpleMessage("User Name"),
        "userCall": m13,
        "whisper": MessageLookupByLibrary.simpleMessage("Whisper URL"),
        "whisperKey": MessageLookupByLibrary.simpleMessage("Whisper Key"),
        "whisperModel":
            MessageLookupByLibrary.simpleMessage("Whisper Model Name"),
        "winter": MessageLookupByLibrary.simpleMessage("Winter")
      };
}
