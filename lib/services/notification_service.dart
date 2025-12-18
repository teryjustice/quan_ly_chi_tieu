import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse, // Đã sửa ở đây
    );
  }

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    // Xử lý khi người dùng nhấn vào thông báo cục bộ (ứng dụng đang chạy/nền)
    // ignore: avoid_print
    print('Notification tapped! Payload: ${notificationResponse.payload}');
    if (notificationResponse.payload != null) {
      // Ví dụ: Điều hướng đến một màn hình cụ thể dựa trên payload
      // Bạn cần có NavigatorKey hoặc Context để thực hiện điều hướng thực tế.
      // For now, we just print.
    }
  }

  // Đã chuyển thành hàm static
  @pragma('vm:entry-point')
  static void onBackgroundNotificationResponse(NotificationResponse notificationResponse) {
    // Xử lý khi người dùng nhấn vào thông báo cục bộ (ứng dụng đã bị đóng)
    // ignore: avoid_print
    print('Background notification tapped! Payload: ${notificationResponse.payload}');
    if (notificationResponse.payload != null) {
      // Tương tự, bạn có thể xử lý điều hướng ở đây.
    }
  }

  Future<void> showNotification(int id, String title, String body, {String? payload}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      channelDescription: 'Your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}