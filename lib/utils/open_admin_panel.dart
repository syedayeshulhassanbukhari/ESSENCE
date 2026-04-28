import 'package:url_launcher/url_launcher.dart';

Future<bool> openAdminPanelPage() async {
    final uri = Uri.base.resolve('admin_panel.html');
    return launchUrl(
        uri,
        webOnlyWindowName: '_self',
    );
}