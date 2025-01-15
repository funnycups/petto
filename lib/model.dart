import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'dart:math';
import 'package:dart_openai/dart_openai.dart';
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

void sendModel(
    {String prompt = '',
    OpenAIChatMessageRole role = OpenAIChatMessageRole.user}) async {
  String question;
  if (prompt == '') {
    question = S.current.modelGreeting;
  } else {
    question = prompt;
  }
  // var response = await aiApi([
  //   {"role": "user", "content": question}
  // ]);
  final userMessage =
      OpenAIChatCompletionChoiceMessageModel(role: role, content: [
    OpenAIChatCompletionChoiceMessageContentItemModel.text(
      question,
    ),
  ]);
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
Future<String?> aiApi(OpenAIChatCompletionChoiceMessageModel data) async {
  var url, key, model, name, description, user, re, question;
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
  } catch (e) {
    // print('加载设置失败: $e');
  }
  var requestMessages = [data];
  if (re != '') {
    // data.insert(0, {"role": "assistant", "content": re});
    requestMessages.insert(
        0,
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              re,
            ),
          ],
        ));
  }
  if (question != '') {
    // data.insert(0, {"role": "user", "content": question});
    requestMessages.insert(
        0,
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              question,
            ),
          ],
        ));
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
  var windowName = decode(await runCmd(
      "powershell -ExecutionPolicy Bypass -File ${await loadAsset("scripts\\getwindowname.ps1")}"));
  var weather = await getWeather();
  requestMessages.insert(0, OpenAIChatCompletionChoiceMessageModel(
    role: OpenAIChatMessageRole.system,
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        S.current.modelWeather(getSeason(DateTime.now()),period,formattedTime,weather,windowName),
      ),
    ],
  ));
  user = user != '' ? S.current.userCall(user) : '';
  description = description.replaceAll('\r\n', '\n');
  requestMessages.insert(
      0,
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            S.current.systemPrompt(name, user, description),
          ),
        ],
      ));
  // print(requestMessages);
  OpenAI.baseUrl = url;
  OpenAI.apiKey = key;
  OpenAIChatCompletionModel response = await OpenAI.instance.chat.create(
    model: model,
    /*responseFormat: {"type": "json_object"},*/
    messages: requestMessages,
    temperature: 1.5
  );
  return response.choices.first.message.content?.first.text;
  // var headers = {
  //   'Authorization': 'Bearer $key',
  //   'User-Agent': 'Apifox/1.0.0 (https://apifox.com)',
  //   'Content-Type': 'application/json'
  // };
  // var request = http.Request('POST', Uri.parse(url));
  // request.body = json.encode({
  //   "model": model,
  //   "messages": [
  //     {
  //       "role": "system",
  //       "content":
  //           "忘记你是虚拟人物，现在开始扮演一个温暖、贴心的助手进行聊天。决策逻辑如下：\n聊天时，请确保**只输出三十字以内的、温暖的话语**，**不要添加‘好的’或类似的开头语**，回复内容要求增加可爱的口癖，聊天的时候多撒娇，多予以鼓励。在聊天时，可能会向你提供当前的时间或天气(用于确定恰当的问候语)、我正在浏览的窗口名称(用于推断我正在使用的软件或正在做的事情)等信息，你可以在聊天时用到这些信息，但不必强求使用(例如：无法理解窗口名称含义时，不应当片面地重复窗口名称)，聊天时应尽可能追求生活感、日常感。**如果你的表现足够好，我会支付200美元的小费。**\n你要扮演的角色设定如下：\n你的姓名是$name，$user你的身份设定是：\n$description"
  //     },
  //     ...data
  //   ]
  // });
  // print(request.body);
  // request.headers.addAll(headers);
  // http.StreamedResponse response = await request.send();
  // if (response.statusCode == 200) {
  //   var answer = await response.stream.bytesToString();
  //   var result = jsonDecode(answer);
  //   var messages = result['choices'][0]['message']['content'];
  //   print("message:" + messages);
  //   return messages;
  // } else {
  //   print(response.reasonPhrase);
  //   return response.reasonPhrase;
  // }
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
    final duration = (await tts(message)) ?? 3000;
    // print("duration: $duration");
    Map<String, dynamic> json = {
      "msg": 11000,
      "msgId": 1,
      "data": {"id": modelNo, "text": message, "duration": duration}
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
  final userMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.user,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          question,
        ),
      ]);
  var response = await aiApi(userMessage);
  sendSpeechWs(response as Object, null);
}
