import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ads_sdk_integration/features/ads/presentation/bloc/ad_bloc.dart';
import 'package:ads_sdk_integration/features/ads/presentation/bloc/ad_state.dart';
import 'package:ads_sdk_integration/features/ads/presentation/widgets/ad_status_card.dart';

class AdVerifierView extends StatelessWidget {
  const AdVerifierView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdBloc, AdState>(
      builder: (context, state) {
        if (state is AdLoaded) {
          return _buildDiagnosticsContent(context, state);
        } else {
          return _buildEmptyState(context, state);
        }
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AdState state) {
    String message =
        'Please load a display ad in the Simulator tab to activate tracking diagnostics.';
    if (state is AdLoading) {
      message = 'Ad session is loading... Please wait.';
    } else if (state is AdError) {
      message = 'Active ad session failed: ${state.message}';
    } else if (state is AdEmpty) {
      message = 'Ad session completed with empty response: ${state.message}';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Active Ad Session',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticsContent(BuildContext context, AdLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'AD SESSION DIAGNOSTICS',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          // Live status checkboxes
          AdStatusCard(
            impressionTracked: state.impressionTracked,
            clickTracked: state.clickTracked,
            uclid: state.ad.uclid,
          ),

          const SizedBox(height: 20),
          const Text(
            'SDK ANALYTICS DATA',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          _buildInfoTile(
            title: 'Image URL',
            value: state.ad.imageUrl,
            icon: Icons.image_outlined,
          ),
          const SizedBox(height: 12),
          _buildInfoTile(
            title: 'Target Landing Page',
            value: state.ad.destinationUrl,
            icon: Icons.launch_outlined,
          ),
          const SizedBox(height: 12),
          _buildInfoTile(
            title: 'Impression Request URL (SDK & Direct Ping)',
            value: state.ad.impressionTrackingUrl ?? 'Not specified by SDK',
            icon: Icons.visibility_outlined,
          ),
          const SizedBox(height: 12),
          _buildInfoTile(
            title: 'Click Request URL (SDK & Direct Ping)',
            value: state.ad.clickTrackingUrl ?? 'Not specified by SDK',
            icon: Icons.mouse_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161626),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0097A7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
