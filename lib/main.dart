import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_service_example/audio_service/audio_handler.dart';
import 'package:audio_service_example/screens/lesson_screen.dart';
import 'package:audio_service_example/screens/lessons_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// You might want to provide this using dependency injection rather than a
// global variable.
late AudioPlayerHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setPreferredOrientations();
  await setSystemOverlayStyle();

  audioHandler = await init();

  AudioService.notificationClicked.listen((clicked) {
    if (clicked) {
      print('--- Cliked ---');
      Get.toNamed("/lesson");
    }
  });

  runApp(MyApp());
}

Future<AudioPlayerHandler> init() async => await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );

// * Set Device Orientation
Future<void> setPreferredOrientations() => SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

// * Set System UI Overlay
Future setSystemOverlayStyle() async => SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(41, 125, 193, 1.0),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

/// The app widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      enableLog: true,
      defaultTransition: Transition.cupertino,
      themeMode: ThemeMode.system,
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData(primarySwatch: Colors.grey),
      title: 'Audio Service Demo',
      home: MainScreen(),
      getPages: [
        GetPage(name: "/home", page: () => MainScreen()),
        GetPage(name: "/lesson", page: () => LessonScreen()),
      ],
    );
}
