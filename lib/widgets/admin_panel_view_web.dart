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
      final iframe = html.IFrameElement()
        ..src = 'admin_panel.html?embed=1'
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
