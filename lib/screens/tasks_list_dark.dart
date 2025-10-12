import 'package:flutter/material.dart';
import '../models/memo.dart';
import '../services/memo_service.dart';
import '../widgets/memo_search_bar.dart';
import '../widgets/editable_task_card.dart';
import '../db/database_helper.dart';
import '../constants/status_color_mapper.dart';
import '../constants/status_codes.dart'; // 固定ステータスコード(01,02)用

/// 📋 メモ一覧画面（ダークモード）
class TasksListDark extends StatefulWidget {
  const TasksListDark({super.key});

  @override
  State<TasksListDark> createState() => _TasksListDarkState();
}

class _TasksListDarkState extends State<TasksListDark> {
  final TextEditingController _searchController = TextEditingController();
  final MemoService _memoService = MemoService();

  List<Memo> _memos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  /// 🟢 全メモ読込
  Future<void> _loadMemos() async {
    final memos = await _memoService.fetchAllMemos();
    setState(() {
      _memos = memos;
      _isLoading = false;
    });
  }

  /// ✏️ 内容更新
  Future<void> _updateMemoContent(Memo memo, String newContent) async {
    final updated = memo.copyWith(content: newContent);
    await _memoService.updateMemo(updated);
    await _loadMemos();
  }

  /// 🔁 ステータス更新
  Future<void> _updateStatus(int memoId, int newStatusId) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'memos',
      {'status_id': newStatusId},
      where: 'id = ?',
      whereArgs: [memoId],
    );
    await _loadMemos();
  }

  /// 🟢 タップで未完了⇄完了トグル
  Future<void> _toggleStatus(Memo memo) async {
    final newStatusId =
    (memo.statusId == 2) ? 1 : 2; // 2:未完了 → 1:完了 → 戻す
    await _updateStatus(memo.id!, newStatusId);
  }

  /// 🟣 長押しで全ステータス選択モーダル
  Future<void> _showStatusSelectDialog(Memo memo) async {
    final db = await DatabaseHelper.instance.database;
    final statuses = await db.query('status', orderBy: 'id ASC');

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: statuses.map((s) {
              final colorCode = s['color_code']?.toString() ?? '08';
              final color = getStatusColor(colorCode);
              final isFixed = isFixedStatus(colorCode);

              return GestureDetector(
                onTap: isFixed
                    ? null // 固定ステータスは選択無効
                    : () async {
                  await _updateStatus(memo.id!, s['id'] as int);
                  Navigator.pop(context);
                },
                child: Opacity(
                  opacity: isFixed ? 0.4 : 1.0,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }



  /// ❌ メモ削除 + Undo対応
  Future<void> _deleteMemo(BuildContext context, Memo memo) async {
    await _memoService.deleteMemo(memo.id!);
    setState(() {
      _memos.removeWhere((m) => m.id == memo.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('メモを削除しました'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 70, left: 16, right: 16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '元に戻す',
          textColor: Colors.white,
          onPressed: () async {
            await _memoService.insertMemo(memo);
            await _loadMemos();
          },
        ),
      ),
    );
  }

  /// 🔍 検索機能
  Future<void> _searchMemos(String query) async {
    final all = await _memoService.fetchAllMemos();
    setState(() {
      _memos = all
          .where((m) => m.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //
  // ====== UI ======
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Builder(
          builder: (innerContext) => Column(
            children: [
              MemoSearchBar(
                controller: _searchController,
                onSearch: _searchMemos,
              ),
              Expanded(child: _buildMemoList(innerContext)),
            ],
          ),
        ),
      ),
    );
  }

  /// 📜 メモリスト
  Widget _buildMemoList(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_memos.isEmpty) {
      return const Center(
        child: Text(
          'まだメモがありません',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMemos,
      color: Colors.blueAccent,
      child: ListView.builder(
        itemCount: _memos.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          final memo = _memos[index];
          return Dismissible(
            key: ValueKey(memo.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 28),
            ),
            onDismissed: (direction) => _deleteMemo(context, memo),
            child: FutureBuilder<String>(
              future: _fetchColorCode(memo.statusId),
              builder: (context, snapshot) {
                final colorCode = snapshot.data ?? '08';
                final color = getStatusColor(colorCode);

                return EditableTaskCard(
                  memo: memo,
                  onContentChanged: (newText) =>
                      _updateMemoContent(memo, newText),
                  leading: GestureDetector(
                    onTap: () => _toggleStatus(memo),
                    onLongPress: () => _showStatusSelectDialog(memo),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// 🧩 status_id → color_code（DB参照で取得）
  Future<String> _fetchColorCode(int? statusId) async {
    if (statusId == null) return '08'; // fallback gray
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'status',
      columns: ['color_code'],
      where: 'id = ?',
      whereArgs: [statusId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['color_code']?.toString() ?? '08';
    }
    return '08';
  }
}
