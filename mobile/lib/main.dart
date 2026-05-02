import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage (used for case drafts)
  await Hive.initFlutter();
  // await Hive.openBox('case_drafts');

  runApp(
    const ProviderScope(
      child: DentIDApp(),
    ),
  );
}

class DentIDApp extends StatelessWidget {
  const DentIDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Forensodont Multimodal OPG Intelligence',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
