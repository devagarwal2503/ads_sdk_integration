import 'package:flutter/material.dart';

/// Diagnostics component that visually represents the active tracking status of an advertisement.
/// Displays checkboxes for visibility impressions (50%+) and link clicks in real-time.
class AdStatusCard extends StatelessWidget {
  /// True if the 50% visibility threshold was crossed and recorded.
  final bool impressionTracked;

  /// True if the ad link click was triggered.
  final bool clickTracked;

  /// Unique click/impression token identifier.
  final String uclid;

  const AdStatusCard({
    super.key,
    required this.impressionTracked,
    required this.clickTracked,
    required this.uclid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF0097A7),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Ad Tracking Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'UCLID: $uclid',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(color: Colors.white10, height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  label: 'Impression',
                  description: '50%+ visible',
                  status: impressionTracked,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusItem(
                  label: 'Click',
                  description: 'Destination URL',
                  status: clickTracked,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper to render a status item indicator for tracking indicators.
  Widget _buildStatusItem({
    required String label,
    required String description,
    required bool status,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: status
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.white24.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status ? Colors.green.withValues(alpha: 0.3) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: status ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: status ? Colors.green : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white30, fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
