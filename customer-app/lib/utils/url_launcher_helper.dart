import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';

/// Helper class for launching URLs, phone calls, emails, etc.
class UrlLauncherHelper {
  /// Launch a phone call
  static Future<bool> launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    return _launchUrl(phoneUri);
  }

  /// Launch WhatsApp chat
  static Future<bool> launchWhatsApp(String phoneNumber, {String? message}) async {
    // Remove any non-digit characters except +
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$cleanNumber${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
    );
    return _launchUrl(whatsappUri);
  }

  /// Launch email
  static Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );
    return _launchUrl(emailUri);
  }

  /// Launch a web URL
  static Future<bool> launchWebUrl(String url) async {
    final Uri webUri = Uri.parse(url);
    return _launchUrl(webUri);
  }

  /// Launch map navigation to coordinates
  static Future<bool> launchMaps(double lat, double lng, {String? label}) async {
    // Try Google Maps first
    final googleMapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    return _launchUrl(googleMapsUri);
  }

  /// Launch support phone
  static Future<bool> launchSupportPhone() async {
    return launchPhone(AppConstants.supportPhone);
  }

  /// Launch support email
  static Future<bool> launchSupportEmail({String? subject}) async {
    return launchEmail(
      AppConstants.supportEmail,
      subject: subject ?? 'دعم تطبيق توصيل الباجور',
    );
  }

  /// Launch support WhatsApp
  static Future<bool> launchSupportWhatsApp({String? message}) async {
    return launchWhatsApp(
      AppConstants.supportPhone,
      message: message ?? 'مرحباً، أحتاج مساعدة',
    );
  }

  /// Internal method to launch URL
  static Future<bool> _launchUrl(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Encode query parameters for email
  static String? _encodeQueryParameters(Map<String, String> params) {
    if (params.isEmpty) return null;
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
