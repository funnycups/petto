# Petto

An intelligent Live2D desktop assistant.

[English](README.md) · [简体中文](README_zh.md)

![Chat Feature](chat.png)


## 1. Overview
Petto periodically outputs quotes/contextual greetings/time greetings, supports streaming/Whisper voice recognition, TTS voice synthesis, motion triggering, expression management, etc. Since v3.0.0, it uses the new Kage mode by default; the original Live2DViewerEX ExAPI workflow is retained as "compatibility mode".

## 2. v3.0.0 Update
v3.0.0 is a major update featuring code refactoring, new Kage default mode, cross-platform improvements, and more.

**View complete changelog**: [CHANGELOG_v3.0.0.md](CHANGELOG_v3.0.0.md)

## 3. Mode Selection
| Mode | Status | Documentation |
| ---- | ------ | ------------- |
| Kage | Recommended | [docs/MODE_KAGE.md](docs/MODE_KAGE.md) |
| Live2DViewerEX Compatibility | Supported | [docs/MODE_LIVE2DVIEWEREX.md](docs/MODE_LIVE2DVIEWEREX.md) |

## 4. Quick Start
1. Download the latest Release and extract
2. Run `petto` directly
3. If Kage is not found on first launch, it will detect and prompt for download
4. Confirm WebSocket address in settings (default `ws://localhost:23333`), optionally select model JSON
5. Click the refresh button next to action groups to auto-fetch motions
6. Start chatting or enable streaming recognition

### Using Live2DViewerEX Compatibility Mode
Settings → Switch to compatibility mode → Fill in ExAPI address and model number. See [MODE_LIVE2DVIEWEREX.md](docs/MODE_LIVE2DVIEWEREX.md) for details.

## 5. Main Features
* Contextual greetings (based on weather/time/current window screenshot)
* Voice interaction:
  * Streaming MASR-compatible recognition
  * Whisper recognition (OpenAI compatible)
* Background keyword wake-up
* TTS voice playback (OpenAI compatible, demo endpoint provided)
* Wake-up via hotkey
* Auto-fetch motion list in Kage mode
* Optional window screenshots
* Update check and logging toggle

## 6. Detailed Settings

You can configure Petto features in detail from the settings in the top right corner of the main interface.

### Desktop Pet Mode
- **Kage (Default)**: Modern WebSocket interface with auto-download support, supports motion/expression/text management
  - See [MODE_KAGE.md](docs/MODE_KAGE.md) for detailed configuration
- **Live2DViewerEX Compatibility**: Maintains support for legacy versions, requires manual configuration
  - See [MODE_LIVE2DVIEWEREX.md](docs/MODE_LIVE2DVIEWEREX.md) for detailed configuration

### Language Model (LLM) Settings

> Petto supports OpenAI-compatible language model APIs.

