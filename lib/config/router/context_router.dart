import 'package:go_router/go_router.dart';
import 'package:ysyw/config/router/route_names.dart';
import 'package:ysyw/screens/authentication_page.dart';

final appRouter = GoRouter(initialLocation: "/",routes: [
  GoRoute(
    name: RouteNames.auth,
    path: "/",
    builder: (context, state) => const AuthenticationPage(),
  ), 
]); 