import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/journal_provider.dart';
import 'providers/breathing_provider.dart';
import 'screens/home_screen.dart';
import 'screens/record_screen.dart';
import 'screens/journal_success_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => BreathingProvider()),
      ],
      child: MaterialApp(
        title: 'NUMA',
        theme: AppTheme.lightTheme(),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              );
            case '/record':
              return MaterialPageRoute(
                builder: (_) => const RecordScreen(),
              );
            case '/journal-success':
              final String entryId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => JournalSuccessScreen(entryId: entryId),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ),
              );
          }
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
