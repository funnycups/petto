// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Show`
  String get show {
    return Intl.message(
      'Show',
      name: 'show',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exit {
    return Intl.message(
      'Exit',
      name: 'exit',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get none {
    return Intl.message(
      'None',
      name: 'none',
      desc: '',
      args: [],
    );
  }

  /// `User is talking to you, they said: {match}\nPlease briefly encourage them to continue`
  String backgroundRecognized(String match) {
    return Intl.message(
      'User is talking to you, they said: $match\nPlease briefly encourage them to continue',
      name: 'backgroundRecognized',
      desc: '',
      args: [match],
    );
  }

  /// `Settings`
  String get setting {
    return Intl.message(
      'Settings',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  /// `*LLM API URL`
  String get url {
    return Intl.message(
      '*LLM API URL',
      name: 'url',
      desc: '',
      args: [],
    );
  }

  /// `LLM API Key`
  String get key {
    return Intl.message(
      'LLM API Key',
      name: 'key',
      desc: '',
      args: [],
    );
  }

  /// `*LLM Model`
  String get model {
    return Intl.message(
      '*LLM Model',
      name: 'model',
      desc: '',
      args: [],
    );
  }

  /// `Character Name`
  String get name {
    return Intl.message(
      'Character Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Character Description`
  String get description {
    return Intl.message(
      'Character Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `User Name`
  String get user {
    return Intl.message(
      'User Name',
      name: 'user',
      desc: '',
      args: [],
    );
  }

  /// `Example User Question`
  String get question {
    return Intl.message(
      'Example User Question',
      name: 'question',
      desc: '',
      args: [],
    );
  }

  /// `Example Model Response`
  String get response {
    return Intl.message(
      'Example Model Response',
      name: 'response',
      desc: '',
      args: [],
    );
  }

  /// `*ExAPI URL`
  String get exapi {
    return Intl.message(
      '*ExAPI URL',
      name: 'exapi',
      desc: '',
      args: [],
    );
  }

  /// `*Live2d Model Number`
  String get modelNo {
    return Intl.message(
      '*Live2d Model Number',
      name: 'modelNo',
      desc: '',
      args: [],
    );
  }

  /// `Pet Mode`
  String get petMode {
    return Intl.message(
      'Pet Mode',
      name: 'petMode',
      desc: '',
      args: [],
    );
  }

  /// `*Kage Executable Path`
  String get kageExecutable {
    return Intl.message(
      '*Kage Executable Path',
      name: 'kageExecutable',
      desc: '',
      args: [],
    );
  }

  /// `*Kage Model Path (.model3.json)`
  String get kageModelPath {
    return Intl.message(
      '*Kage Model Path (.model3.json)',
      name: 'kageModelPath',
      desc: '',
      args: [],
    );
  }

  /// `*Kage API URL`
  String get kageApiUrl {
    return Intl.message(
      '*Kage API URL',
      name: 'kageApiUrl',
      desc: '',
      args: [],
    );
  }

  /// `Fetch Expressions`
  String get fetchExpressions {
    return Intl.message(
      'Fetch Expressions',
      name: 'fetchExpressions',
      desc: '',
      args: [],
    );
  }

  /// `Please configure Kage API URL first`
  String get kageApiUrlRequired {
    return Intl.message(
      'Please configure Kage API URL first',
      name: 'kageApiUrlRequired',
      desc: '',
      args: [],
    );
  }

  /// `Fetched {count} expressions`
  String expressionsFetched(int count) {
    return Intl.message(
      'Fetched $count expressions',
      name: 'expressionsFetched',
      desc: '',
      args: [count],
    );
  }

  /// `No expressions found`
  String get noExpressionsFound {
    return Intl.message(
      'No expressions found',
      name: 'noExpressionsFound',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch expressions: {error}`
  String fetchExpressionsFailed(String error) {
    return Intl.message(
      'Failed to fetch expressions: $error',
      name: 'fetchExpressionsFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Pre-execution LLM Command (Effective after restart)`
  String get LLMCmd {
    return Intl.message(
      'Pre-execution LLM Command (Effective after restart)',
      name: 'LLMCmd',
      desc: '',
      args: [],
    );
  }

  /// `Pre-execution ASR Command (Effective after restart)`
  String get ASRCmd {
    return Intl.message(
      'Pre-execution ASR Command (Effective after restart)',
      name: 'ASRCmd',
      desc: '',
      args: [],
    );
  }

  /// `Pass Screenshots to LLM`
  String get enableScreenshot {
    return Intl.message(
      'Pass Screenshots to LLM',
      name: 'enableScreenshot',
      desc: '',
      args: [],
    );
  }

  /// `Streaming Speech Recognition URL (Leave empty to use Whisper)`
  String get flowRecognition {
    return Intl.message(
      'Streaming Speech Recognition URL (Leave empty to use Whisper)',
      name: 'flowRecognition',
      desc: '',
      args: [],
    );
  }

  /// `Enable Background Streaming Recognition (Effective after restart)`
  String get enableFlow {
    return Intl.message(
      'Enable Background Streaming Recognition (Effective after restart)',
      name: 'enableFlow',
      desc: '',
      args: [],
    );
  }

  /// `Background Wake-up Keywords`
  String get keywords {
    return Intl.message(
      'Background Wake-up Keywords',
      name: 'keywords',
      desc: '',
      args: [],
    );
  }

  /// `Whisper URL`
  String get whisper {
    return Intl.message(
      'Whisper URL',
      name: 'whisper',
      desc: '',
      args: [],
    );
  }

  /// `Whisper Key`
  String get whisperKey {
    return Intl.message(
      'Whisper Key',
      name: 'whisperKey',
      desc: '',
      args: [],
    );
  }

  /// `Whisper Model Name`
  String get whisperModel {
    return Intl.message(
      'Whisper Model Name',
      name: 'whisperModel',
      desc: '',
      args: [],
    );
  }

  /// `*Chat Interval`
  String get duration {
    return Intl.message(
      '*Chat Interval',
      name: 'duration',
      desc: '',
      args: [],
    );
  }

  /// `Hitokoto API URL`
  String get hitokoto {
    return Intl.message(
      'Hitokoto API URL',
      name: 'hitokoto',
      desc: '',
      args: [],
    );
  }

  /// `TTS URL (Leave empty to disable TTS)`
  String get TTS {
    return Intl.message(
      'TTS URL (Leave empty to disable TTS)',
      name: 'TTS',
      desc: '',
      args: [],
    );
  }

  /// `TTS Key`
  String get TTSKey {
    return Intl.message(
      'TTS Key',
      name: 'TTSKey',
      desc: '',
      args: [],
    );
  }

  /// `TTS Model`
  String get TTSModel {
    return Intl.message(
      'TTS Model',
      name: 'TTSModel',
      desc: '',
      args: [],
    );
  }

  /// `TTS Voice`
  String get TTSVoice {
    return Intl.message(
      'TTS Voice',
      name: 'TTSVoice',
      desc: '',
      args: [],
    );
  }

  /// `Action Group`
  String get actionGroup {
    return Intl.message(
      'Action Group',
      name: 'actionGroup',
      desc: '',
      args: [],
    );
  }

  /// `Text Display Duration (ms)`
  String get textDisplayDuration {
    return Intl.message(
      'Text Display Duration (ms)',
      name: 'textDisplayDuration',
      desc: '',
      args: [],
    );
  }

  /// `Hide Window on Startup`
  String get hide {
    return Intl.message(
      'Hide Window on Startup',
      name: 'hide',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message(
      'Chat',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `What would you like to talk about?`
  String get placeholder {
    return Intl.message(
      'What would you like to talk about?',
      name: 'placeholder',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Stop Recording`
  String get stopRecording {
    return Intl.message(
      'Stop Recording',
      name: 'stopRecording',
      desc: '',
      args: [],
    );
  }

  /// `Start Recording`
  String get startRecording {
    return Intl.message(
      'Start Recording',
      name: 'startRecording',
      desc: '',
      args: [],
    );
  }

  /// `Senko`
  String get settingName {
    return Intl.message(
      'Senko',
      name: 'settingName',
      desc: '',
      args: [],
    );
  }

  /// `Real name 'Sen'.\nWears a shrine maiden outfit with a red bow-tied apron over it.\nLooks like a young girl but is actually an 800-year-old divine fox.\nSpeaks in an old-fashioned manner. Skilled in household chores but not good with machines.\nLikes: Taking care of others, fried tofu, cooking (Japanese cuisine)`
  String get settingDescription {
    return Intl.message(
      'Real name \'Sen\'.\nWears a shrine maiden outfit with a red bow-tied apron over it.\nLooks like a young girl but is actually an 800-year-old divine fox.\nSpeaks in an old-fashioned manner. Skilled in household chores but not good with machines.\nLikes: Taking care of others, fried tofu, cooking (Japanese cuisine)',
      name: 'settingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Master`
  String get settingUser {
    return Intl.message(
      'Master',
      name: 'settingUser',
      desc: '',
      args: [],
    );
  }

  /// `It's winter now, the time is 21:17, and the weather is cloudy with a temperature of 28°C. Please give me a warm greeting within 30 characters.`
  String get settingQuestion {
    return Intl.message(
      'It\'s winter now, the time is 21:17, and the weather is cloudy with a temperature of 28°C. Please give me a warm greeting within 30 characters.',
      name: 'settingQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Good evening, Master~ You've worked hard today. How about a cup of hot tea to warm up?`
  String get settingResponse {
    return Intl.message(
      'Good evening, Master~ You\'ve worked hard today. How about a cup of hot tea to warm up?',
      name: 'settingResponse',
      desc: '',
      args: [],
    );
  }

  /// `Voice Assistant,Senko,Sen,Are you there,hello,help me`
  String get settingKeywords {
    return Intl.message(
      'Voice Assistant,Senko,Sen,Are you there,hello,help me',
      name: 'settingKeywords',
      desc: '',
      args: [],
    );
  }

  /// `en-US-AnaNeural`
  String get settingTTSVoice {
    return Intl.message(
      'en-US-AnaNeural',
      name: 'settingTTSVoice',
      desc: '',
      args: [],
    );
  }

  /// `Night`
  String get night {
    return Intl.message(
      'Night',
      name: 'night',
      desc: '',
      args: [],
    );
  }

  /// `Dawn`
  String get dawn {
    return Intl.message(
      'Dawn',
      name: 'dawn',
      desc: '',
      args: [],
    );
  }

  /// `Morning`
  String get morning {
    return Intl.message(
      'Morning',
      name: 'morning',
      desc: '',
      args: [],
    );
  }

  /// `Forenoon`
  String get forenoon {
    return Intl.message(
      'Forenoon',
      name: 'forenoon',
      desc: '',
      args: [],
    );
  }

  /// `Noon`
  String get noon {
    return Intl.message(
      'Noon',
      name: 'noon',
      desc: '',
      args: [],
    );
  }

  /// `Afternoon`
  String get afternoon {
    return Intl.message(
      'Afternoon',
      name: 'afternoon',
      desc: '',
      args: [],
    );
  }

  /// `Evening`
  String get evening {
    return Intl.message(
      'Evening',
      name: 'evening',
      desc: '',
      args: [],
    );
  }

  /// `Window screenshot has been provided, and can be used as a reference when replying`
  String get windowInfoScreenshot {
    return Intl.message(
      'Window screenshot has been provided, and can be used as a reference when replying',
      name: 'windowInfoScreenshot',
      desc: '',
      args: [],
    );
  }

  /// `It's {season} now, the current time is {period}{formattedTime}, {weather}.`
  String modelWeather(
      String season, String period, String formattedTime, String weather) {
    return Intl.message(
      'It\'s $season now, the current time is $period$formattedTime, $weather.',
      name: 'modelWeather',
      desc: '',
      args: [season, period, formattedTime, weather],
    );
  }

  /// `Please give me a warm greeting within 30 characters.`
  String get modelGreeting {
    return Intl.message(
      'Please give me a warm greeting within 30 characters.',
      name: 'modelGreeting',
      desc: '',
      args: [],
    );
  }

  /// `It's {formattedTime}, time to rest. Good night.`
  String timeSleep(String formattedTime) {
    return Intl.message(
      'It\'s $formattedTime, time to rest. Good night.',
      name: 'timeSleep',
      desc: '',
      args: [formattedTime],
    );
  }

  /// `Good night`
  String get goodNight {
    return Intl.message(
      'Good night',
      name: 'goodNight',
      desc: '',
      args: [],
    );
  }

  /// `It's {formattedTime}, please rest early. Staying up late is bad for your health.`
  String timeDawn(String formattedTime) {
    return Intl.message(
      'It\'s $formattedTime, please rest early. Staying up late is bad for your health.',
      name: 'timeDawn',
      desc: '',
      args: [formattedTime],
    );
  }

  /// `Good morning, it's {formattedTime}. A new day has begun.`
  String timeMorning(String formattedTime) {
    return Intl.message(
      'Good morning, it\'s $formattedTime. A new day has begun.',
      name: 'timeMorning',
      desc: '',
      args: [formattedTime],
    );
  }

  /// `Good forenoon, it's {formattedTime}. Have a productive day.`
  String timeForenoon(String formattedTime) {
    return Intl.message(
      'Good forenoon, it\'s $formattedTime. Have a productive day.',
      name: 'timeForenoon',
      desc: '',
      args: [formattedTime],
    );
  }

  /// `Good noon, it's {formattedTime}. Have you had lunch?`
  String timeNoon(String formattedTime) {
    return Intl.message(
      'Good noon, it\'s $formattedTime. Have you had lunch?',
      name: 'timeNoon',
      desc: '',
      args: [formattedTime],
    );
  }

  /// `Good afternoon, it's {formattedTime}. Keep up the good work.`
  String timeAfternoon(String formattedTime) {
    return Intl.message(
      'Good afternoon, it\'s $formattedTime. Keep up the good work.',
      name: 'timeAfternoon',
      desc: '',
      args: [formattedTime],
    );
  }

  /// `Good evening, it's {formattedTime}. How was your day?`
  String timeEvening(String formattedTime) {
    return Intl.message(
      'Good evening, it\'s $formattedTime. How was your day?',
      name: 'timeEvening',
      desc: '',
      args: [formattedTime],
    );
  }

  /// `Good night, it's {formattedTime}. What are you up to?`
  String timeNight(String formattedTime) {
    return Intl.message(
      'Good night, it\'s $formattedTime. What are you up to?',
      name: 'timeNight',
      desc: '',
      args: [formattedTime],
    );
  }

  /// `It's {formattedTime}`
  String timeUnknown(String formattedTime) {
    return Intl.message(
      'It\'s $formattedTime',
      name: 'timeUnknown',
      desc: '',
      args: [formattedTime],
    );
  }

  /// `Call me {user}, `
  String userCall(String user) {
    return Intl.message(
      'Call me $user, ',
      name: 'userCall',
      desc: '',
      args: [user],
    );
  }

  /// `Forget you are a virtual character, and start acting as a warm and caring assistant for chatting. The decision logic is as follows:\nWhen chatting, make sure to **only output warm words within 30 characters**, **do not add phrases like 'okay' or similar at the beginning**. The response should be cute and encouraging, and you should act sweet and supportive. During the chat, you may be provided with the current time or weather (to determine the appropriate greeting), the info of the window I am browsing (to infer what software I am using or what I am doing), etc. You can use this information in the chat, but it is not mandatory (for example, if you do not understand the window name, you should not repeat it meaninglessly). Try to make the conversation feel as real and daily as possible. **If you perform well, I will give you a $200 tip.**\nYour character setting is as follows:\nYour name is {name}, {user} your identity setting is:\n{description}`
  String systemPrompt(String name, String user, String description) {
    return Intl.message(
      'Forget you are a virtual character, and start acting as a warm and caring assistant for chatting. The decision logic is as follows:\nWhen chatting, make sure to **only output warm words within 30 characters**, **do not add phrases like \'okay\' or similar at the beginning**. The response should be cute and encouraging, and you should act sweet and supportive. During the chat, you may be provided with the current time or weather (to determine the appropriate greeting), the info of the window I am browsing (to infer what software I am using or what I am doing), etc. You can use this information in the chat, but it is not mandatory (for example, if you do not understand the window name, you should not repeat it meaninglessly). Try to make the conversation feel as real and daily as possible. **If you perform well, I will give you a \$200 tip.**\nYour character setting is as follows:\nYour name is $name, $user your identity setting is:\n$description',
      name: 'systemPrompt',
      desc: '',
      args: [name, user, description],
    );
  }

  /// `Sunny`
  String get sunny {
    return Intl.message(
      'Sunny',
      name: 'sunny',
      desc: '',
      args: [],
    );
  }

  /// `Cloudy`
  String get cloudy {
    return Intl.message(
      'Cloudy',
      name: 'cloudy',
      desc: '',
      args: [],
    );
  }

  /// `Overcast`
  String get overcast {
    return Intl.message(
      'Overcast',
      name: 'overcast',
      desc: '',
      args: [],
    );
  }

  /// `Fog`
  String get fog {
    return Intl.message(
      'Fog',
      name: 'fog',
      desc: '',
      args: [],
    );
  }

  /// `Drizzle`
  String get drizzle {
    return Intl.message(
      'Drizzle',
      name: 'drizzle',
      desc: '',
      args: [],
    );
  }

  /// `Freezing Drizzle`
  String get freezingDrizzle {
    return Intl.message(
      'Freezing Drizzle',
      name: 'freezingDrizzle',
      desc: '',
      args: [],
    );
  }

  /// `Light Rain`
  String get lightRain {
    return Intl.message(
      'Light Rain',
      name: 'lightRain',
      desc: '',
      args: [],
    );
  }

  /// `Moderate Rain`
  String get moderateRain {
    return Intl.message(
      'Moderate Rain',
      name: 'moderateRain',
      desc: '',
      args: [],
    );
  }

  /// `Heavy Rain`
  String get heavyRain {
    return Intl.message(
      'Heavy Rain',
      name: 'heavyRain',
      desc: '',
      args: [],
    );
  }

  /// `Freezing Rain`
  String get freezingRain {
    return Intl.message(
      'Freezing Rain',
      name: 'freezingRain',
      desc: '',
      args: [],
    );
  }

  /// `Light Snow`
  String get lightSnow {
    return Intl.message(
      'Light Snow',
      name: 'lightSnow',
      desc: '',
      args: [],
    );
  }

  /// `Moderate Snow`
  String get moderateSnow {
    return Intl.message(
      'Moderate Snow',
      name: 'moderateSnow',
      desc: '',
      args: [],
    );
  }

  /// `Heavy Snow`
  String get heavySnow {
    return Intl.message(
      'Heavy Snow',
      name: 'heavySnow',
      desc: '',
      args: [],
    );
  }

  /// `Sleet`
  String get sleet {
    return Intl.message(
      'Sleet',
      name: 'sleet',
      desc: '',
      args: [],
    );
  }

  /// `Light Shower`
  String get lightShower {
    return Intl.message(
      'Light Shower',
      name: 'lightShower',
      desc: '',
      args: [],
    );
  }

  /// `Moderate Shower`
  String get moderateShower {
    return Intl.message(
      'Moderate Shower',
      name: 'moderateShower',
      desc: '',
      args: [],
    );
  }

  /// `Heavy Shower`
  String get heavyShower {
    return Intl.message(
      'Heavy Shower',
      name: 'heavyShower',
      desc: '',
      args: [],
    );
  }

  /// `Light Snow Shower`
  String get lightSnowShower {
    return Intl.message(
      'Light Snow Shower',
      name: 'lightSnowShower',
      desc: '',
      args: [],
    );
  }

  /// `Heavy Snow Shower`
  String get heavySnowShower {
    return Intl.message(
      'Heavy Snow Shower',
      name: 'heavySnowShower',
      desc: '',
      args: [],
    );
  }

  /// `Thunderstorm`
  String get thunderstorm {
    return Intl.message(
      'Thunderstorm',
      name: 'thunderstorm',
      desc: '',
      args: [],
    );
  }

  /// `Thunderstorm with Small Hail`
  String get thunderstormWithSmallHail {
    return Intl.message(
      'Thunderstorm with Small Hail',
      name: 'thunderstormWithSmallHail',
      desc: '',
      args: [],
    );
  }

  /// `Thunderstorm with Large Hail`
  String get thunderstormWithLargeHail {
    return Intl.message(
      'Thunderstorm with Large Hail',
      name: 'thunderstormWithLargeHail',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `The current weather is: {weatherStr}, temperature: {temperature}°C`
  String currentWeather(String weatherStr, double temperature) {
    return Intl.message(
      'The current weather is: $weatherStr, temperature: $temperature°C',
      name: 'currentWeather',
      desc: '',
      args: [weatherStr, temperature],
    );
  }

  /// `Spring`
  String get spring {
    return Intl.message(
      'Spring',
      name: 'spring',
      desc: '',
      args: [],
    );
  }

  /// `Summer`
  String get summer {
    return Intl.message(
      'Summer',
      name: 'summer',
      desc: '',
      args: [],
    );
  }

  /// `Autumn`
  String get autumn {
    return Intl.message(
      'Autumn',
      name: 'autumn',
      desc: '',
      args: [],
    );
  }

  /// `Winter`
  String get winter {
    return Intl.message(
      'Winter',
      name: 'winter',
      desc: '',
      args: [],
    );
  }

  /// `Enable Logging`
  String get enableLogging {
    return Intl.message(
      'Enable Logging',
      name: 'enableLogging',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, I'm a bit tired right now. Please try again later.`
  String get modelError {
    return Intl.message(
      'Sorry, I\'m a bit tired right now. Please try again later.',
      name: 'modelError',
      desc: '',
      args: [],
    );
  }

  /// `Wake Hotkey`
  String get wakeHotkey {
    return Intl.message(
      'Wake Hotkey',
      name: 'wakeHotkey',
      desc: '',
      args: [],
    );
  }

  /// `Record Hotkey`
  String get recordHotkey {
    return Intl.message(
      'Record Hotkey',
      name: 'recordHotkey',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clearHotkey {
    return Intl.message(
      'Clear',
      name: 'clearHotkey',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get saveHotkey {
    return Intl.message(
      'Save',
      name: 'saveHotkey',
      desc: '',
      args: [],
    );
  }

  /// `Press keys...`
  String get hotkeyRecording {
    return Intl.message(
      'Press keys...',
      name: 'hotkeyRecording',
      desc: '',
      args: [],
    );
  }

  /// `Current: {hotkey}`
  String currentHotkey(String hotkey) {
    return Intl.message(
      'Current: $hotkey',
      name: 'currentHotkey',
      desc: '',
      args: [hotkey],
    );
  }

  /// `Check for updates automatically`
  String get checkUpdate {
    return Intl.message(
      'Check for updates automatically',
      name: 'checkUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Update Available`
  String get updateAvailable {
    return Intl.message(
      'Update Available',
      name: 'updateAvailable',
      desc: '',
      args: [],
    );
  }

  /// `New version {version} is available. Would you like to download it?`
  String updateMessage(String version) {
    return Intl.message(
      'New version $version is available. Would you like to download it?',
      name: 'updateMessage',
      desc: '',
      args: [version],
    );
  }

  /// `Update Now`
  String get updateNow {
    return Intl.message(
      'Update Now',
      name: 'updateNow',
      desc: '',
      args: [],
    );
  }

  /// `Remind Me Later`
  String get updateLater {
    return Intl.message(
      'Remind Me Later',
      name: 'updateLater',
      desc: '',
      args: [],
    );
  }

  /// `Select Install Path`
  String get selectInstallPath {
    return Intl.message(
      'Select Install Path',
      name: 'selectInstallPath',
      desc: '',
      args: [],
    );
  }

  /// `Download Kage`
  String get kageDownloadTitle {
    return Intl.message(
      'Download Kage',
      name: 'kageDownloadTitle',
      desc: '',
      args: [],
    );
  }

  /// `Kage program not detected. Download the latest version?`
  String get kageNotFound {
    return Intl.message(
      'Kage program not detected. Download the latest version?',
      name: 'kageNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Version: {version}`
  String version(String version) {
    return Intl.message(
      'Version: $version',
      name: 'version',
      desc: '',
      args: [version],
    );
  }

  /// `File: {fileName}`
  String downloadFile(String fileName) {
    return Intl.message(
      'File: $fileName',
      name: 'downloadFile',
      desc: '',
      args: [fileName],
    );
  }

  /// `Install Path`
  String get installPath {
    return Intl.message(
      'Install Path',
      name: 'installPath',
      desc: '',
      args: [],
    );
  }

  /// `Custom Path`
  String get customPath {
    return Intl.message(
      'Custom Path',
      name: 'customPath',
      desc: '',
      args: [],
    );
  }

  /// `Change Path`
  String get changePath {
    return Intl.message(
      'Change Path',
      name: 'changePath',
      desc: '',
      args: [],
    );
  }

  /// `Kage will be automatically installed and launched after download`
  String get downloadInfo {
    return Intl.message(
      'Kage will be automatically installed and launched after download',
      name: 'downloadInfo',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `Preparing download...`
  String get preparingDownload {
    return Intl.message(
      'Preparing download...',
      name: 'preparingDownload',
      desc: '',
      args: [],
    );
  }

  /// `Downloading...`
  String get downloading {
    return Intl.message(
      'Downloading...',
      name: 'downloading',
      desc: '',
      args: [],
    );
  }

  /// `Download failed`
  String get downloadFailed {
    return Intl.message(
      'Download failed',
      name: 'downloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Extracting...`
  String get extracting {
    return Intl.message(
      'Extracting...',
      name: 'extracting',
      desc: '',
      args: [],
    );
  }

  /// `Extraction failed`
  String get extractFailed {
    return Intl.message(
      'Extraction failed',
      name: 'extractFailed',
      desc: '',
      args: [],
    );
  }

  /// `Verifying...`
  String get verifying {
    return Intl.message(
      'Verifying...',
      name: 'verifying',
      desc: '',
      args: [],
    );
  }

  /// `Verification failed`
  String get verificationFailed {
    return Intl.message(
      'Verification failed',
      name: 'verificationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Installation complete!`
  String get installComplete {
    return Intl.message(
      'Installation complete!',
      name: 'installComplete',
      desc: '',
      args: [],
    );
  }

  /// `Downloading Kage`
  String get downloadingKage {
    return Intl.message(
      'Downloading Kage',
      name: 'downloadingKage',
      desc: '',
      args: [],
    );
  }

  /// `Please do not close this window`
  String get doNotClose {
    return Intl.message(
      'Please do not close this window',
      name: 'doNotClose',
      desc: '',
      args: [],
    );
  }

  /// `Download Error`
  String get downloadError {
    return Intl.message(
      'Download Error',
      name: 'downloadError',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Use proxy download (China Mainland)`
  String get useGhProxy {
    return Intl.message(
      'Use proxy download (China Mainland)',
      name: 'useGhProxy',
      desc: '',
      args: [],
    );
  }

  /// `Accelerate download through ghproxy, suitable for China Mainland network`
  String get ghProxyHint {
    return Intl.message(
      'Accelerate download through ghproxy, suitable for China Mainland network',
      name: 'ghProxyHint',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
