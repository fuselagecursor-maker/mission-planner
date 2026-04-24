import 'package:flutter/material.dart';

/// UI-only shells for Save/Load mission actions (SRS FR-05).
///
/// Future:
/// - Replace with real persistence (local DB + cloud sync) and mission versioning.
Future<void> showSaveMissionDialog(BuildContext context) {
  final name = TextEditingController(text: 'Mission_${DateTime.now().millisecondsSinceEpoch}');
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Save Mission'),
      content: TextField(
        controller: name,
        decoration: const InputDecoration(
          labelText: 'Filename',
          hintText: 'e.g., Recon_Alpha_v1',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Saved: ${name.text} (placeholder)')),
            );
          },
          child: const Text('Save'),
        ),
      ],
    ),
  ).whenComplete(name.dispose);
}

Future<void> showLoadMissionDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Load Mission'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: const [
            ListTile(
              leading: Icon(Icons.folder_outlined),
              title: Text('Recon_Alpha_v1'),
              subtitle: Text('Saved: --'),
            ),
            ListTile(
              leading: Icon(Icons.folder_outlined),
              title: Text('Supply_Drop_v2'),
              subtitle: Text('Saved: --'),
            ),
            ListTile(
              leading: Icon(Icons.folder_outlined),
              title: Text('Perimeter_Patrol'),
              subtitle: Text('Saved: --'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loaded mission (placeholder)')),
            );
          },
          child: const Text('Load selected'),
        ),
      ],
    ),
  );
}

