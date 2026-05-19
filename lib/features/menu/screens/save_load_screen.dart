import 'package:flutter/material.dart';
import 'package:tmatch/features/menu/widgets/save_slot_widget.dart';

class SaveLoadScreen extends StatefulWidget {
  final List<String> saves;
  final void Function(String name) onSave;
  final void Function(String name) onLoad;
  final void Function(String name) onDelete;
  final VoidCallback onRefresh;
  final void Function(String name)? onExport;
  final void Function(String json)? onImport;

  const SaveLoadScreen({
    super.key,
    required this.saves,
    required this.onSave,
    required this.onLoad,
    required this.onDelete,
    required this.onRefresh,
    this.onExport,
    this.onImport,
  });

  @override
  State<SaveLoadScreen> createState() => _SaveLoadScreenState();
}

class _SaveLoadScreenState extends State<SaveLoadScreen> {
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save / Load'),
        actions: [
          if (widget.onImport != null)
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Import save',
              onPressed: _showImportDialog,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: widget.onRefresh,
          ),
        ],
      ),
      body: widget.saves.isEmpty
          ? const Center(child: Text('No saves yet'))
          : ListView.builder(
              itemCount: widget.saves.length,
              itemBuilder: (context, index) {
                final saveName = widget.saves[index];
                return SaveSlotWidget(
                  saveName: saveName,
                  onLoad: () => _confirmLoad(saveName),
                  onDelete: () => _confirmDelete(saveName),
                  onExport: widget.onExport != null
                      ? () {
                          widget.onExport!(saveName);
                          _showSnackBar('Save exported');
                        }
                      : null,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSaveDialog,
        tooltip: 'Save current game',
        child: const Icon(Icons.save),
      ),
    );
  }

  void _showSaveDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save game'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Save name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                widget.onSave(name);
                Navigator.pop(context);
                _showSnackBar('Game saved');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmLoad(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load save'),
        content: Text('Load "$name"? Unsaved progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onLoad(name);
              Navigator.pop(context);
              _showSnackBar('Game loaded');
            },
            child: const Text('Load'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete save'),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(name);
              Navigator.pop(context);
              _showSnackBar('Save deleted');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import save'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Paste save JSON here'),
          maxLines: 8,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final json = controller.text.trim();
              if (json.isNotEmpty) {
                try {
                  widget.onImport?.call(json);
                  Navigator.pop(context);
                  _showSnackBar('Save imported');
                } catch (e) {
                  _showSnackBar('Import failed: invalid JSON');
                }
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}
