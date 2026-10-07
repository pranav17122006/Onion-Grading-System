// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'firebase_options.dart';
// import 'pages/home_page.dart';
// import 'pages/welcome_page.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   runApp(const OnionQualityApp());
// }

// class OnionQualityApp extends StatelessWidget {
//   const OnionQualityApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Onion Quality Grading',

//       theme: ThemeData(
//         useMaterial3: true,

//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF2E7D32),
//         ),

//         scaffoldBackgroundColor:
//             const Color(0xFFF7F9F5),

//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color(0xFF2E7D32),
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),

//         inputDecorationTheme:
//             InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,

//           border: OutlineInputBorder(
//             borderRadius:
//                 BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),

//           enabledBorder:
//               OutlineInputBorder(
//             borderRadius:
//                 BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: Colors.grey.shade300,
//             ),
//           ),

//           focusedBorder:
//               const OutlineInputBorder(
//             borderRadius:
//                 BorderRadius.all(
//               Radius.circular(12),
//             ),
//             borderSide: BorderSide(
//               color: Color(0xFF2E7D32),
//               width: 2,
//             ),
//           ),
//         ),
//       ),

//       // IMPORTANT:
//       // AuthGate must remain the root page.
//       home: const AuthGate(),
//     );
//   }
// }

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream:
//           FirebaseAuth.instance.authStateChanges(),

//       builder: (context, snapshot) {
//         // Firebase is checking authentication.
//         if (snapshot.connectionState ==
//             ConnectionState.waiting) {
//           return const Scaffold(
//             backgroundColor:
//                 Color(0xFFF7F9F5),

//             body: Center(
//               child:
//                   CircularProgressIndicator(
//                 color:
//                     Color(0xFF2E7D32),
//               ),
//             ),
//           );
//         }

//         // Authentication error.
//         if (snapshot.hasError) {
//           return const Scaffold(
//             backgroundColor:
//                 Color(0xFFF7F9F5),

//             body: Center(
//               child: Text(
//                 'Unable to check login status.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           );
//         }

//         // USER IS LOGGED IN
//         if (snapshot.data != null) {
//           return const HomePage();
//         }

//         // USER IS LOGGED OUT
//         return const WelcomePage();
//       },
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart'  as firebase_auth;
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'firebase_options.dart';
// import 'pages/home_page.dart';
// import 'pages/welcome_page.dart';


// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // ============================================================
//   // SUPABASE INITIALIZATION
//   // ============================================================

//  await Supabase.initialize(
//   url: 'https://zlmokjoyhchgebqljrzz.supabase.co',
//   anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsbW9ram95aGNoZ2VicWxqcnp6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkyMDAzMDYsImV4cCI6MjEwNDc3NjMwNn0.bkOAdYJC1EQ7YrHjJxIoBPXy2wheGsg2V-5hlNVvZcI',
// );

//   runApp(const OnionQualityApp());
// }

// class OnionQualityApp extends StatelessWidget {
//   const OnionQualityApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Onion Quality Grading',

//       theme: ThemeData(
//         useMaterial3: true,

//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF2E7D32),
//         ),

//         scaffoldBackgroundColor:
//             const Color(0xFFF7F9F5),

//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color(0xFF2E7D32),
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),

//         inputDecorationTheme:
//             InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,

//           border: OutlineInputBorder(
//             borderRadius:
//                 BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),

//           enabledBorder:
//               OutlineInputBorder(
//             borderRadius:
//                 BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: Colors.grey.shade300,
//             ),
//           ),

//           focusedBorder:
//               const OutlineInputBorder(
//             borderRadius:
//                 BorderRadius.all(
//               Radius.circular(12),
//             ),
//             borderSide: BorderSide(
//               color: Color(0xFF2E7D32),
//               width: 2,
//             ),
//           ),
//         ),
//       ),

//       // IMPORTANT:
//       // AuthGate must remain the root page.
//       home: const AuthGate(),
//     );
//   }
// }

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<firebase_auth.User?>(
//       stream:
//           firebase_auth.FirebaseAuth.instance.authStateChanges(),

//       builder: (context, snapshot) {
//         // Firebase is checking authentication.
//         if (snapshot.connectionState ==
//             ConnectionState.waiting) {
//           return const Scaffold(
//             backgroundColor:
//                 Color(0xFFF7F9F5),

//             body: Center(
//               child:
//                   CircularProgressIndicator(
//                 color:
//                     Color(0xFF2E7D32),
//               ),
//             ),
//           );
//         }

//         // Authentication error.
//         if (snapshot.hasError) {
//           return const Scaffold(
//             backgroundColor:
//                 Color(0xFFF7F9F5),

//             body: Center(
//               child: Text(
//                 'Unable to check login status.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           );
//         }

//         // USER IS LOGGED IN
//         if (snapshot.data != null) {
//           return const HomePage();
//         }

//         // USER IS LOGGED OUT
//         return const WelcomePage();
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/welcome_page.dart';
import 'localization/app_localizations.dart';


// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================================
  // FIREBASE INITIALIZATION
  // ==========================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ==========================================================
  // SUPABASE INITIALIZATION
  // ==========================================================

  await Supabase.initialize(
    url: 'https://zlmokjoyhchgebqljrzz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsbW9ram95aGNoZ2VicWxqcnp6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkyMDAzMDYsImV4cCI6MjEwNDc3NjMwNn0.bkOAdYJC1EQ7YrHjJxIoBPXy2wheGsg2V-5hlNVvZcI',
  );

  // ==========================================================
  // LOAD SAVED LANGUAGE
  // ==========================================================

  final prefs = await SharedPreferences.getInstance();

  final savedLanguage =
      prefs.getString('languageCode') ?? 'en';

  // ==========================================================
  // START APPLICATION
  // ==========================================================

  runApp(
    OnionQualityApp(
      initialLocale: Locale(savedLanguage),
    ),
  );
}


