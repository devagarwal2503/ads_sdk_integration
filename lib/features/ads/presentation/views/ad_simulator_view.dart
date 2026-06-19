import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ads_sdk_integration/features/ads/presentation/bloc/ad_bloc.dart';
import 'package:ads_sdk_integration/features/ads/presentation/bloc/ad_event.dart';
import 'package:ads_sdk_integration/features/ads/presentation/bloc/ad_state.dart';
import 'package:ads_sdk_integration/features/ads/presentation/widgets/banner_ad_widget.dart';
import 'package:ads_sdk_integration/features/ads/presentation/widgets/load_button.dart';
import 'package:ads_sdk_integration/features/ads/presentation/widgets/loading_indicator.dart';

class AdSimulatorView extends StatelessWidget {
  const AdSimulatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Demo showcasing API-driven display banner ads, visibility-based impression triggers (50%+), and click attribution.',
            style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161626),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              clipBehavior: Clip.antiAlias,
              child: BlocBuilder<AdBloc, AdState>(
                builder: (context, state) {
                  if (state is AdInitial) {
                    return _buildInitialState(context);
                  } else if (state is AdLoading) {
                    return const LoadingIndicator();
                  } else if (state is AdLoaded) {
                    return _buildLoadedState(context, state);
                  } else if (state is AdEmpty) {
                    return _buildEmptyState(context, state.message);
                  } else if (state is AdError) {
                    return _buildErrorState(context, state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.ads_click, size: 56, color: Colors.white30),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ready to Load Ad',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Click below to fetch the banner ad.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 24),
          LoadButton(
            label: 'Load Display Ad',
            icon: Icons.cloud_download_outlined,
            onPressed: () {
              context.read<AdBloc>().add(LoadBannerAd());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDummyArticleCard({
    required String title,
    required String snippet,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            snippet,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, AdLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'DEMO FEED CONTENT (SCROLL DOWN)',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildDummyArticleCard(
            title: 'Exploring Clean Architecture in Flutter',
            snippet:
                'Discover how isolating domain, data, and presentation layers leads to highly maintainable, testable, and robust codebases in large-scale mobile apps...',
          ),
          const SizedBox(height: 12),
          _buildDummyArticleCard(
            title: 'State Management with BLoC',
            snippet:
                'A deep dive into event-driven state transitions, asynchronous streams, and reactive UI elements to separate business logic from rendering code...',
          ),
          const SizedBox(height: 12),
          _buildDummyArticleCard(
            title: 'Testing Flutter Applications',
            snippet:
                'Learn how to write unit, widget, and integration tests to verify functionality and prevent code regressions during fast iteration cycles...',
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          const Text(
            'SPONSORED ADVERTISEMENT',
            style: TextStyle(
              color: Color(0xFF0097A7),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          BannerAdWidget(
            ad: state.ad,
            onImpression: () {
              context.read<AdBloc>().add(ImpressionDetected());
            },
            onAdClick: () {
              context.read<AdBloc>().add(BannerClicked());
            },
          ),
          const SizedBox(height: 32),
          _buildDummyArticleCard(
            title: 'Responsive Layouts in Flutter',
            snippet:
                'Best practices for handling overflows, adapting sizes, and supporting multiple screen profiles...',
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () {
                context.read<AdBloc>().add(ResetBanner());
              },
              icon: const Icon(
                Icons.refresh,
                color: Color(0xFF0097A7),
                size: 20,
              ),
              label: const Text(
                'Reset & Load Another',
                style: TextStyle(
                  color: Color(0xFF0097A7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_empty, size: 56, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'No Ads Available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LoadButton(
              label: 'Retry Fetch',
              icon: Icons.refresh,
              onPressed: () {
                context.read<AdBloc>().add(RetryLoadingAd());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Ad Loading Failed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LoadButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: () {
                context.read<AdBloc>().add(RetryLoadingAd());
              },
            ),
          ],
        ),
      ),
    );
  }
}
