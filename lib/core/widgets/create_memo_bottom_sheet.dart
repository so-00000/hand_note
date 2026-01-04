import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateMemoBottomSheet extends StatefulWidget {
  const CreateMemoBottomSheet({super.key});

  @override
  State<CreateMemoBottomSheet> createState() =>
      _CreateMemoBottomSheetState();
}

class _CreateMemoBottomSheetState extends State<CreateMemoBottomSheet> {
  final TextEditingController _memoController = TextEditingController();
  bool _repeatEnabled = false;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF2F2F6),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(
                onCancel: () => Navigator.pop(context),
                onAdd: _memoController.text.isEmpty ? null : _onAdd,
              ),

              const SizedBox(height: 12),

              _MemoInputCard(controller: _memoController),

              const SizedBox(height: 12),

              _RepeatRow(
                value: _repeatEnabled,
                onChanged: (v) => setState(() => _repeatEnabled = v),
              ),

              const SizedBox(height: 12),

              const _ListSelectRow(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _onAdd() {
    // TODO: ViewModel / Repository に委譲
    Navigator.pop(context);
  }
}


class _Header extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onAdd;

  const _Header({
    required this.onCancel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFE6E5EF),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF0C79FE),
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const Text(
            '新規メモ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onAdd,
              child: Text(
                'Add',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: onAdd == null
                      ? const Color(0xFFB6B6B9)
                      : const Color(0xFF0C79FE),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _MemoInputCard extends StatelessWidget {
  final TextEditingController controller;

  const _MemoInputCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(fontSize: 17),
        decoration: const InputDecoration(
          hintText: 'メモ',
          border: InputBorder.none,
        ),
      ),
    );
  }
}


class _RepeatRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _RepeatRow({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingRow(
      iconColor: const Color(0xFFF14C3B),
      title: 'Repeat',
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _ListSelectRow extends StatelessWidget {
  const _ListSelectRow();

  @override
  Widget build(BuildContext context) {
    return _SettingRow(
      title: 'List',
      trailing: Row(
        children: const [
          CircleAvatar(radius: 4, backgroundColor: Color(0xFFFFA032)),
          SizedBox(width: 6),
          Text(
            'Reminders',
            style: TextStyle(color: Color(0xFF8E8E92)),
          ),
          SizedBox(width: 6),
          Icon(Icons.chevron_right, color: Color(0xFFB6B6B9)),
        ],
      ),
    );
  }
}


class _SettingRow extends StatelessWidget {
  final String title;
  final Widget trailing;
  final Color? iconColor;

  const _SettingRow({
    required this.title,
    required this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (iconColor != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 17),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}