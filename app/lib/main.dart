import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/app_router_provider.dart';
import 'core/services/demo_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('No .env file found, running in demo mode');
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Supabase (or demo mode)
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  final hasValidSupabase = supabaseUrl != null &&
      supabaseAnonKey != null &&
      !supabaseUrl.contains('your-project') &&
      supabaseUrl.startsWith('https://');

  if (hasValidSupabase) {
    await Supabase.initialize(
      url: supabaseUrl!,
      anonKey: supabaseAnonKey!,
    );
  } else {
    debugPrint('⚠️ No valid Supabase credentials - running in DEMO MODE');
    demoMode.activate();
  }

  // Set preferred orientations (only on mobile)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  runApp(
    const ProviderScope(
      child: WemakeApp(),
    ),
  );
}

class WemakeApp extends ConsumerWidget {
  const WemakeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'WEMAKE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
