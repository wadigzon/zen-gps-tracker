import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data/services/location_service.dart';
import 'data/services/storage_service.dart';
import 'ui/core/zen_colors.dart';
import 'ui/features/tracking/tracking_screen.dart';
import 'ui/view_models/history_view_model.dart';
import 'ui/view_models/settings_view_model.dart';
import 'ui/view_models/tracking_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent dark system navigation bars for immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: ZenColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ZenGpsApp());
}

class ZenGpsApp extends StatelessWidget {
  const ZenGpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();
    final storageService = StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(
          create: (_) => TrackingViewModel(
            locationService: locationService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryViewModel(
            storageService: storageService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Zen GPS Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: ZenColors.background,
          colorScheme: const ColorScheme.dark(
            primary: ZenColors.emeraldPrimary,
            secondary: ZenColors.cyanAccent,
            surface: ZenColors.surface,
          ),
          fontFamily: 'Roboto',
        ),
        home: const TrackingScreen(),
      ),
    );
  }
}
