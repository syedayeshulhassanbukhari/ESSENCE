import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/widgets.dart';

class AdminPanelView extends StatelessWidget {
  const AdminPanelView({super.key});

  static const String _viewType = 'admin-panel-view';
  static bool _registered = false;

  void _registerView() {
    if (_registered) {
      return;
    }
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final origin = html.window.location.origin;
      final serverOrigin = origin.contains('localhost') || origin.contains('127.0.0.1')
          ? '${html.window.location.protocol}//${html.window.location.hostname}:5050'
          : origin;
      final iframe = html.IFrameElement()
        ..src = '$serverOrigin/?embed=1'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });
    _registered = true;
  }

  @override
  Widget build(BuildContext context) {
    _registerView();
    return const HtmlElementView(viewType: _viewType);
  }
}
