import 'package:flutter/material.dart';

import '../../../../core/ui/styles/box_decorations.dart';

class MemoSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const MemoSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: textBoxDecoration(theme),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            icon: Icon(Icons.search, color: Colors.white54),
            hintText: 'Search',
            hintStyle: TextStyle(color: Color(0x99EBEBF5)),
            border: InputBorder.none,
          ),
          onChanged: onSearch,
        ),
      ),
    );
  }
}
