# Kage Mode Guide

Kage mode is the default desktop pet rendering and interaction method since v3.0.0, providing an alternative solution to Live2DViewerEX.
Kage is free and open source software. You can submit issues, contribute, or review the source code in the [Kage repository](https://github.com/funnycups/kage).

## 1. First Run & Auto Download
1. Launch Petto directly (defaults to Kage mode on first run)
2. If `kage_executable` is not configured and Kage is not running locally:
   * Petto will prompt to download the latest [Release](https://github.com/funnycups/kage/releases/latest)
3. After extraction, the executable path will be recorded for future launches.

> If you already have Kage installed manually, you can select its executable file in settings and set the model JSON path.

## 2. Settings Explanation
When selecting `Kage` in Settings → Mode, the following fields will appear:

### Kage Executable

Path to the Kage executable file. Supports:
* Windows: `kage.exe`
* macOS: `Kage.app`
* Linux: `kage`

Example: `C:\Users\You\.petto\kage\kage.exe`

If left blank and Kage is not running, Petto will prompt for download on startup.

### Model Config Path

Path to the Kage model JSON file.

Example: `C:\models\hiyori.model3.json`

### Kage API Address

Kage's WebSocket service address.

Default: `ws://localhost:23333`

If you modify Kage's startup port, you need to update this address accordingly.

### Action Groups

List of available motions for the desktop pet, comma-separated.

Example: `Idle,Tap,TapHead`

**How to obtain:**
1. Click the refresh icon on the right
2. Petto will automatically fetch all motions from Kage for the current model
3. Auto-fill into this field

You can also fill manually, but ensure the motion names match those in the model.

## 3. Model Loading & Switching

### Initial Loading
1. Fill in the complete path to the model JSON file in "Model Config Path"
2. Click save
3. Petto will automatically send the model path to Kage via WebSocket
4. After Kage loads successfully, click the refresh button next to action groups to fetch the motion list

### Switching Models
1. Select a new model JSON path
2. Click save
3. Kage will automatically unload the old model and load the new one

## 4. Motions & Expressions

Kage supports the following features:
* **Trigger Motion**: Automatically triggers random motions from the action group during timed greetings and voice responses
* **Query Motion List**: Fetch all available motions for the current model via the refresh button
* **Set Expression**: Support long-term expression settings (if model supports)
* **Clear Expression**: Restore to default expression

Motions are automatically triggered in the following scenarios:
* Timed greetings
* Responses after voice recognition
* When user sends messages

## 5. Common Issues

### Cannot Connect to Kage
**Possible Causes:**
* Kage not running
* WebSocket address incorrect
* Firewall blocking
* Port occupied by another program

**Solutions:**
1. Confirm if Kage is running
2. Check if the address matches what's configured in Kage (default `ws://localhost:23333`)
3. Check firewall settings, allow Petto and Kage to communicate
4. If port is occupied, modify Kage's startup parameters and update the address in Petto settings accordingly

### Motion/Expression List is Empty
**Possible Causes:**
* Model JSON path incorrect
* Model file corrupted
* Model format not supported

**Solutions:**
1. Confirm the model JSON file path is correct and the file exists
2. Try loading the model in Kage standalone to see if there are error messages

## 6. Log Troubleshooting

Enable Settings → Enable Logging to view detailed log information.

Log files can help quickly identify issues. It's recommended to enable logging when encountering problems.
