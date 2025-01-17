# Petto

**Read this in other languages: [English](README.md), [简体中文](README_zh.md)**

Petto is an intelligent desktop assistant based on Live2DViewerEX. It supports streaming speech recognition, natural language, and voice conversations.

Use it to decorate your desktop pet!

## Features

At regular intervals, the desktop pet will:
* Output famous quotes
* Output greetings based on current weather, season, and the window you are visiting using a large language model
* Output simple greetings based on the current time

Additionally, Petto supports streaming speech recognition, TTS speech-to-text, background wake-up, and more, allowing you to interact with your desktop pet via voice!

![Chat Feature](chat.png)

## Supported Languages

* English
* Simplified Chinese

## Getting Started

* Download the Petto release package
* Extract it to any location on your computer
* Ensure your Live2DViewerEX is running, then open the extracted `petto.exe`
* Done! Try talking to your desktop pet!

## Advanced Usage

### Settings

You can configure Petto's features in detail in the settings in the top right corner of the main interface.

Below are explanations for some settings:

#### Language Model (LLM) Settings

> Petto supports language model APIs compatible with OpenAI usage.

Petto is pre-configured with a public language model: [https://api.cups.moe/api/chat](https://api.cups.moe/api/chat), which is deployed based on the [Duck2api](https://github.com/aurora-develop/Duck2api) project.

However, due to restrictions from Duckduckgo, the model may temporarily be unresponsive if there are too many requests in a short period. Consider using your own API or deploying the language model locally.

#### Character Settings

> You can set the character's name, settings, title, and other information.

Write character settings that match your expectations based on the desktop pet character you are using!

#### Message Examples

> The LLM's responses will be influenced by the message examples.

This setting is used to provide references to the model. If you find the LLM's responses do not meet your expectations, you can try writing a simple message example to pass to the LLM.

#### ExAPI Address

> Keep the default value unless there are special circumstances.

Required field, used for communication with Live2DViewerEX.

#### Live2D Model Number

Required field, used to specify the Live2D model number Petto uses. The value is (the model number displayed in Live2DViewerEX - 1). For example, in the case shown below, the selected model's number is 0.

![Live2D Model Number](modelNoExample.png)

#### Pre-execution Model Command

This command can be used to start the language model and speech recognition model locally.

Petto provides reference scripts `startmodel.ps1` and `startserver.ps1` to start the RWKV model and MASR-based speech recognition model locally. More detailed information will be provided later.

Petto allows these two scripts to output a PID for managing the process. When Petto exits, it will automatically kill the process to avoid resource occupation.

#### Streaming Speech Recognition

> If the recognition address is left blank, the Whisper recognition mode will be used.

> The background recognition service will always keep recording and send the speech content back to the set recognition address. Please be aware of potential privacy and security issues.

Currently, streaming recognition must use an interface compatible with the [MASR](https://github.com/yeyupiaoling/MASR) server-side recognition project.

The project is pre-configured with a public streaming recognition: `wss://api.cups.moe/api/asr/`

The server performance is average, so please use it gently :) If used too heavily, my server might crash.

It is best to refer to the tutorial later in the document to deploy the MASR service yourself or use the Whisper mode.

After enabling background streaming recognition, Petto will always run the streaming recognition function in the background. When any speech containing the background wake-up keyword is detected, the desktop pet will send you a message and prompt you to talk to it:
> User: Help me
>
> Desktop Pet: Master, what do you need help with? Please tell me~

Then, Petto will automatically start a ten-second recording recognition, allowing you to interact with the desktop pet. After the recording recognition ends, the desktop pet will respond.

![Streaming Recognition](backgroundRecognition.png)

#### Whisper Recognition Mode

> Unlike streaming recognition, Whisper recognition mode must complete the recording before obtaining the final text, which mainly affects the speed of background recognition.
>
> Petto supports Whisper APIs compatible with OpenAI usage.

#### Hitokoto API Address

> Keep the default value unless there are special circumstances.

Fill in the API address for requesting Hitokoto.

#### TTS

> Petto supports TTS APIs compatible with OpenAI usage.

Although TTS information is not filled in by default, we actually provide a ready-to-use TTS service:

TTS Address: [https://api.cups.moe/api/tts/](https://api.cups.moe/api/tts/)

TTS Key: ecWdn$TJ&ktP#89

This service is deployed based on [openai-edge-tts](https://github.com/travisvn/openai-edge-tts)

#### Action Groups

Set character action groups. The character will automatically trigger actions each time a task is triggered.

In Live2DViewerEX, select the model you are using, click the custom button at the top right, and you will see a series of action groups.

### Startup

* (Optional) In the settings, check "Hide window on startup"
* Press Win+R, type `shell:startup`. Create a shortcut for `petto.exe` and place it in this folder

### Deploying Models Locally

Please check the following two files:

* `data\flutter_assets\scripts\startmodel.ps1`
* `data\flutter_assets\scripts\startserver.ps1`

They correspond to the scripts for starting the RWKV model and the local streaming speech recognition service, respectively.

#### Starting the RWKV Model

> You can also modify the contents of `startmodel.ps1` to start your own model.

To start the RWKV model, you need to:

* Download [RWKV Runner](https://github.com/josStorer/RWKV-Runner) and configure the environment as instructed.
* Then, [download the RWKV model](https://huggingface.co/BlinkDL/rwkv-7-world) and place it in the `models/` directory under the RWKV Runner directory.
* Adjust the contents of `startmodel.ps1`: follow the `cd` command with the path to the RWKV Runner directory, and change `RWKV-x060-World-3B-v2.1-20240417-ctx4096.pth` to the actual downloaded file name.
* In Petto settings, remove the `#` at the beginning of the "Pre-execution Language Model Command" and then restart Petto.

#### Starting the MASR Speech Recognition Service
> The model provided below is trained only on Chinese corpus. You can manually train models that support more languages and have higher accuracy, or use pre-trained models or Whisper interfaces for speech recognition.

To start the local streaming speech recognition service, go to the `data\flutter_assets\speech\models` directory and:

* Create a directory named `conformer_streaming_fbank` and download [inference.pt](https://www.cups.moe/static/asr/inference.pt) into it.
* Go to the `pun_models` directory and download [model.pdiparams](https://www.cups.moe/static/asr/model.pdiparams) into it.
* In Petto settings, remove the `#` at the beginning of the "Pre-execution Speech Model Command" and then restart Petto.

## TODO

- [ ] Support more languages
- [ ] MacOS and Linux support
- [ ] Add voice authentication
- [ ] Optimize UI