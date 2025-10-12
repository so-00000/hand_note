import 'package:flutter/material.dart';

/// 画面上部の共通ヘッダー

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          // Text(
          //   'Notes',
          //   style: TextStyle(
          //     color: Colors.white,
          //     fontSize: 20,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
          // Icon(Icons.more_vert, color: Colors.white),
        ],
      ),
    );
  }
}