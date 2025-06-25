import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ysyw/bloc/auth/authentication_bloc.dart';
import 'package:ysyw/config/router/context_router.dart';
import 'package:ysyw/config/theme/theme.dart';
import 'package:ysyw/firebase_options.dart';
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
  await dotenv.load(fileName: ".env");
  runApp(const RootApp());
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // send notication to the user

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
