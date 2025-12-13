import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/home_feed_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      // On mobile the default app is configured via google-services plist/json.
      // Only pass explicit options when needed (web/desktop).
      await Firebase.initializeApp(
        options: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
      );
    }
  } catch (e) {
    final message = e.toString();
    if (!message.contains('duplicate-app')) {
      rethrow;
    }

  }

  runApp(const BeastModeApp());
}

class BeastModeApp extends StatelessWidget {
  const BeastModeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeastMode',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Logged in
        if (snapshot.hasData) {
          return const HomeFeedScreen();
        }

        // Logged out
        return const LoginScreen();
      },
    );
  }
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color.fromARGB(255, 253, 107, 63),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: const Color.fromARGB(255, 253, 107, 63), // accent color
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor:  Color.fromARGB(255, 253, 107, 63),
      foregroundColor: Colors.white,
      elevation: 2,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 253, 107, 63),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor:  Color.fromARGB(255, 255, 84, 32),
      unselectedItemColor: Color.fromARGB(255, 253, 107, 63),
      showUnselectedLabels: true,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 253, 107, 63),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
  );
}
