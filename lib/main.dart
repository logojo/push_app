import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/config/router/app_router.dart';

import 'package:push_app/config/theme/app_theme.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

void main() async {
  //*inicializando firebase
  WidgetsFlutterBinding.ensureInitialized();
  //*mandando llamar la funcion que se encarga de las notificaciones cuando la aplicacion no esta corriendo
  //* esto es un listener
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  //*inicializando notificaciones push
  await NotificationsBloc.initializeFCM();

  //* instancia del bloc en el punto más alto de la aplicación
  //* esto permite que en toda la aplicacion se pueda acceder al bloc
  runApp(MultiBlocProvider(
      providers: [BlocProvider(create: (_) => NotificationsBloc())],
      child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      //*builder para manejo de notificaciones en app minimizada
      builder: (context, child) =>
          HandleNotificationInteractions(child: child!),
    );
  }
}

//*widget que se encarga de realizar la interacción con las notificaciones cuando la app esta minimizada

class HandleNotificationInteractions extends StatefulWidget {
  final Widget child;

  const HandleNotificationInteractions({super.key, required this.child});

  @override
  State<HandleNotificationInteractions> createState() =>
      _HandleNotificationInteractionsState();
}

class _HandleNotificationInteractionsState
    extends State<HandleNotificationInteractions> {
  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    //*usando la funcion handleRemoteMessage de mi bloc para almacenar la notificacion en el List
    context.read<NotificationsBloc>().handleRemoteMessage(message);

    //*exportardo la variable appRouter para poder navegar a la ruta
    final messageId =
        message.messageId?.replaceAll(':', '').replaceAll('%', '');

    appRouter.push('/push-details/$messageId');

    //* con el type que viene en la data del mensaje puedo identificarlo para navegar a diferentes pantalla
    // if (message.data['type'] == 'chat') {
    //   Navigator.pushNamed(
    //     context,
    //     '/chat',
    //     arguments: ChatArguments(message),
    //   );0
    // }
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
