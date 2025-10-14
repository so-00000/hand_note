import 'package:flutter/material.dart';

class BottomTabBar extends StatelessWidget {
  final Function(int) onTabSelected;
  final int currentIndex;

  const BottomTabBar({
    super.key,
    required this.onTabSelected,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(color: Color(0xFF1C1C1E)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // ✏️ 鉛筆アイコン（メモ作成）
            _TabButton(
              icon: Icons.edit_outlined,
              isActive: currentIndex == 0,
              onTap: () => onTabSelected(0),
            ),


            // 📋 リストアイコン（一覧）
            _TabButton(
              icon: Icons.list_alt_outlined,
              isActive: currentIndex == 1,
              onTap: () => onTabSelected(1),
            ),

            // ⚙️ 歯車（設定）
            _TabButton(
              icon: Icons.settings_outlined,
              isActive: currentIndex == 2,
              onTap: () => onTabSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(46),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
