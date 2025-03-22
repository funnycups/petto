import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'dart:math';
import 'package:openai_dart/openai_dart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'helper.dart';
import 'weather.dart';
import 'settings.dart';

var _lock = Lock();

void sendHitokoto(String hitokoto) async {
  final url = hitokoto;
  if (url.isEmpty) {
    return;
  }
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    sendSpeechWs(response.body, null);
  } else {
    // print('Request failed with status: ${response.statusCode}.');
  }
}

void sendModel({String prompt = ''}) async {
  String question;
  if (prompt == '') {
    question = S.current.modelGreeting;
  } else {
    question = prompt;
  }
  // final userMessage =
  //     OpenAIChatCompletionChoiceMessageModel(role: role, content: [
  //   OpenAIChatCompletionChoiceMessageContentItemModel.text(
  //     question,
  //   ),
  // ]);
  final userMessage = [
    ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.string(question))
  ];
  var response = await aiApi(userMessage);
  sendSpeechWs(response as Object, null);
}

void sendTime() async {
  DateTime now = DateTime.now();
  var hour = now.hour;
  var minute = now.minute;
  String formattedTime =
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  var choices;
  String question;
  if (hour >= 23 || hour < 1) {
    question = S.current.timeSleep(formattedTime);
    choices = [S.current.goodNight];
  } else if (hour >= 1 && hour < 6) {
    question = S.current.timeDawn(formattedTime);
  } else if (hour >= 6 && hour < 8) {
    question = S.current.timeMorning(formattedTime);
  } else if (hour >= 8 && hour < 11) {
    question = S.current.timeForenoon(formattedTime);
  } else if (hour >= 11 && hour < 13) {
    question = S.current.timeNoon(formattedTime);
  } else if (hour >= 13 && hour < 18) {
    question = S.current.timeAfternoon(formattedTime);
  } else if (hour >= 18 && hour < 19) {
    question = S.current.timeEvening(formattedTime);
  } else if (hour >= 19 && hour < 23) {
    question = S.current.timeNight(formattedTime);
  } else {
    question = S.current.timeUnknown(formattedTime);
  }
  sendSpeechWs(question, choices);
}

// Future<String?> aiApi(List<Map<String, dynamic>> data) async {
Future<String?> aiApi(List<ChatCompletionMessage> requestMessages) async {
  var url, key, model, name, description, user, re, question, infoGetter, cmd;
  try {
    final settings = await readSettings();
    url = settings['url'] ?? '';
    key = settings['key'] ?? '';
    model = settings['model'] ?? '';
    name = settings['name'] ?? '';
    description = settings['description'] ?? '';
    user = settings['user'] ?? '';
    re = settings['response'] ?? '';
    question = settings['question'] ?? '';
    infoGetter = settings['window_info_getter'] ?? '';
    cmd = settings['screen_info_cmd'] ?? '';
  } catch (e) {
    // print('加载设置失败: $e');
  }
  // var requestMessages = data;
  if (re != '') {
    // requestMessages.insert(
    //     0,
    //     OpenAIChatCompletionChoiceMessageModel(
    //       role: OpenAIChatMessageRole.assistant,
    //       content: [
    //         OpenAIChatCompletionChoiceMessageContentItemModel.text(
    //           re,
    //         ),
    //       ],
    //     ));
    requestMessages.insert(0, ChatCompletionMessage.assistant(content: re));
  }
  if (question != '') {
    // requestMessages.insert(
    //     0,
    //     OpenAIChatCompletionChoiceMessageModel(
    //       role: OpenAIChatMessageRole.user,
    //       content: [
    //         OpenAIChatCompletionChoiceMessageContentItemModel.text(
    //           question,
    //         ),
    //       ],
    //     ));
    requestMessages.insert(
        0,
        ChatCompletionMessage.user(
            content: ChatCompletionUserMessageContent.string(question)));
  }
  DateTime now = DateTime.now();
  var hour = now.hour;
  var minute = now.minute;
  String formattedTime =
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  String period;
  if (hour >= 20 || hour < 1) {
    period = S.current.night;
  } else if (hour >= 1 && hour < 6) {
    period = S.current.dawn;
  } else if (hour >= 6 && hour < 10) {
    period = S.current.morning;
  } else if (hour >= 10 && hour < 12) {
    period = S.current.forenoon;
  } else if (hour >= 12 && hour < 14) {
    period = S.current.noon;
  } else if (hour >= 14 && hour < 18) {
    period = S.current.afternoon;
  } else {
    period = S.current.evening;
  }
  // var windowName = decode(await runCmd(
  //     "powershell -ExecutionPolicy Bypass -File ${await loadAsset("scripts\\getwindowname.ps1")}"));
  String windowInfo = await getWindow(infoGetter, cmd) ?? '';
  String window = '';
  if (infoGetter == S.current.screenshot) {
    window = S.current.windowInfoScreenshot;
    final bytes = await File(windowInfo).readAsBytes();
    String base64 = base64Encode(bytes);
    // requestMessages.insert(
    //     0,
    //     OpenAIChatCompletionChoiceMessageModel(
    //         role: OpenAIChatMessageRole.system,
    //         content: [
    //           OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
    //               base64)
    //         ]));
    requestMessages.insert(
        0,
        ChatCompletionMessage.user(
            content: ChatCompletionMessageContentParts([
          ChatCompletionMessageContentPart.text(
            text: window,
          ),
          ChatCompletionMessageContentPart.image(
              imageUrl: ChatCompletionMessageImageUrl(url: base64))
        ])));
  } else if (infoGetter == S.current.shell) {
    window = S.current.windowInfoName(windowInfo);
  }
  var weather = await getWeather();
  // requestMessages.insert(
  //     0,
  //     OpenAIChatCompletionChoiceMessageModel(
  //       role: OpenAIChatMessageRole.system,
  //       content: [
  //         OpenAIChatCompletionChoiceMessageContentItemModel.text(
  //           S.current.modelWeather(getSeason(DateTime.now()), period,
  //               formattedTime, weather, window),
  //         ),
  //       ],
  //     ));
  requestMessages.insert(
      0,
      ChatCompletionMessage.system(
          content: S.current.modelWeather(getSeason(DateTime.now()), period,
              formattedTime, weather, window)));
  user = user != '' ? S.current.userCall(user) : '';
  description = description.replaceAll('\r\n', '\n');
  // requestMessages.insert(
  //     0,
  //     OpenAIChatCompletionChoiceMessageModel(
  //       role: OpenAIChatMessageRole.system,
  //       content: [
  //         OpenAIChatCompletionChoiceMessageContentItemModel.text(
  //           S.current.systemPrompt(name, user, description),
  //         ),
  //       ],
  //     ));
  requestMessages.insert(
      0,
      ChatCompletionMessage.system(
          content: S.current.systemPrompt(name, user, description)));
  // OpenAI.baseUrl = url;
  // OpenAI.apiKey = key;
  final client = OpenAIClient(
    apiKey: key,
    baseUrl: url,
  );
  final response = await client.createChatCompletion(
      request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(model),
          /*responseFormat: {"type": "json_object"},*/
          messages: requestMessages,
          temperature: 1.5));
  if (infoGetter == S.current.screenshot) {
    File windowScreenshot = File(windowInfo);
    await windowScreenshot.delete();
  }
  return response.choices.first.message.content;
}

