import 'package:flutter/material.dart';
import '../../core/glass_card.dart';
import '../../core/zen_colors.dart';
import '../../view_models/tracking_view_model.dart';

/// Interactive trip control panel featuring Start, Pause, Resume, Stop, and Save actions.
class ControlsPanel extends StatelessWidget {
  final TrackingState state;
  final bool isSimulating;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final ValueChanged<bool> onToggleSimulation;

  const ControlsPanel({
    super.key,
    required this.state,
    required this.isSimulating,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onSave,
    required this.onDiscard,
    required this.onToggleSimulation,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Simulation / Demo Mode Toggle (when idle)
          if (state == TrackingState.idle)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.directions_walk_outlined,
                        size: 16,
                        color: isSimulating ? ZenColors.cyanAccent : ZenColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Demo GPS Simulator Mode',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSimulating ? ZenColors.textPrimary : ZenColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isSimulating,
                      activeColor: ZenColors.cyanAccent,
                      onChanged: onToggleSimulation,
                    ),
                  ),
                ],
              ),
            ),

          // Main Action Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state == TrackingState.idle) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: const Text(
                      'START RECORDING',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZenColors.emeraldPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                  ),
                ),
              ] else if (state == TrackingState.recording) ...[
                // Pause Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPause,
                    icon: const Icon(Icons.pause_rounded, size: 24),
                    label: const Text('PAUSE', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZenColors.amberPause,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Stop Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStop,
                    icon: const Icon(Icons.stop_rounded, size: 24),
                    label: const Text('STOP', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZenColors.roseStop,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ] else if (state == TrackingState.paused) ...[
                // Resume Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow_rounded, size: 24),
                    label: const Text('RESUME', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZenColors.emeraldPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Stop Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStop,
                    icon: const Icon(Icons.stop_rounded, size: 24),
                    label: const Text('STOP', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZenColors.roseStop,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ] else if (state == TrackingState.stopped) ...[
                // Discard Button
                OutlinedButton.icon(
                  onPressed: onDiscard,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: const Text('DISCARD'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ZenColors.roseStop,
                    side: const BorderSide(color: ZenColors.roseStop),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(width: 12),
                // Save Trip Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.save_alt_rounded, size: 22),
                    label: const Text('SAVE & EXPORT', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZenColors.emeraldPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
