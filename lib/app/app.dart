import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'router.dart';
import 'theme.dart';
import '../core/providers.dart';
import '../l10n/app_localizations.dart';

class CoopApp extends ConsumerWidget {
  const CoopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final locale = language == 'bn' ? const Locale('bn') : const Locale('en');
    final bengali = locale.languageCode == 'bn';
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(bengali: bengali),
      darkTheme: AppTheme.dark(bengali: bengali),
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('bn'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // Check if device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == deviceLocale?.languageCode) {
            return supportedLocale;
          }
        }
        // Fallback to English
        return const Locale('en');
      },
    );
  }
}

class HeaderWithImage extends StatelessWidget {
  const HeaderWithImage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Adjust height to make the image fully visible
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/dollar.png'),
          fit: BoxFit.cover, // Ensure the image covers the entire header
        ),
      ),
      child: AppBar(
        backgroundColor:
            Colors.transparent, // Make AppBar background transparent
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text(
          'Coop App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black,
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0, // Remove shadow from AppBar
      ),
    );
  }
}

// Replace the MaterialApp.router with this widget to test the header
// Example: return HeaderWithImage();
