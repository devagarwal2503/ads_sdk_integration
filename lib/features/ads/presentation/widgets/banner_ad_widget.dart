import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/ad_entity.dart';
import 'ad_visibility_wrapper.dart';

/// Interactive UI component that renders the network ad image within a specific lock-ratio box.
/// Wraps elements in a visibility checker to automate impression reporting.
class BannerAdWidget extends StatelessWidget {
  /// The business entity representing the active display advertisement.
  final AdEntity ad;

  /// Callback to execute once 50% visibility is reached.
  final VoidCallback onImpression;

  /// Callback to execute when the user taps on the ad banner.
  final VoidCallback onAdClick;

  const BannerAdWidget({
    super.key,
    required this.ad,
    required this.onImpression,
    required this.onAdClick,
  });

  /// Opens the advertisement's destination target in the device's default web browser application.
  ///
  /// Employs robust fallbacks to bypass potential Android 11+ package queries visibility restrictions.
  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.parse(ad.destinationUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        onAdClick();
      } else {
        // Try directly launching if package queries are restricted on Android 11+
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          onAdClick();
          return;
        } catch (_) {}

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch ${ad.destinationUrl}')),
          );
        }
      }
    } catch (_) {
      // Trigger click and launch default browser if any other errors occur
      onAdClick();
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically calculate aspect ratio from ad metadata to avoid stretching images.
    // Defaults to 16:9 if dimensions are missing or invalid.
    final double ratio =
        (ad.width != null && ad.height != null && ad.height! > 0)
        ? (ad.width! / ad.height!)
        : (16 / 9);

    return AdVisibilityWrapper(
      adId: ad.imageUrl,
      onImpression: onImpression,
      child: GestureDetector(
        onTap: () => _launchUrl(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: ratio,
              child: CachedNetworkImage(
                imageUrl: ad.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0097A7)),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[850],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 48,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ad image failed to load',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
