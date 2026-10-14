import 'package:url_launcher/url_launcher.dart';

class LinkUtils {
  LinkUtils._();

  static Future<bool> openUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }
}
