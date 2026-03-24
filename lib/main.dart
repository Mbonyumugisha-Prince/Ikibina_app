import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/group_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: const IkibinaApp(),
    ),
  );
}

class IkibinaApp extends StatelessWidget {
  const IkibinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch LocaleProvider to trigger rebuilds when language changes
    // (even though we keep MaterialApp locale as English)
    context.watch<LocaleProvider>();
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ikibina',
      // Keep Material widgets in English (built-in Material localizations)
      // Custom app strings come from LocaleProvider.strings instead
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(primarySwatch: Colors.grey),
      home: const SplashScreen(),
    );
  }
}
