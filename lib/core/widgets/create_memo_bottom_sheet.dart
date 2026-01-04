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
  _SheetMode _sheetMode = _SheetMode.memo;
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
    final sheetHeight = MediaQuery.of(context).size.height * 0.62;

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
          child: SizedBox(
            height: sheetHeight,
            child: Column(
              children: [
                _SheetHeader(
                  leadingLabel:
                      _sheetMode == _SheetMode.memo ? 'Cancel' : 'Back',
                  onLeadingTap: _sheetMode == _SheetMode.memo
                      ? () => Navigator.pop(context)
                      : _showMemoSheet,
                  title:
                      _sheetMode == _SheetMode.memo ? '新規メモ' : 'カテゴリ',
                  trailingLabel: _sheetMode == _SheetMode.memo ? 'Add' : null,
                  onTrailingTap: _sheetMode == _SheetMode.memo &&
                          _memoController.text.isNotEmpty
                      ? _onAdd
                      : null,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: _sheetMode == _SheetMode.memo
                        ? _MemoSheetContent(
                            key: const ValueKey('memo'),
                            memoController: _memoController,
                            repeatEnabled: _repeatEnabled,
                            onRepeatChanged: (v) =>
                                setState(() => _repeatEnabled = v),
                            category: _selectedCategory,
                            onCategoryTap: _showCategorySheet,
                          )
                        : _CategorySheetContent(
                            key: const ValueKey('category'),
                            categories: _categories,
                            selectedCategory: _selectedCategory,
                            onSelect: _selectCategory,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onAdd() {
    // TODO: ViewModel / Repository に委譲
    Navigator.pop(context);
  }

  void _showCategorySheet() {
    setState(() => _sheetMode = _SheetMode.category);
  }

  void _showMemoSheet() {
    setState(() => _sheetMode = _SheetMode.memo);
  }

  void _selectCategory(_CategoryItem category) {
    setState(() {
      _selectedCategory = category;
      _sheetMode = _SheetMode.memo;
    });
  }
}

class _MemoSheetContent extends StatelessWidget {
  final TextEditingController memoController;
  final bool repeatEnabled;
  final ValueChanged<bool> onRepeatChanged;
  final _CategoryItem category;
  final VoidCallback onCategoryTap;

  const _MemoSheetContent({
    super.key,
    required this.memoController,
    required this.repeatEnabled,
    required this.onRepeatChanged,
    required this.category,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Column(
        children: [
          _MemoInputCard(controller: memoController),
          const SizedBox(height: 12),
          _RepeatRow(
            value: repeatEnabled,
            onChanged: onRepeatChanged,
          ),
          const SizedBox(height: 12),
          _ListSelectRow(
            category: category,
            onTap: onCategoryTap,
          ),
        ],
      ),
    );
  }
}

class _CategorySheetContent extends StatelessWidget {
  final List<_CategoryItem> categories;
  final _CategoryItem selectedCategory;
  final ValueChanged<_CategoryItem> onSelect;

  const _CategorySheetContent({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryListTile(
                category: category,
                isSelected: category == selectedCategory,
                onTap: () => onSelect(category),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String leadingLabel;
  final VoidCallback onLeadingTap;
  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  const _SheetHeader({
    required this.leadingLabel,
    required this.onLeadingTap,
    required this.title,
    required this.trailingLabel,
    required this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFE6E5EF),
      ),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onLeadingTap,
            child: Text(
              leadingLabel,
              style: TextStyle(
                color: Color(0xFF0C79FE),
                fontSize: 17,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: trailingLabel == null
                ? null
                : Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onTrailingTap,
                      child: Text(
                        trailingLabel!,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: onTrailingTap == null
                              ? const Color(0xFFB6B6B9)
                              : const Color(0xFF0C79FE),
                        ),
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

enum _SheetMode { memo, category }
