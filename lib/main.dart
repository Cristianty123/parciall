import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
import 'application/auth_provider.dart';
import 'ui/home/home_selector.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryAutoLogin()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeSelector(),
    );
  }
=======
import 'app.dart';
import 'application/providers/user_provider.dart';
import 'injection.dart';
import 'application/providers/auth_provider.dart';
import 'application/providers/image_provider.dart' as image;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initInjection();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => sl<AuthProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<UserProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<image.ImageProvider>(),
        ),
      ],
      child: const EmprendeApp(),
    ),
  );
>>>>>>> origin/master
}