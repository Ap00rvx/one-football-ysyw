
// Complete Schedule Dialog
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ysyw/model/schedule.dart';

class CompleteScheduleDialog extends StatefulWidget {
  final Schedule schedule;
  final Function(String? notes) onComplete;

  const CompleteScheduleDialog({
    super.key,
    required this.schedule,
    required this.onComplete,
  });

  @override
  State<CompleteScheduleDialog> createState() => _CompleteScheduleDialogState();
}

class _CompleteScheduleDialogState extends State<CompleteScheduleDialog> {
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete Schedule'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mark "${widget.schedule.title}" as completed?'),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Completion Notes (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onComplete(
              _notesController.text.isEmpty ? null : _notesController.text,
            );
            Navigator.pop(context);
          },
          child: const Text('Complete'),
        ),
      ],
    );
  }
}

// Cancel Schedule Dialog
class CancelScheduleDialog extends StatefulWidget {
  final Schedule schedule;
  final Function(String? reason) onCancel;

  const CancelScheduleDialog({
    super.key,
    required this.schedule,
    required this.onCancel,
  });

  @override
  State<CancelScheduleDialog> createState() => _CancelScheduleDialogState();
}

class _CancelScheduleDialogState extends State<CancelScheduleDialog> {
  final _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel Schedule'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cancel "${widget.schedule.title}"?'),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Cancellation Reason (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Keep'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onCancel(
              _reasonController.text.isEmpty ? null : _reasonController.text,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Cancel Schedule'),
        ),
      ],
    );
  }
}