Future<void> sendActionWs() async {
  var settings = await readSettings();
  String modelNo = settings['model_no'] ?? '';
  String group = settings['group'] ?? '';
  String url = settings['exapi'] ?? '';
  final channel = WebSocketChannel.connect(Uri.parse(url));
  var g = group.split(",");
  Random r = Random();
  group = g[r.nextInt(g.length)];
  Map<String, dynamic> json = {
    "msg": 13200,
    "msgId": 1,
    "data": {"id": modelNo, "type": 0, "mtn": group}
  };
  final message = jsonEncode(json);
  channel.sink.add(message);
  await Future.delayed(const Duration(seconds: 5));
  channel.sink.close();
}

Future<void> sendSpeechWs(Object message, List<String>? choices) async {
  var settings = await readSettings();
  String modelNo = settings['model_no'] ?? '';
  String url = settings['exapi'] ?? '';
  final channel = WebSocketChannel.connect(Uri.parse(url));
  await _lock.synchronized(() async {
    String messageText = message.toString().trim();
    final duration = (await tts(messageText)) ?? 3000;
    // print("duration: $duration");
    Map<String, dynamic> json = {
      "msg": 11000,
      "msgId": 1,
      "data": {"id": modelNo, "text": messageText, "duration": duration}
    };
    if (choices != null) {
      json['data']['choices'] = choices;
    }
    final messages = jsonEncode(json);
    channel.sink.add(messages);
    channel.stream.listen((messages) {
      // print('Received message: $message');
      switch (jsonDecode(messages)['data']) {
        case -1:
          // print('未选择');
          break;
        case 0:
          sendSpeechWs(S.current.goodNight, null);
          break;
        default:
        // print('未知结果');
      }
    }, onError: (error) {
      // print('Error: $error');
    }, onDone: () {
      // print('WebSocket connection closed.');
    });
    await Future.delayed(Duration(milliseconds: duration));
    await channel.sink.close();
  });
}

Future<void> sendRequest(String question) async {
  await hideWindow();
  // final userMessage = OpenAIChatCompletionChoiceMessageModel(
  //     role: OpenAIChatMessageRole.user,
  //     content: [
  //       OpenAIChatCompletionChoiceMessageContentItemModel.text(
  //         question,
  //       ),
  //     ]);
  final userMessage = [
    ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.string(question))
  ];
  var response = await aiApi(userMessage);
  sendSpeechWs(response as Object, null);
}
