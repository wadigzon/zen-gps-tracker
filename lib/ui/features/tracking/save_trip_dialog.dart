import 'package:flutter/material.dart';
import '../../core/zen_colors.dart';

/// Modal dialog allowing user to enter trip title and optional notes before saving.
class SaveTripDialog extends StatefulWidget {
  final String defaultTitle;
  final Function(String title, String? description) onSave;

  const SaveTripDialog({
    super.key,
    required this.defaultTitle,
    required this.onSave,
  });

  @override
  State<SaveTripDialog> createState() => _SaveTripDialogState();
}

class _SaveTripDialogState extends State<SaveTripDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.defaultTitle);
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ZenColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.save_rounded, color: ZenColors.emeraldPrimary),
          SizedBox(width: 10),
          Text(
            'Save Your Trip',
            style: TextStyle(color: ZenColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRIP TITLE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: ZenColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: ZenColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: ZenColors.background,
              hintText: 'e.g., Yosemite Waterfall Hike',
              hintStyle: const TextStyle(color: ZenColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'NOTES / DESCRIPTION (OPTIONAL)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: ZenColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _descController,
            maxLines: 2,
            style: const TextStyle(color: ZenColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: ZenColors.background,
              hintText: 'Weather, trail conditions, or memories...',
              hintStyle: const TextStyle(color: ZenColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: ZenColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final desc = _descController.text.trim();
            widget.onSave(title, desc.isEmpty ? null : desc);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ZenColors.emeraldPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save Trip', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
