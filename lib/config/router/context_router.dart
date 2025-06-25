import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:ysyw/config/router/route_names.dart';
import 'package:ysyw/screens/auth/sign_up_page.dart';
import 'package:ysyw/screens/onboarding_page.dart';

final appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      name: RouteNames.onboarding,
      path: "/",
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const OnboardingPage(),
      ),
    ),
    GoRoute(
      name: RouteNames.signup,
      path: "/signup",
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const SignUpPage(),
      ),
    ),
  ],
);