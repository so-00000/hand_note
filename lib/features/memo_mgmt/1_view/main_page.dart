import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  static const _bgColor = Color(0xFFE6E5EF);
  static const _cardColor = Color(0xFF373739);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildFilterArea(),
                    const SizedBox(height: 30),
                    _buildCategoryArea(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // =========================
  // Header
  // =========================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          Icon(Icons.more_horiz, color: Color(0xFF373739)),
        ],
      ),
    );
  }

  // =========================
  // Filter Area
  // =========================
  Widget _buildFilterArea() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFilterCard(
                iconBg: const Color(0xFF0C79FE),
                label: '今日',
                count: '0',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildFilterCard(
                iconBg: const Color(0xFFF14C3B),
                label: '繰り返し',
                count: '0',
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildFilterCard(
          iconBg: Colors.white,
          iconColor: _cardColor,
          label: 'すべて',
          count: '1',
        ),
      ],
    );
  }

  Widget _buildFilterCard({
    required Color iconBg,
    Color iconColor = Colors.white,
    required String label,
    required String count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: iconBg,
                  child: Icon(Icons.circle, size: 12, color: iconColor),
                ),
                Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Category Area
  // =========================
  Widget _buildCategoryArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            'カテゴリ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E2124),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildCategoryItem('買い物リスト', '1'),
        const SizedBox(height: 10),
        _buildCategoryItem('削除', '1'),
      ],
    );
  }

  Widget _buildCategoryItem(String title, String count) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFFFA032),
                child: Icon(Icons.list, color: _cardColor, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // Footer
  // =========================
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: _bgColor,
        border: Border(top: BorderSide(width: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E2124),
              shape: const StadiumBorder(),
            ),
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('メモを作成'),
          ),
          const Icon(Icons.settings),
        ],
      ),
    );
  }
}
