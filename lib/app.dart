import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';

class IkibinaApp extends StatelessWidget {
  const IkibinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ikibina',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRoutes.router,
    );
  }
}
