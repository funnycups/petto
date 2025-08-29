// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/utils/platform_utils.dart';
import '../../core/services/system_service.dart';
import '../../generated/l10n.dart';

class TrayService with TrayListener {
  static final TrayService _instance = TrayService._internal();
  static TrayService get instance => _instance;

  TrayService._internal();

  Future<void> init() async {
    await trayManager
        .setIcon(await PlatformUtils.loadAsset('images/tray_icon.ico'));
    Menu menu = Menu(
      items: [
        MenuItem(key: 'show_window', label: S.current.show),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: S.current.exit),
      ],
    );
    await trayManager.setContextMenu(menu);
    trayManager.addListener(this);
  }

  void dispose() {
    trayManager.removeListener(this);
  }

  @override
  Future<void> onTrayIconMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  Future<void> onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  Future<void> onTrayIconRightMouseUp() async {
    await trayManager.popUpContextMenu();
  }

  @override
  Future<void> onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      await windowManager.show();
    } else if (menuItem.key == 'exit_app') {
      await SystemService.instance.quit();
    }
  }
}
