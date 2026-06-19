import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ad_bloc.dart';
import '../bloc/ad_event.dart';
import '../views/ad_simulator_view.dart';
import '../views/ad_verifier_view.dart';
import '../views/console_logs_view.dart';

/// The root navigation shell of the advertisement integration demo.
/// Coordinates the bottom navigation bar and switches views without destroying states.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Currently active index representing the selected tab.
  int _currentIndex = 0;

  /// Ordered list of views hosted within the navigation stack.
  final List<Widget> _views = const [
    AdSimulatorView(),
    AdVerifierView(),
    ConsoleLogsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text(
          'OSMOS ADS INTEGRATION',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161626),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              context.read<AdBloc>().add(ResetBanner());
            },
            tooltip: 'Reset State',
          ),
        ],
      ),
      body: SafeArea(
        // IndexedStack preserves the scroll position and data inputs of other tabs
        // when the user toggles between the simulator, diagnostics, and log console.
        child: IndexedStack(index: _currentIndex, children: _views),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF111122),
          selectedItemColor: const Color(0xFF0097A7),
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.normal,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.ads_click),
              activeIcon: Icon(Icons.ads_click, color: Color(0xFF0097A7)),
              label: 'Ad Simulator',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(
                Icons.analytics_outlined,
                color: Color(0xFF0097A7),
              ),
              label: 'Ad Verifier',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.terminal),
              activeIcon: Icon(Icons.terminal, color: Color(0xFF0097A7)),
              label: 'Event Console',
            ),
          ],
        ),
      ),
    );
  }
}
