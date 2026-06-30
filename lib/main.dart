import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/firebase/firebase_service.dart';
import 'core/notifications/notification_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FirebaseService.instance.initialize();
    if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('FCM opened: ${message.data}');
    });
    await NotificationService.instance.initialize();
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FlutterError.presentError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
      ),
    );
    return true;
  };

  runApp(const ProviderScope(child: CoopApp()));
}
