import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ysyw/bloc/auth/authentication_bloc.dart';
import 'package:ysyw/bloc/coach/coach_bloc.dart';
import 'package:ysyw/bloc/competetion/competetion_bloc.dart';
import 'package:ysyw/bloc/profile/profile_bloc.dart';
import 'package:ysyw/bloc/student/student_bloc.dart';
import 'package:ysyw/config/debug/debug.dart';
import 'package:ysyw/config/router/context_router.dart';
import 'package:ysyw/config/theme/theme.dart';
import 'package:ysyw/firebase_options.dart';
import 'package:ysyw/locator.dart';
import 'package:ysyw/services/local_storage_service.dart';

import 'package:ysyw/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((_) => {
            FirebaseMessaging.onBackgroundMessage(
                firebaseMessagingBackgroundHandler)
          });
  NotificationService().init();
  await dotenv.load(fileName: ".env").then((_) {
    Debug.info("Environment variables loaded successfully");
    Debug.info("API URL: ${dotenv.env['API_URL']}");
    Debug.info("Football API URL: ${dotenv.env['FOOTBALL_API_URL']}");
    Debug.info("Football API Key: ${dotenv.env['FOOTBALL_API_KEY']}");
  }).catchError((error) {
    Debug.info("Error loading environment variables: $error");
  });
  setupLocator();
  // LocalStorageService().deleteAuthToken();
  runApp(const RootApp());
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message received: ${message.notification?.title}");
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  @override
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
    });
  }

  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [

        BlocProvider(
          create: (context) => AuthenticationBloc(),
        ),
        BlocProvider(
          create: (context) => StudentBloc(),
        ),
         BlocProvider(
          create: (context) => CompetetionBloc(),
        ),
         BlocProvider(
          create: (context) => CoachBloc(),
        ),
         BlocProvider(
          create: (context) => ProfileBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: 'YSYW',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
