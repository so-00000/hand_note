import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF373739),
          borderRadius: BorderRadius.circular(10),
        ),
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
