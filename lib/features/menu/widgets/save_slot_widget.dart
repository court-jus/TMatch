import 'package:flutter/material.dart';

class SaveSlotWidget extends StatelessWidget {
  final String saveName;
  final VoidCallback onLoad;
  final VoidCallback onDelete;
  final VoidCallback? onExport;

  const SaveSlotWidget({
    super.key,
    required this.saveName,
    required this.onLoad,
    required this.onDelete,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.save_outlined),
        title: Text(saveName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.file_upload_outlined),
              tooltip: 'Load',
              onPressed: onLoad,
            ),
            if (onExport != null)
              IconButton(
                icon: const Icon(Icons.file_copy_outlined),
                tooltip: 'Export',
                onPressed: onExport,
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
