// main.dart - Update your main.dart
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/data/provider/localProvider.dart';
import 'package:aiims_heartcare/l10n/app_localizations.dart';
import 'package:aiims_heartcare/local/preference.dart';
import 'package:aiims_heartcare/pages/NotificationPermission.dart';
import 'package:aiims_heartcare/pages/NotificationService/NotificationService.dart';
import 'package:aiims_heartcare/pages/SplashScreen.dart';
import 'package:aiims_heartcare/service/NotificationsService.dart';
import 'package:aiims_heartcare/utils/dependency_injection.dart';
import 'package:aiims_heartcare/utils/user_sessions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.init();

  await initHive();
  await Preference.initialize();
  setupDependencyInjections();

  final NotificationService notificationService = NotificationService();
  await notificationService.initialize(); 
  await requestNotificationPermission(); 
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        Provider<NotificationService>(create: (_) => notificationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Consumer<LocaleProvider>(
      builder: (context, provider, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>(
              create: (context) => HomeBloc(LoginState(ApiStatus.INITIAL)),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Hriday Sathi',
            // Use the global navigator key
            navigatorKey: MedicationReminderService.navigatorKey,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('hi', ''),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              primarySwatch: Colors.green,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: SplashScreen(),
          ),
        );
      },
    );
  }
}

Future<void> initHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox(DB.CONTENT);
}

class DB {
  static const String CONTENT = 'content';
}