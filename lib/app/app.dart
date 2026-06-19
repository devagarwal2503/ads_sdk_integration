import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/dependency_injection.dart';
import '../features/ads/presentation/bloc/ad_bloc.dart';
import '../features/ads/presentation/pages/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdBloc>(
      create: (_) => sl<AdBloc>(),
      child: MaterialApp(
        title: 'Osmos Ads Integration',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF0097A7),
          scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        ),
        home: const HomePage(),
      ),
    );
  }
}
