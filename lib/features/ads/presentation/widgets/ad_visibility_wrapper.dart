import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A wrapper widget that tracks the on-screen visibility fraction of its child component.
///
/// Triggers the [onImpression] callback exactly once when the visibility fraction crosses
/// the 50% threshold ([visibleFraction] >= 0.5), as required by ads visibility guidelines.
class AdVisibilityWrapper extends StatefulWidget {
  final Widget child;

  /// Callback to execute when the impression condition is met.
  final VoidCallback onImpression;

  /// Unique identifier of the advertisement currently rendered.
  final String adId;

  const AdVisibilityWrapper({
    super.key,
    required this.child,
    required this.onImpression,
    required this.adId,
  });

  @override
  State<AdVisibilityWrapper> createState() => _AdVisibilityWrapperState();
}

class _AdVisibilityWrapperState extends State<AdVisibilityWrapper> {
  /// Session lock flag preventing multiple impressions from firing for the same ad object.
  bool _impressionFired = false;

  @override
  void didUpdateWidget(covariant AdVisibilityWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset the session lock if the widget is rebuilt with a different ad identifier
    if (oldWidget.adId != widget.adId) {
      _impressionFired = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('ad_visibility_${widget.adId}'),
      onVisibilityChanged: (info) {
        // Enforce the 50% threshold visibility check exactly once per ad session
        if (!_impressionFired && info.visibleFraction >= 0.5) {
          _impressionFired = true;
          widget.onImpression();
        }
      },
      child: widget.child,
    );
  }
}
