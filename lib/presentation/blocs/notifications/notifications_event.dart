part of 'notifications_bloc.dart';

sealed class NotificationsEvent {
  const NotificationsEvent();
}

//* clase que manejara el cambio de estado del permiso
class NotificationStatusChange extends NotificationsEvent {
  final AuthorizationStatus status;

  NotificationStatusChange(this.status);
}

class NotificationReceived extends NotificationsEvent {
  final PushMessage notification;

  NotificationReceived(this.notification);
}
