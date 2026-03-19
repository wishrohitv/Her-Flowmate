import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/storage_service.dart';
import 'services/prediction_service.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final storageService = StorageService();
    await storageService.init();

    final notificationService = NotificationService();
    await notificationService.init();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
          ProxyProvider<StorageService, PredictionService>(
            update: (_, storage, __) => PredictionService(storage),
          ),
        ],
        child: const HerFlowmateApp(),
      ),
    );
  } catch (e) {
    debugPrint('FATAL ERROR DURING STARTUP: $e');
  }
}

class HerFlowmateApp extends StatelessWidget {
  const HerFlowmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storage, child) {
        return MaterialApp(
          title: 'HerFlowmate',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.accentPink,
              primary: AppTheme.accentPink,
              secondary: AppTheme.accentPink,
              surface: AppTheme.frameColor,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.outfitTextTheme(),
            scaffoldBackgroundColor: AppTheme.frameColor,
          ),
          home: storage.hasCompletedOnboarding || storage.hasCompletedLogin
              ? const MainNavigationScreen()
              : const LoginScreen(),
        );
      },
    );
  }
}
