import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';

import 'views/auth/login_screen.dart';
import 'views/student/home_screen.dart';
import 'views/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ibkedixspebmwopcefwr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlia2VkaXhzcGVibXdvcGNlZndyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2MzgxMzQsImV4cCI6MjA5MzIxNDEzNH0.gS91PwR9S8V2AbKo2ZFVBv4yhOrnusF65U1nAjolbuw',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin': (context) => const AdminDashboard(),
        },
      ),
    );
  }
}