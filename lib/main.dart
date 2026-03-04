import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/tappy_wizard_game.dart';
import 'services/score_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Immersive mode & Portrait lock
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Init services
  final scoreService = ScoreService();
  await scoreService.init();

  final settingsService = SettingsService();
  await settingsService.init();

  runApp(
    TappyWizardApp(
      scoreService: scoreService,
      settingsService: settingsService,
    ),
  );
}

class TappyWizardApp extends StatelessWidget {
  final ScoreService scoreService;
  final SettingsService settingsService;

  const TappyWizardApp({
    super.key,
    required this.scoreService,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tappy Wizard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: TappyWizardGame(
          scoreService: scoreService,
          settingsService: settingsService,
        ),
      ),
    );
  }
}
