# Live2DViewerEX Compatibility Mode Guide

Although Kage mode is recommended by default since v3.0.0, compatibility support for the original Live2DViewerEX (ExAPI) is retained.

## 1. Activation Steps
1. Launch Live2DViewerEX and ensure its ExAPI functionality is enabled
2. Open Petto Settings → Desktop Pet Mode, select `Live2DViewerEX`
3. Fill in relevant configurations (see details below)
4. Save settings and exit the dialog

## 2. Detailed Configuration

### ExAPI Address

> If there are no special circumstances, keep the default value.

Required field, used for communication with Live2DViewerEX.

Default address: `ws://127.0.0.1:10086/api`

### Live2D Model Number

Required field, used to specify the Live2D model number Petto uses. The value is (model number displayed in Live2DViewerEX - 1). For example, in the case shown below, the selected model's number is 0.

![Live2D Model Number](../modelNoExample.png)

### Action Groups

Set character action groups. The character will automatically trigger motions when tasks are triggered.

Fill in the "Action Groups" field (comma-separated) so Petto can call them when triggering tasks (such as timed greetings, voice responses). For example:
```
Tap,TapHead,Idle
```

**How to view available action groups:**

In Live2DViewerEX, select the model you're using, click the customize button in the top right corner, and you can see a series of action groups.

## 3. v3.0.0 Migration Notes

### Pre-execution Scripts Deprecated
**Important**: v3 refactoring no longer auto-executes old PowerShell startup scripts (startmodel.ps1, startserver.ps1).

If you previously used local model scripts, you need to run these services manually and fill in the interface addresses in settings.

For detailed information about local model deployment, see [CHANGELOG_v3.0.0.md](../CHANGELOG_v3.0.0.md).

### Window Title Feature Deprecated
**Important**: v3.0.0 has removed the "window title" context configuration option.

Now unified to use window screenshot functionality for context information (see "Window Screenshot" settings in README).

## 4. Troubleshooting

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| No motion triggered | Action groups left blank | Add action group names that exist in Live2DViewerEX |
| Text not displaying | ExAPI not enabled/address incorrect | Check Live2DViewerEX settings for port and switch |
| Model number incorrect | Wrong number | Confirm number in Live2DViewerEX model list and subtract 1 |
| Intermittent disconnection | Live2DViewerEX restarted or port occupied | Reconnect or change port |

---
Still using this mode? Feel free to provide feedback on compatibility features you need in Issues for continued maintenance.
