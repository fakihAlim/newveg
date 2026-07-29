import 'package:flutter/material.dart';

class CreateGroupDialog extends StatefulWidget {
  final Function(String name) onCreate;
  const CreateGroupDialog({super.key, required this.onCreate});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buat Grup Baru'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Nama Grup',
          hintText: 'Masukkan nama komunitas',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onCreate(_controller.text.trim());
              Navigator.of(context).pop();
            }
          },
          child: const Text('Buat'),
        )
      ],
    );
  }
}
