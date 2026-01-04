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
  final List<_CategoryItem> _categories = const [
    _CategoryItem(name: 'Reminders', color: Color(0xFFFFA032)),
    _CategoryItem(name: 'Work', color: Color(0xFF3B82F6)),
    _CategoryItem(name: 'Personal', color: Color(0xFF10B981)),
    _CategoryItem(name: 'Ideas', color: Color(0xFF8B5CF6)),
    _CategoryItem(name: 'Archive', color: Color(0xFF9CA3AF)),
  ];
  late _CategoryItem _selectedCategory = _categories.first;

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

              _ListSelectRow(
                category: _selectedCategory,
                onTap: _showCategorySheet,
              ),

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

  Future<void> _showCategorySheet() async {
    final selected = await showGeneralDialog<_CategoryItem>(
      context: context,
      barrierLabel: 'Category',
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.white,
            child: SafeArea(
              left: false,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.78,
                child: _CategorySelectSheet(
                  categories: _categories,
                  selected: _selectedCategory,
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );

    if (selected != null && selected != _selectedCategory) {
      setState(() => _selectedCategory = selected);
    }
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
  final _CategoryItem category;
  final VoidCallback onTap;

  const _ListSelectRow({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingRow(
      title: 'List',
      onTap: onTap,
      trailing: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: category.color),
          const SizedBox(width: 6),
          Text(
            category.name,
            style: const TextStyle(color: Color(0xFF8E8E92)),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Color(0xFFB6B6B9)),
        ],
      ),
    );
  }
}

class _CategorySelectSheet extends StatelessWidget {
  final List<_CategoryItem> categories;
  final _CategoryItem selected;

  const _CategorySelectSheet({
    required this.categories,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFFE6E5EF),
          ),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF0C79FE),
                    fontSize: 17,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'カテゴリ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 56),
            ],
          ),
        ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryListTile(
                category: category,
                isSelected: category == selected,
                onTap: () => Navigator.pop(context, category),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  final _CategoryItem category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryListTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(radius: 6, backgroundColor: category.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check,
                    color: Color(0xFF0C79FE),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _CategoryItem {
  final String name;
  final Color color;

  const _CategoryItem({
    required this.name,
    required this.color,
  });
}


class _SettingRow extends StatelessWidget {
  final String title;
  final Widget trailing;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.title,
    required this.trailing,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
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

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
