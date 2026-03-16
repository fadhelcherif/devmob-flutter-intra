import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/splash/Splash.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/group_message_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase already initialized: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GroupMessageProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return AnimatedBuilder(
            animation: themeProvider,
            builder: (context, child) {
              return MaterialApp(
                title: 'DEVMOB - FlutterIntra',
                debugShowCheckedModeBanner: false,
                themeMode: themeProvider.themeMode,
                theme: themeProvider.lightTheme,
                darkTheme: themeProvider.darkTheme,
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