// ============================================================
// MAIN APPLICATION
// ============================================================

class OnionQualityApp extends StatefulWidget {
  final Locale initialLocale;

  const OnionQualityApp({
    super.key,
    required this.initialLocale,
  });

  @override
  State<OnionQualityApp> createState() =>
      _OnionQualityAppState();
}


// ============================================================
// APPLICATION STATE
// ============================================================

class _OnionQualityAppState
    extends State<OnionQualityApp> {

  late Locale _locale;

  @override
  void initState() {
    super.initState();

    _locale = widget.initialLocale;
  }


  // ==========================================================
  // CHANGE LANGUAGE
  // ==========================================================

  Future<void> changeLanguage(
    String languageCode,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();

    // Save selected language
    await prefs.setString(
      'languageCode',
      languageCode,
    );

    // Change application language
    setState(() {
      _locale = Locale(languageCode);
    });
  }


  // ==========================================================
  // BUILD APPLICATION
  // ==========================================================

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      // ========================================================
      // BASIC APP SETTINGS
      // ========================================================

      debugShowCheckedModeBanner: false,

      title: 'Onion Quality Grading',


      // ========================================================
      // CURRENT LANGUAGE
      // ========================================================

      locale: _locale,


      // ========================================================
      // SUPPORTED LANGUAGES
      // ========================================================

      supportedLocales:
          AppLocalizations.supportedLocales,


      // ========================================================
      // LOCALIZATION DELEGATES
      // ========================================================

      localizationsDelegates: const [

        // Our custom translations
        AppLocalizations.delegate,

        // Flutter Material translations
        GlobalMaterialLocalizations.delegate,

        // Flutter widget translations
        GlobalWidgetsLocalizations.delegate,

        // Flutter Cupertino translations
        GlobalCupertinoLocalizations.delegate,
      ],


      // ========================================================
      // EXISTING THEME
      // ========================================================

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor:
              const Color(0xFF2E7D32),
        ),

        scaffoldBackgroundColor:
            const Color(0xFFF7F9F5),

        appBarTheme:
            const AppBarTheme(
          backgroundColor:
              Color(0xFF2E7D32),

          foregroundColor:
              Colors.white,

          elevation: 0,
        ),

        inputDecorationTheme:
            InputDecorationTheme(

          filled: true,

          fillColor:
              Colors.white,

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),

            borderSide:
                BorderSide.none,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),

            borderSide:
                BorderSide(
              color:
                  Colors.grey.shade300,
            ),
          ),

          focusedBorder:
              const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(
              Radius.circular(12),
            ),

            borderSide:
                BorderSide(
              color:
                  Color(0xFF2E7D32),

              width: 2,
            ),
          ),
        ),
      ),


      // ========================================================
      // IMPORTANT:
      // AUTHGATE REMAINS THE ROOT PAGE
      // ========================================================

      home: AuthGate(
        onLanguageChanged:
            changeLanguage,
      ),
    );
  }
}


// ============================================================
// AUTH GATE
// ============================================================
//
// This widget decides whether the user should see:
//
// 1. HomePage       → Logged in
// 2. WelcomePage    → Logged out
//
// Firebase authentication functionality is unchanged.
// ============================================================

class AuthGate extends StatelessWidget {

  final Future<void> Function(
    String languageCode,
  ) onLanguageChanged;


  const AuthGate({
    super.key,
    required this.onLanguageChanged,
  });


  @override
  Widget build(
    BuildContext context,
  ) {

    return StreamBuilder<
        firebase_auth.User?>(
      stream:
          firebase_auth.FirebaseAuth
              .instance
              .authStateChanges(),

      builder:
          (context, snapshot) {

        // ======================================================
        // FIREBASE IS CHECKING AUTHENTICATION
        // ======================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return const Scaffold(

            backgroundColor:
                Color(0xFFF7F9F5),

            body:
                Center(

              child:
                  CircularProgressIndicator(

                color:
                    Color(0xFF2E7D32),
              ),
            ),
          );
        }


        // ======================================================
        // AUTHENTICATION ERROR
        // ======================================================

        if (snapshot.hasError) {

          return const Scaffold(

            backgroundColor:
                Color(0xFFF7F9F5),

            body:
                Center(

              child:
                  Text(
                'Unable to check login status.',

                textAlign:
                    TextAlign.center,

                style:
                    TextStyle(
                  color:
                      Colors.red,

                  fontSize:
                      16,
                ),
              ),
            ),
          );
        }


        // ======================================================
        // USER IS LOGGED IN
        // ======================================================

        if (snapshot.data != null) {

          return HomePage(
            onLanguageChanged:
                onLanguageChanged,
          );
        }


        // ======================================================
        // USER IS LOGGED OUT
        // ======================================================

        return const WelcomePage();
      },
    );
  }
}
