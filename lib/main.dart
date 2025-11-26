import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/app_localizations.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/ehr_provider.dart';
import 'providers/prescription_provider.dart';
import 'providers/settings_provider.dart';

// Routing & Theme
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

// Configuration
import 'config/api_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: ApiConfig.supabaseUrl,
    anonKey: ApiConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => EhrProvider()),
        ChangeNotifierProvider(create: (_) => PrescriptionProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Doc Oclock',
            theme: AppTheme.getTheme(
              isDarkMode: settingsProvider.isDarkMode,
              fontSize: settingsProvider.fontSize,
            ),
            locale: settingsProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [
              Locale('en'), // English
              Locale('sw'), // Swahili
            ],
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
