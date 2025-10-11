// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final _fm = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

//   static Future<void> init() async {
//     // ask permission
//     NotificationSettings settings = await _fm.requestPermission();

//     // local notifications (Android)
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await _local.initialize(initializationSettings);

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       // show local notification
//       final notification = message.notification;
//       if (notification != null) {
//         _local.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails('default', 'Default', importance: Importance.max),
//           ),
//         );
//       }
//     });
//   }
// }
