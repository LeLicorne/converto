import 'package:converto/core/theme.dart';
import 'package:converto/features/home/home_page.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ConvertoApp extends StatelessWidget {
  const ConvertoApp({this.locale, super.key});

  final Locale? locale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appName,
    debugShowCheckedModeBanner: false,
    locale: locale,
    theme: buildTheme(Brightness.light),
    darkTheme: buildTheme(Brightness.dark),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const HomePage(),
  );
}
