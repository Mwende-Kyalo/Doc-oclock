import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/ehr_provider.dart';
import 'providers/settings_provider.dart';

// Routing & Theme
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://lxisvhpacxttccezuyhb.supabase.co',
    anonKey: 'sb_publishable_kG2hecr9jyery2FtCdiTLQ_QHVoo9oI',
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
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
