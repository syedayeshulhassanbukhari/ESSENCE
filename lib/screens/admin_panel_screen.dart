import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../widgets/admin_panel_view.dart';
import '../widgets/layout_widgets.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    final background = brightness == Brightness.light
        ? colors.backgroundLight
        : colors.backgroundDark;

    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: const [
          AppHeader(),
          Expanded(child: AdminPanelView()),
        ],
      ),
    );
  }
}
