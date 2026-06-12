import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

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
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(),
          update: (_, authProvider, previous) {
            final provider = previous ?? NotificationProvider();
            provider.updateUser(authProvider.currentUser);
            return provider;
          },
        ),
        // ConnectivityProvider phải được tạo sau TaskProvider & ProjectProvider
        // vì nó cần gọi syncPending() khi có mạng trở lại
        ChangeNotifierProxyProvider2<TaskProvider, ProjectProvider,
            ConnectivityProvider>(
          create: (_) => ConnectivityProvider(),
          update: (_, taskProvider, projectProvider, previous) {
            final provider = previous ?? ConnectivityProvider();
            provider.updateSyncCallback(
              onBackOnline: () async {
                await projectProvider.syncPending();
                await taskProvider.syncPending();
              },
            );
            return provider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}