import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'app/theme/color_palette.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Status & Navigation Bar aesthetics
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: ColorPalette.obsidianBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Dependency Injection
  await configureDependencies();

  runApp(const NexoraApp());
}
