import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:ysyw/config/debug/debug.dart';
import 'package:ysyw/config/router/route_names.dart';
import 'package:ysyw/screens/auth/login_page.dart';
import 'package:ysyw/screens/auth/otp_verification_page.dart';
import 'package:ysyw/screens/auth/sign_up_page.dart';
import 'package:ysyw/screens/home/home_page.dart';
import 'package:ysyw/screens/onboarding_page.dart';
import 'package:ysyw/screens/splash_page.dart';
import 'package:ysyw/screens/user.details/coach_details_page.dart';
import 'package:ysyw/screens/user.details/student_details_page.dart';

final appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      name: RouteNames.splash,
      path: "/",
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const SplashPage(),
      ),
    ),
    GoRoute(
      name: RouteNames.onboarding,
      path: "/onboarding",
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
    GoRoute(
      name: RouteNames.login,
      path: "/login",
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      name: RouteNames.home,
      path: "/home",
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const HomePage(),
      ),
    ),
    GoRoute(
      name: RouteNames.verify,
      path: "/verify",
      // Assuming the email is passed as a query parameter
      pageBuilder: (context, state) {
        // Extract email from the extras
        final email =
            (state.extra as Map<String, dynamic>?)?['email'] as String?;
        // Extract isLogin flag from the extras
        final isLogin =
            (state.extra as Map<String, dynamic>?)?['isLogin'] as bool? ??
                false;
        Debug.custom(
            'Navigating to OtpVerificationPage with email: $email, isLogin: $isLogin',
            "");

        return CupertinoPage(
          key: state.pageKey,
          child: OtpVerificationPage(email: email ?? '', isLogin: isLogin),
        );
      },
    ),
    GoRoute(
      name: RouteNames.studentDetails,
      path: "/studentDetails",
      // Assuming the email is passed as a query parameter
      pageBuilder: (context, state) {
        // Extract email from the extras
        final email =
            (state.extra as Map<String, dynamic>?)?['email'] as String?;
        final name = (state.extra as Map<String, dynamic>?)?['name'] as String?;
        final userId =
            (state.extra as Map<String, dynamic>?)?['userId'] as String?;

        return CupertinoPage(
          key: state.pageKey,
          child: StudentDetailsPage(
            email: email ?? '',
            name: name ?? '',
            userId: userId ?? '',
          ),
        );
      },
    ),
     GoRoute(
      name: RouteNames.coachDetails,
      path: "/coachDetails",
      // Assuming the email is passed as a query parameter
      pageBuilder: (context, state) {
        // Extract email from the extras
        final email =
            (state.extra as Map<String, dynamic>?)?['email'] as String?;
        final name = (state.extra as Map<String, dynamic>?)?['name'] as String?;
        final userId =
            (state.extra as Map<String, dynamic>?)?['userId'] as String?;

        return CupertinoPage(
          key: state.pageKey,
          child: CoachDetailsPage(
            email: email ?? '',
            name: name ?? '',
            userId: userId ?? '',
          ),
        );
      },
    ),
  ],
);
