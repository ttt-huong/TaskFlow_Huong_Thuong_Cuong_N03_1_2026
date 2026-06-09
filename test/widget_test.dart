import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_app/app.dart';
import 'package:my_app/providers/auth_provider.dart';
import 'package:my_app/providers/project_provider.dart';
import 'package:my_app/providers/task_provider.dart';
import 'package:my_app/providers/connectivity_provider.dart';

void main() {
  testWidgets('App starts and displays login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame with correct providers.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProjectProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the login text or button is present
    expect(find.byType(TextField), findsNWidgets(2)); // Email and password text fields
    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
