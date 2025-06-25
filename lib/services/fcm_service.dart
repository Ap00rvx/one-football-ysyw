import 'package:ysyw/config/debug/debug.dart';
import 'package:ysyw/global/dio.dart';
import 'package:ysyw/services/notification_service.dart';

class FcmService {
  final _dioClient = DioClient();
  Future<void> saveToken(String userId) async {
    String? token = await NotificationService().getFCMToken();
    if (token == null) {
      Debug.error("Failed to retrieve FCM Token.");
      return;
    }
    try {
      final response = await _dioClient.post(
        '/app/fcm/save-token',
        data: {'fcmToken': token, 'userId': userId},
      );
      if (response.statusCode == 200) {
        Debug.success("FCM Token saved successfully: ${response.data}");
      } else {
        Debug.error("Failed to save FCM Token: ${response.statusMessage}");
      }
    } catch (e) {
      Debug.error("Error saving FCM Token: $e");
    }
  }
}
