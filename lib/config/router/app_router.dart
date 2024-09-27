import 'package:go_router/go_router.dart';
import 'package:push_app/presentation/screens/home.dart';

final appRouter = GoRouter(initialLocation: '/', routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const Home(),
  )
]);
