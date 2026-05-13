import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'app/router.dart';
import 'data/providers/service_providers.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAsync = ref.watch(firebaseInitializerProvider);

    return firebaseAsync.when(
      data: (_) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          title: 'Aemo Loans',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        );
      },
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (err, stack) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize: $err'),
          ),
        ),
      ),
    );
  }
}
