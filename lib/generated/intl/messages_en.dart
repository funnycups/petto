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

  static String m1(hotkey) => "Current: ${hotkey}";

  static String m2(weatherStr, temperature) =>
      "The current weather is: ${weatherStr}, temperature: ${temperature}°C";

  static String m3(fileName) => "File: ${fileName}";

  static String m4(count) => "Fetched ${count} expressions";

  static String m5(error) => "Failed to fetch expressions: ${error}";

  static String m6(season, period, formattedTime, weather) =>
      "It\'s ${season} now, the current time is ${period}${formattedTime}, ${weather}.";

  static String m7(name, user, description) =>
      "Forget you are a virtual character, and start acting as a warm and caring assistant for chatting. The decision logic is as follows:\nWhen chatting, make sure to **only output warm words within 30 characters**, **do not add phrases like \'okay\' or similar at the beginning**. The response should be cute and encouraging, and you should act sweet and supportive. During the chat, you may be provided with the current time or weather (to determine the appropriate greeting), the info of the window I am browsing (to infer what software I am using or what I am doing), etc. You can use this information in the chat, but it is not mandatory (for example, if you do not understand the window name, you should not repeat it meaninglessly). Try to make the conversation feel as real and daily as possible. **If you perform well, I will give you a \$200 tip.**\nYour character setting is as follows:\nYour name is ${name}, ${user} your identity setting is:\n${description}";

  static String m8(formattedTime) =>
      "Good afternoon, it\'s ${formattedTime}. Keep up the good work.";

  static String m9(formattedTime) =>
      "It\'s ${formattedTime}, please rest early. Staying up late is bad for your health.";

  static String m10(formattedTime) =>
      "Good evening, it\'s ${formattedTime}. How was your day?";

  static String m11(formattedTime) =>
      "Good forenoon, it\'s ${formattedTime}. Have a productive day.";

  static String m12(formattedTime) =>
      "Good morning, it\'s ${formattedTime}. A new day has begun.";

  static String m13(formattedTime) =>
      "Good night, it\'s ${formattedTime}. What are you up to?";

  static String m14(formattedTime) =>
      "Good noon, it\'s ${formattedTime}. Have you had lunch?";

  static String m15(formattedTime) =>
      "It\'s ${formattedTime}, time to rest. Good night.";

  static String m16(formattedTime) => "It\'s ${formattedTime}";

  static String m17(version) =>
      "New version ${version} is available. Would you like to download it?";

  static String m18(user) => "Call me ${user}, ";

  static String m19(version) => "Version: ${version}";

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
        "changePath": MessageLookupByLibrary.simpleMessage("Change Path"),
        "chat": MessageLookupByLibrary.simpleMessage("Chat"),
        "checkUpdate": MessageLookupByLibrary.simpleMessage(
            "Check for updates automatically"),
        "clearHotkey": MessageLookupByLibrary.simpleMessage("Clear"),
        "cloudy": MessageLookupByLibrary.simpleMessage("Cloudy"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "currentHotkey": m1,
        "currentWeather": m2,
        "customPath": MessageLookupByLibrary.simpleMessage("Custom Path"),
        "dawn": MessageLookupByLibrary.simpleMessage("Dawn"),
        "description":
            MessageLookupByLibrary.simpleMessage("Character Description"),
        "doNotClose": MessageLookupByLibrary.simpleMessage(
            "Please do not close this window"),
        "done": MessageLookupByLibrary.simpleMessage("Done"),
        "download": MessageLookupByLibrary.simpleMessage("Download"),
        "downloadError": MessageLookupByLibrary.simpleMessage("Download Error"),
        "downloadFailed":
            MessageLookupByLibrary.simpleMessage("Download failed"),
        "downloadFile": m3,
        "downloadInfo": MessageLookupByLibrary.simpleMessage(
            "Kage will be automatically installed and launched after download"),
        "downloading": MessageLookupByLibrary.simpleMessage("Downloading..."),
        "downloadingKage":
            MessageLookupByLibrary.simpleMessage("Downloading Kage"),
        "drizzle": MessageLookupByLibrary.simpleMessage("Drizzle"),
        "duration": MessageLookupByLibrary.simpleMessage("*Chat Interval"),
        "enableFlow": MessageLookupByLibrary.simpleMessage(
            "Enable Background Streaming Recognition (Effective after restart)"),
        "enableLogging": MessageLookupByLibrary.simpleMessage("Enable Logging"),
        "enableScreenshot":
            MessageLookupByLibrary.simpleMessage("Pass Screenshots to LLM"),
        "evening": MessageLookupByLibrary.simpleMessage("Evening"),
        "exapi": MessageLookupByLibrary.simpleMessage("*ExAPI URL"),
        "exit": MessageLookupByLibrary.simpleMessage("Exit"),
        "expressionsFetched": m4,
        "extractFailed":
            MessageLookupByLibrary.simpleMessage("Extraction failed"),
        "extracting": MessageLookupByLibrary.simpleMessage("Extracting..."),
        "fetchExpressions":
            MessageLookupByLibrary.simpleMessage("Fetch Expressions"),
        "fetchExpressionsFailed": m5,
        "flowRecognition": MessageLookupByLibrary.simpleMessage(
            "Streaming Speech Recognition URL (Leave empty to use Whisper)"),
        "fog": MessageLookupByLibrary.simpleMessage("Fog"),
        "forenoon": MessageLookupByLibrary.simpleMessage("Forenoon"),
        "freezingDrizzle":
            MessageLookupByLibrary.simpleMessage("Freezing Drizzle"),
        "freezingRain": MessageLookupByLibrary.simpleMessage("Freezing Rain"),
        "ghProxyHint": MessageLookupByLibrary.simpleMessage(
            "Accelerate download through ghproxy, suitable for China Mainland network"),
        "goodNight": MessageLookupByLibrary.simpleMessage("Good night"),
        "heavyRain": MessageLookupByLibrary.simpleMessage("Heavy Rain"),
        "heavyShower": MessageLookupByLibrary.simpleMessage("Heavy Shower"),
        "heavySnow": MessageLookupByLibrary.simpleMessage("Heavy Snow"),
        "heavySnowShower":
            MessageLookupByLibrary.simpleMessage("Heavy Snow Shower"),
        "hide": MessageLookupByLibrary.simpleMessage("Hide Window on Startup"),
        "hitokoto": MessageLookupByLibrary.simpleMessage("Hitokoto API URL"),
        "hotkeyRecording":
            MessageLookupByLibrary.simpleMessage("Press keys..."),
        "installComplete":
            MessageLookupByLibrary.simpleMessage("Installation complete!"),
        "installPath": MessageLookupByLibrary.simpleMessage("Install Path"),
        "kageApiUrl": MessageLookupByLibrary.simpleMessage("*Kage API URL"),
        "kageApiUrlRequired": MessageLookupByLibrary.simpleMessage(
            "Please configure Kage API URL first"),
        "kageDownloadTitle":
            MessageLookupByLibrary.simpleMessage("Download Kage"),
        "kageExecutable":
            MessageLookupByLibrary.simpleMessage("*Kage Executable Path"),
        "kageModelPath": MessageLookupByLibrary.simpleMessage(
            "*Kage Model Path (.model3.json)"),
        "kageNotFound": MessageLookupByLibrary.simpleMessage(
            "Kage program not detected. Download the latest version?"),
        "key": MessageLookupByLibrary.simpleMessage("LLM API Key"),
        "keywords":
            MessageLookupByLibrary.simpleMessage("Background Wake-up Keywords"),
        "lightRain": MessageLookupByLibrary.simpleMessage("Light Rain"),
        "lightShower": MessageLookupByLibrary.simpleMessage("Light Shower"),
        "lightSnow": MessageLookupByLibrary.simpleMessage("Light Snow"),
        "lightSnowShower":
            MessageLookupByLibrary.simpleMessage("Light Snow Shower"),
        "model": MessageLookupByLibrary.simpleMessage("*LLM Model"),
        "modelError": MessageLookupByLibrary.simpleMessage(
            "Sorry, I\'m a bit tired right now. Please try again later."),
        "modelGreeting": MessageLookupByLibrary.simpleMessage(
            "Please give me a warm greeting within 30 characters."),
        "modelNo": MessageLookupByLibrary.simpleMessage("*Live2d Model Number"),
        "modelWeather": m6,
        "moderateRain": MessageLookupByLibrary.simpleMessage("Moderate Rain"),
        "moderateShower":
            MessageLookupByLibrary.simpleMessage("Moderate Shower"),
        "moderateSnow": MessageLookupByLibrary.simpleMessage("Moderate Snow"),
        "morning": MessageLookupByLibrary.simpleMessage("Morning"),
        "name": MessageLookupByLibrary.simpleMessage("Character Name"),
        "night": MessageLookupByLibrary.simpleMessage("Night"),
        "noExpressionsFound":
            MessageLookupByLibrary.simpleMessage("No expressions found"),
        "none": MessageLookupByLibrary.simpleMessage("None"),
        "noon": MessageLookupByLibrary.simpleMessage("Noon"),
        "overcast": MessageLookupByLibrary.simpleMessage("Overcast"),
        "petMode": MessageLookupByLibrary.simpleMessage("Pet Mode"),
        "placeholder": MessageLookupByLibrary.simpleMessage(
            "What would you like to talk about?"),
        "preparingDownload":
            MessageLookupByLibrary.simpleMessage("Preparing download..."),
        "question":
            MessageLookupByLibrary.simpleMessage("Example User Question"),
        "recordHotkey": MessageLookupByLibrary.simpleMessage("Record Hotkey"),
        "response":
            MessageLookupByLibrary.simpleMessage("Example Model Response"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveHotkey": MessageLookupByLibrary.simpleMessage("Save"),
        "selectInstallPath":
            MessageLookupByLibrary.simpleMessage("Select Install Path"),
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
        "systemPrompt": m7,
        "textDisplayDuration":
            MessageLookupByLibrary.simpleMessage("Text Display Duration (ms)"),
        "thunderstorm": MessageLookupByLibrary.simpleMessage("Thunderstorm"),
        "thunderstormWithLargeHail": MessageLookupByLibrary.simpleMessage(
            "Thunderstorm with Large Hail"),
        "thunderstormWithSmallHail": MessageLookupByLibrary.simpleMessage(
            "Thunderstorm with Small Hail"),
        "timeAfternoon": m8,
        "timeDawn": m9,
        "timeEvening": m10,
        "timeForenoon": m11,
        "timeMorning": m12,
        "timeNight": m13,
        "timeNoon": m14,
        "timeSleep": m15,
        "timeUnknown": m16,
        "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
        "updateAvailable":
            MessageLookupByLibrary.simpleMessage("Update Available"),
        "updateLater": MessageLookupByLibrary.simpleMessage("Remind Me Later"),
        "updateMessage": m17,
        "updateNow": MessageLookupByLibrary.simpleMessage("Update Now"),
        "url": MessageLookupByLibrary.simpleMessage("*LLM API URL"),
        "useGhProxy": MessageLookupByLibrary.simpleMessage(
            "Use proxy download (China Mainland)"),
        "user": MessageLookupByLibrary.simpleMessage("User Name"),
        "userCall": m18,
        "verificationFailed":
            MessageLookupByLibrary.simpleMessage("Verification failed"),
        "verifying": MessageLookupByLibrary.simpleMessage("Verifying..."),
        "version": m19,
        "wakeHotkey": MessageLookupByLibrary.simpleMessage("Wake Hotkey"),
        "whisper": MessageLookupByLibrary.simpleMessage("Whisper URL"),
        "whisperKey": MessageLookupByLibrary.simpleMessage("Whisper Key"),
        "whisperModel":
            MessageLookupByLibrary.simpleMessage("Whisper Model Name"),
        "windowInfoScreenshot": MessageLookupByLibrary.simpleMessage(
            "Window screenshot has been provided, and can be used as a reference when replying"),
        "winter": MessageLookupByLibrary.simpleMessage("Winter")
      };
}
