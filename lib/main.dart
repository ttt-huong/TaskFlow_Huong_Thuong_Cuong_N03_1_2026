import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';
import 'providers/task_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/connectivity_provider.dart';
import 'services/connectivity_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (try-catch to run offline if configuration is missing)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e. Running in offline mode.');
  }

  // Khởi tạo ConnectivityService trước khi runApp để isOnline có giá trị ngay
  await ConnectivityService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        // ConnectivityProvider phải được tạo sau TaskProvider & ProjectProvider
        // vì nó cần gọi syncPending() khi có mạng trở lại
        ChangeNotifierProxyProvider2<TaskProvider, ProjectProvider,
            ConnectivityProvider>(
          create: (_) => ConnectivityProvider(),
          update: (_, taskProvider, projectProvider, previous) {
            previous?.updateSyncCallback(
              onBackOnline: () async {
                await taskProvider.syncPending();
                await projectProvider.syncPending();
              },
            );
            return previous ?? ConnectivityProvider();
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}