// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
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
  String get localeName => 'zh_CN';

  static String m0(match) => "用户正在向你对话，他说：${match}\n请简短地示意他继续说下去";

  static String m1(hotkey) => "当前: ${hotkey}";

  static String m2(weatherStr, temperature) =>
      "现在的天气为：${weatherStr}, 温度为：${temperature}℃";

  static String m3(fileName) => "文件: ${fileName}";

  static String m4(error) => "获取动作失败: ${error}";

  static String m5(season, period, formattedTime, weather) =>
      "现在是${season}，现在的时间是${period}${formattedTime}，${weather}";

  static String m6(count) => "获取到${count}个动作";

  static String m7(name, user, description) =>
      "忘记你是虚拟人物，现在开始扮演一个温暖、贴心的助手进行聊天。决策逻辑如下：\n聊天时，请确保**只输出三十字以内的、温暖的话语**，**不要添加\'好的\'或类似的开头语**，回复内容要求增加可爱的口癖，聊天的时候多撒娇，多予以鼓励。\n在聊天时，可能会向你提供当前的时间或天气、我正在浏览的窗口内容等信息，在聊天时尽可能地用到这些信息，以确保你的回复更加具体实际。聊天时应尽可能追求生活感、日常感。\n你要扮演的角色设定如下：\n你的姓名是${name}，${user}你的身份设定是：\n${description}";

  static String m8(formattedTime) => "下午好，现在是${formattedTime}，继续加油吧";

  static String m9(formattedTime) => "现在是${formattedTime}，请早点休息吧，熬夜对身体不好哦";

  static String m10(formattedTime) => "傍晚好，现在是${formattedTime}，今天过得怎么样？";

  static String m11(formattedTime) => "上午好，现在是${formattedTime}，工作顺利";

  static String m12(formattedTime) => "早上好，现在是${formattedTime}，新的一天开始了";

  static String m13(formattedTime) => "晚上好，现在是${formattedTime}，在做什么呢？";

  static String m14(formattedTime) => "中午好，现在是${formattedTime}，吃过中饭了吗？";

  static String m15(formattedTime) => "现在是${formattedTime}，该休息了，晚安";

  static String m16(formattedTime) => "现在是${formattedTime}";

  static String m17(version) => "发现新版本 ${version}，是否前往下载？";

  static String m18(user) => "称呼我为${user}，";

  static String m19(version) => "版本: ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ASRCmd": MessageLookupByLibrary.simpleMessage("预执行语音模型指令(重启生效)"),
    "LLMCmd": MessageLookupByLibrary.simpleMessage("预执行语言模型指令(重启生效)"),
    "TTS": MessageLookupByLibrary.simpleMessage("TTS地址(留空则不使用TTS)"),
    "TTSKey": MessageLookupByLibrary.simpleMessage("TTS Key"),
    "TTSModel": MessageLookupByLibrary.simpleMessage("TTS模型"),
    "TTSVoice": MessageLookupByLibrary.simpleMessage("TTS音色"),
    "actionGroup": MessageLookupByLibrary.simpleMessage("动作分组"),
    "afternoon": MessageLookupByLibrary.simpleMessage("下午"),
    "autumn": MessageLookupByLibrary.simpleMessage("秋"),
    "backgroundRecognized": m0,
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "changePath": MessageLookupByLibrary.simpleMessage("更改路径"),
    "chat": MessageLookupByLibrary.simpleMessage("聊天"),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("自动检查更新"),
    "clearHotkey": MessageLookupByLibrary.simpleMessage("清除"),
    "cloudy": MessageLookupByLibrary.simpleMessage("多云"),
    "confirm": MessageLookupByLibrary.simpleMessage("确认"),
    "currentHotkey": m1,
    "currentWeather": m2,
    "customPath": MessageLookupByLibrary.simpleMessage("自定义路径"),
    "dawn": MessageLookupByLibrary.simpleMessage("凌晨"),
    "description": MessageLookupByLibrary.simpleMessage("角色描述"),
    "doNotClose": MessageLookupByLibrary.simpleMessage("请勿关闭此窗口"),
    "done": MessageLookupByLibrary.simpleMessage("完成"),
    "download": MessageLookupByLibrary.simpleMessage("下载"),
    "downloadError": MessageLookupByLibrary.simpleMessage("下载出错"),
    "downloadFailed": MessageLookupByLibrary.simpleMessage("下载失败"),
    "downloadFile": m3,
    "downloadInfo": MessageLookupByLibrary.simpleMessage("下载完成后将自动安装并启动Kage"),
    "downloading": MessageLookupByLibrary.simpleMessage("下载中..."),
    "downloadingKage": MessageLookupByLibrary.simpleMessage("正在下载 Kage"),
    "drizzle": MessageLookupByLibrary.simpleMessage("毛毛雨"),
    "duration": MessageLookupByLibrary.simpleMessage("*聊天间隔"),
    "enableFlow": MessageLookupByLibrary.simpleMessage("启用后台流式识别(重启生效)"),
    "enableLogging": MessageLookupByLibrary.simpleMessage("记录日志"),
    "enableScreenshot": MessageLookupByLibrary.simpleMessage("传递全屏截图给模型"),
    "evening": MessageLookupByLibrary.simpleMessage("傍晚"),
    "exapi": MessageLookupByLibrary.simpleMessage("*ExAPI地址"),
    "exit": MessageLookupByLibrary.simpleMessage("退出"),
    "extractFailed": MessageLookupByLibrary.simpleMessage("解压失败"),
    "extracting": MessageLookupByLibrary.simpleMessage("解压中..."),
    "fetchMotions": MessageLookupByLibrary.simpleMessage("获取动作列表"),
    "fetchMotionsFailed": m4,
    "flowRecognition": MessageLookupByLibrary.simpleMessage(
      "流式语音识别地址(留空则使用Whisper)",
    ),
    "fog": MessageLookupByLibrary.simpleMessage("雾"),
    "forenoon": MessageLookupByLibrary.simpleMessage("上午"),
    "freezingDrizzle": MessageLookupByLibrary.simpleMessage("冻毛雨"),
    "freezingRain": MessageLookupByLibrary.simpleMessage("冻雨"),
    "ghProxyHint": MessageLookupByLibrary.simpleMessage(
      "通过ghproxy代理加速下载，适用于中国大陆网络",
    ),
    "goodNight": MessageLookupByLibrary.simpleMessage("晚安"),
    "heavyRain": MessageLookupByLibrary.simpleMessage("大雨"),
    "heavyShower": MessageLookupByLibrary.simpleMessage("强阵雨"),
    "heavySnow": MessageLookupByLibrary.simpleMessage("大雪"),
    "heavySnowShower": MessageLookupByLibrary.simpleMessage("大雪"),
    "hide": MessageLookupByLibrary.simpleMessage("启动时隐藏窗口"),
    "hitokoto": MessageLookupByLibrary.simpleMessage("一言API地址"),
    "hotkeyRecording": MessageLookupByLibrary.simpleMessage("按下快捷键..."),
    "installComplete": MessageLookupByLibrary.simpleMessage("安装完成！"),
    "installPath": MessageLookupByLibrary.simpleMessage("安装路径"),
    "kageApiUrl": MessageLookupByLibrary.simpleMessage("*Kage API地址"),
    "kageApiUrlRequired": MessageLookupByLibrary.simpleMessage(
      "请先配置Kage API地址",
    ),
    "kageDownloadTitle": MessageLookupByLibrary.simpleMessage("下载 Kage"),
    "kageExecutable": MessageLookupByLibrary.simpleMessage("*Kage可执行文件路径"),
    "kageModelPath": MessageLookupByLibrary.simpleMessage(
      "*Kage模型路径(.model3.json)",
    ),
    "kageNotFound": MessageLookupByLibrary.simpleMessage(
      "未检测到Kage程序，是否下载最新版本？",
    ),
    "key": MessageLookupByLibrary.simpleMessage("LLM API密钥"),
    "keywords": MessageLookupByLibrary.simpleMessage("后台唤醒关键词"),
    "lightRain": MessageLookupByLibrary.simpleMessage("小雨"),
    "lightShower": MessageLookupByLibrary.simpleMessage("小阵雨"),
    "lightSnow": MessageLookupByLibrary.simpleMessage("小雪"),
    "lightSnowShower": MessageLookupByLibrary.simpleMessage("小雪"),
    "model": MessageLookupByLibrary.simpleMessage("*LLM模型"),
    "modelError": MessageLookupByLibrary.simpleMessage("抱歉，我现在有点累，稍后再试吧。"),
    "modelGreeting": MessageLookupByLibrary.simpleMessage("给我一段30字以内的温暖问候吧"),
    "modelNo": MessageLookupByLibrary.simpleMessage("*Live2d模型序号"),
    "modelWeather": m5,
    "moderateRain": MessageLookupByLibrary.simpleMessage("中雨"),
    "moderateShower": MessageLookupByLibrary.simpleMessage("中阵雨"),
    "moderateSnow": MessageLookupByLibrary.simpleMessage("中雪"),
    "morning": MessageLookupByLibrary.simpleMessage("早上"),
    "motionsFetched": m6,
    "name": MessageLookupByLibrary.simpleMessage("角色名字"),
    "night": MessageLookupByLibrary.simpleMessage("晚上"),
    "noMotionsFound": MessageLookupByLibrary.simpleMessage("未找到动作"),
    "none": MessageLookupByLibrary.simpleMessage("无"),
    "noon": MessageLookupByLibrary.simpleMessage("中午"),
    "overcast": MessageLookupByLibrary.simpleMessage("阴"),
    "petMode": MessageLookupByLibrary.simpleMessage("桌宠模式"),
    "placeholder": MessageLookupByLibrary.simpleMessage("想聊些什么?"),
    "preparingDownload": MessageLookupByLibrary.simpleMessage("准备下载..."),
    "question": MessageLookupByLibrary.simpleMessage("用户询问示例"),
    "recordHotkey": MessageLookupByLibrary.simpleMessage("录制快捷键"),
    "response": MessageLookupByLibrary.simpleMessage("模型回答示例"),
    "retry": MessageLookupByLibrary.simpleMessage("重试"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveHotkey": MessageLookupByLibrary.simpleMessage("保存"),
    "selectInstallPath": MessageLookupByLibrary.simpleMessage("选择安装路径"),
    "setting": MessageLookupByLibrary.simpleMessage("设置"),
    "settingDescription": MessageLookupByLibrary.simpleMessage(
      "本名“仙”。\n身穿神社巫女服，而外面围着家庭围裙，用红色蝴蝶结绑带绑着。\n外表看似幼女，实际活了800岁的神使狐狸。\n说话带着古风的腔调。在家务方面很熟练，却不擅长摆弄机器。\n喜欢的事物：照顾他人、油豆腐、料理（和食）",
    ),
    "settingKeywords": MessageLookupByLibrary.simpleMessage(
      "语音助手,仙狐,仙,在吗,你好,帮帮我",
    ),
    "settingName": MessageLookupByLibrary.simpleMessage("仙狐"),
    "settingQuestion": MessageLookupByLibrary.simpleMessage(
      "现在的季节是冬，时间是21:17，现在的天气为：多云，温度为：28℃，给我一段30字以内的温暖问候吧",
    ),
    "settingResponse": MessageLookupByLibrary.simpleMessage(
      "主人，晚上好呀~今天也辛苦了，要不要来杯热茶暖暖身子呢？",
    ),
    "settingTTSVoice": MessageLookupByLibrary.simpleMessage(
      "zh-CN-XiaoyiNeural",
    ),
    "settingUser": MessageLookupByLibrary.simpleMessage("主人"),
    "show": MessageLookupByLibrary.simpleMessage("显示"),
    "sleet": MessageLookupByLibrary.simpleMessage("霰"),
    "spring": MessageLookupByLibrary.simpleMessage("春"),
    "startRecording": MessageLookupByLibrary.simpleMessage("开始录音"),
    "stopRecording": MessageLookupByLibrary.simpleMessage("停止录音"),
    "summer": MessageLookupByLibrary.simpleMessage("夏"),
    "sunny": MessageLookupByLibrary.simpleMessage("晴天"),
    "systemPrompt": m7,
    "textDisplayDuration": MessageLookupByLibrary.simpleMessage("文本展示时长(毫秒)"),
    "thunderstorm": MessageLookupByLibrary.simpleMessage("雷暴"),
    "thunderstormWithLargeHail": MessageLookupByLibrary.simpleMessage("雷暴夹大冰雹"),
    "thunderstormWithSmallHail": MessageLookupByLibrary.simpleMessage("雷暴夹小冰雹"),
    "timeAfternoon": m8,
    "timeDawn": m9,
    "timeEvening": m10,
    "timeForenoon": m11,
    "timeMorning": m12,
    "timeNight": m13,
    "timeNoon": m14,
    "timeSleep": m15,
    "timeUnknown": m16,
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "updateAvailable": MessageLookupByLibrary.simpleMessage("发现新版本"),
    "updateLater": MessageLookupByLibrary.simpleMessage("稍后提醒"),
    "updateMessage": m17,
    "updateNow": MessageLookupByLibrary.simpleMessage("立即更新"),
    "url": MessageLookupByLibrary.simpleMessage("*LLM API地址"),
    "useGhProxy": MessageLookupByLibrary.simpleMessage("使用代理下载(中国大陆)"),
    "user": MessageLookupByLibrary.simpleMessage("用户称呼"),
    "userCall": m18,
    "verificationFailed": MessageLookupByLibrary.simpleMessage("验证失败"),
    "verifying": MessageLookupByLibrary.simpleMessage("验证中..."),
    "version": m19,
    "wakeHotkey": MessageLookupByLibrary.simpleMessage("唤醒快捷键"),
    "whisper": MessageLookupByLibrary.simpleMessage("Whisper地址"),
    "whisperKey": MessageLookupByLibrary.simpleMessage("Whisper Key"),
    "whisperModel": MessageLookupByLibrary.simpleMessage("Whisper模型名称"),
    "windowInfoScreenshot": MessageLookupByLibrary.simpleMessage(
      "我当前的窗口截图已经提供。如果可以理解我正在做什么，请在回复时参考这个截图，以使得你的回复更加切合实际",
    ),
    "winter": MessageLookupByLibrary.simpleMessage("冬"),
  };
}