Petto is pre-configured with a public language model: [https://free-llm.cups.moe/v1](https://free-llm.cups.moe/v1), which includes some directly usable models.

Key: sk-ObgTAfL0qYK6OmoYpQx2qra3EyIxdtP2DPAzz8D5wwe3Eb9l

Note: This public service may periodically change keys or shut down. Please do not abuse.

### Character Settings

> You can customize the character's name, profile, alias, and other information.

Write character settings that match your expectations based on the desktop pet character you're using!

### Message Examples

> LLM responses will be influenced by message examples.

This setting provides reference examples to the model. If the LLM's responses don't meet your expectations, try writing example messages for the model to learn from.

### Streaming Voice Recognition

> If the recognition address is left blank, Whisper recognition mode will be used.

> The background recognition service keeps recording continuously and sends voice content to the configured recognition address. Be aware of potential privacy and security issues.

Currently, streaming recognition must use an interface compatible with the [MASR](https://github.com/yeyupiaoling/MASR) server-side recognition project.

The project is pre-configured with a public streaming recognition service: wss://api.cups.moe/api/asr/

Server performance is poor, use with care :) Heavy usage might crash my server.

It's recommended to deploy MASR service yourself following the tutorial below, or use Whisper mode.

After enabling background streaming recognition, Petto will continuously run in the background. When any speech containing the background wake-up keyword is detected, the desktop pet will send you a message and prompt you to talk to it:
> User: Help me
>
> Desktop Pet: Master, what do you need help with? Please tell me~

Then, Petto will automatically start a ten-second recording recognition session. You can interact with the desktop pet, and after the recording ends, it will respond.

![Streaming Recognition](backgroundRecognition.png)

### Whisper Recognition Mode

> Unlike streaming recognition, Whisper recognition mode must complete recording before obtaining the final text, which mainly affects background recognition speed.
>
> Petto supports OpenAI-compatible Whisper APIs.

### Hitokoto API Address

> If there are no special circumstances, keep the default value.

Fill in the API address for requesting Hitokoto quotes.

### TTS

> Petto supports OpenAI-compatible TTS APIs.

Although TTS information is not filled in by default, we actually provide a ready-to-use TTS service:

TTS Address: [https://api.cups.moe/api/tts/](https://api.cups.moe/api/tts/)

TTS Key: ecWdn$TJ&ktP#89

This service is deployed based on [openai-edge-tts](https://github.com/travisvn/openai-edge-tts)

### Hotkey

Set the hotkey to wake up Petto. Record and save to take effect.

### Window Screenshot

> This feature captures screenshots of the current active window as context information. Disabled by default.

If screenshot mode is enabled in settings as context:
* Petto will pass the current active window screenshot to the language model to generate more contextual greetings
* Be aware of potential privacy and security issues

**Cross-platform Support:**

v3.0.0 uses [xcap](https://github.com/nashaofu/xcap) for cross-platform screenshots, supporting Windows, macOS, and Linux.

**Note:** v3.0.0 has removed the legacy "window title" feature, now unified to use window screenshots.

### Text Display Duration

Set the display time for desktop pet text bubbles, in milliseconds.

Default: `3000` (3 seconds)

* Applies to both Kage mode and Live2DViewerEX compatibility mode
* Controls display duration for greetings, reply messages, and other text

## 7. Auto-start on Boot

* (Optional) In settings, check "Hide window on startup"
* Press Win+R, type shell:startup. Create a shortcut for petto.exe and place it in this folder

## 8. Local MASR Voice Recognition Deployment

> The models provided below are trained only on Chinese corpus. You can manually train models that support more languages and have higher accuracy, or use pre-trained models or Whisper API for voice recognition.

* Download [inference.pt](https://www.cups.moe/static/asr/inference.pt) for local deployment.
* Download [model.pdiparams](https://www.cups.moe/static/asr/model.pdiparams) to punctuate speech recognition results.

## 9. Voice Mode Description
**Streaming:** Real-time transmission, fast response.
**Whisper:** Record first then recognize. Leave the streaming address blank to enable Whisper mode.
**Privacy:** Be aware of privacy risks when using voice recognition.

## 10. Roadmap / TODO
- [ ] Support more languages
- [ ] Voice authentication
- [ ] UI optimization
- [x] macOS support
- [x] Linux support
- [x] Kage integration

## 11. Common Issues
| Issue | Troubleshooting |
| ----- | --------------- |
| Cannot connect to Kage | Check ws address/firewall/port occupation |
| Motion list is empty | Is model JSON correct; refresh; check logs |
| Text not displaying | Text display duration>0; is version latest |
| Streaming lag | Self-host MASR or switch to Whisper |
| No motions in compatibility mode | Is action group filled correctly |
| Kage not auto-detected | Manually select executable and restart |

## 12. Contributing
Contributions and bug reports are welcome.

## 13. License
GPL-3.0-or-later, see LICENSE for details.

## 14. Sponsor
Sponsored by NETJETT: https://netjett.com/aff.php?aff=45

---

Need more detailed mode instructions? Read: [docs/MODE_KAGE.md](docs/MODE_KAGE.md) and [docs/MODE_LIVE2DVIEWEREX.md](docs/MODE_LIVE2DVIEWEREX.md).