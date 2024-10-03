import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_app/config/router/app_router.dart';

//*Clase que maneja las interacciones de las local notifications con el usuario
class LocalNotification {
  //* función de solicitud de permiso de las local notifications
  static Future<void> requestPermissionLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> initializeLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAdroid =
        AndroidInitializationSettings('app_icon');

    //todo: ios configuration
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAdroid,
      // todo ios configuration seeting
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  static void showLocalNotification(
      {required int id,
      required String title,
      required String body,
      String? data}) {
    //* playSound se utiliza para cambiar el sonido de la notificación junto con el "sound"
    //*para cambiar el sonido hay que copiar el archivo en la carpeta android/main/res/raw
    //* la carpeta raw hay que crearla
    const androidDetails = AndroidNotificationDetails(
        'channelId', 'channelName',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        importance: Importance.max,
        priority: Priority.high);

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      //todo ios
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails,
        payload: data);
  }

  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    appRouter.push('/push-details/${response.payload}');
  }
}
