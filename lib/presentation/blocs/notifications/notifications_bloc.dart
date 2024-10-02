import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:push_app/domain/entities/push_messages.dart';
import 'package:push_app/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

//* funcion que manejara las notificaciones cuando la aplicacion no este corriendo
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(const NotificationsState()) {
    on<NotificationStatusChange>(_notificationStatusChanged);

    on<NotificationReceived>(_onPushMessageReceived);

//* este metodo verifica cual es el status del permiso de notificaciones y lo mantiene
    _initialStatusCheck();

//*como este metodo es un listeter se coloca una unica vez cuando se inicializa la aplicación
//* y este listener se mantine pendiente de si se reciben notificaciones
    _onForegroundMessage();
  }

//* Funcion que inicializa Firebase Cloud Messaging
  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  //* metodo que se utiliza para saber el status del permiso para notificaciones
  void _notificationStatusChanged(
      NotificationStatusChange event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(status: event.status));
    _getFCMToken();
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();

    add(NotificationStatusChange(settings.authorizationStatus));
  }

  void _getFCMToken() async {
    if (state.status != AuthorizationStatus.authorized) return;

    //*obteniendo token
    final token = await messaging.getToken();

    //* token necesario para mandar la notificacion
    //* este token se puede grabar en el backend para despues mandarle notificaciones al telefono
    print(token);
  }

//* metodo para manejar los mensajes o notificaciones que se envien del backend
  void handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) return;

    final notification = PushMessage(
        messageId:
            message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        sendDate: message.sentTime ?? DateTime.now(),
        data: message.data,
        imageUrl: Platform.isAndroid
            ? message.notification!.android?.imageUrl
            : message.notification!.apple?.imageUrl);

    add(NotificationReceived(notification));
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPemition() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    //* Emitiendo el permiso dado por el usuario
    add(NotificationStatusChange(settings.authorizationStatus));
  }

  void _onPushMessageReceived(
      NotificationReceived event, Emitter<NotificationsState> emit) {
    emit(state
        .copyWith(notifications: [event.notification, ...state.notifications]));
  }

//*Metodo vara buscar dentro de las notificaciones por id
  PushMessage? getMessageById(String pushMessageId) {
    final exist = state.notifications
        .any((element) => element.messageId == pushMessageId);

    if (!exist) return null;

//* firstWhere es para buscar por is dentro del List si existe el elemento
    return state.notifications
        .firstWhere((element) => element.messageId == pushMessageId);
  }
}
