import 'package:flutter/material.dart';
import '../models/memo.dart';
import '../services/memo_service.dart';
import '../utils/date_formatter.dart';
import '../constants/status_color_mapper.dart'; // 🎨 新カラー管理

/// 🪧 編集可能なメモカードWidget
/// - メモ内容を直接編集可能
/// - 丸アイコンで「未完了 ⇄ 完了」を切り替え
/// - ステータス変更時は更新日時を変更
/// - 外部から leading（左側ウィジェット）を差し込めるよう拡張
class EditableTaskCard extends StatefulWidget {
  final Memo memo;
  final Function(String) onContentChanged;

  /// 👇 ステータス丸などを差し込むための任意ウィジェット
  final Widget? leading;

  const EditableTaskCard({
    super.key,
    required this.memo,
    required this.onContentChanged,
    this.leading,
  });

  @override
  State<EditableTaskCard> createState() => _EditableTaskCardState();
}

class _EditableTaskCardState extends State<EditableTaskCard> {
  late TextEditingController _controller;
  final MemoService _memoService = MemoService();

  bool _isEditing = false;
  int? _statusId;
  String? _statusName;
  String? _statusColor; // ✅ DBのcolor_code（"01"〜"14"）を保持

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.memo.content);
    _statusId = widget.memo.statusId;
    _statusName = widget.memo.statusName;
    _statusColor = widget.memo.statusColor;
  }

  @override
  void didUpdateWidget(covariant EditableTaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.memo.content != widget.memo.content) {
      _controller.text = widget.memo.content;
    }
    if (oldWidget.memo.statusId != widget.memo.statusId) {
      _statusId = widget.memo.statusId;
      _statusName = widget.memo.statusName;
      _statusColor = widget.memo.statusColor;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// ✅ ステータスをトグル（未完了 ⇄ 完了）
  Future<void> _toggleStatus() async {
    if (widget.memo.id == null) return;
    await _memoService.toggleStatus(widget.memo);

    // 🔁 DBから最新状態を再取得
    final all = await _memoService.fetchAllMemos();
    final refreshed = all.firstWhere((m) => m.id == widget.memo.id);

    setState(() {
      _statusId = refreshed.statusId;
      _statusName = refreshed.statusName;
      _statusColor = refreshed.statusColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStatusName = _statusName ?? '未完了';
    final currentColorCode = _statusColor ?? '02'; // 未完了デフォルト
    final currentColor = getStatusColor(currentColorCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ 左側（ステータス丸など差し込み用）
          if (widget.leading != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: widget.leading!,
            ),

          // ✅ メイン部分
          Expanded(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),

              // ✏️ メモ本文
              title: _isEditing
                  ? TextField(
                controller: _controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                ),
                onSubmitted: _saveIfChanged,
              )
                  : GestureDetector(
                onTap: () => setState(() => _isEditing = true),
                child: Text(
                  widget.memo.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // 🕒 日付 + ステータス名
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    // ✅ 更新日時があればそれを優先表示
                    formatDateTime(
                      widget.memo.updatedAt ?? widget.memo.createdAt,
                    ),
                    style: const TextStyle(
                      color: Color(0x99EBEBF5),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    currentStatusName,
                    style: TextStyle(
                      color: currentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

            ),
          ),
        ],
      ),
    );
  }

  /// 💾 内容変更時にDB反映
  void _saveIfChanged(String newText) {
    FocusScope.of(context).unfocus();
    final trimmed = newText.trim();
    if (trimmed.isNotEmpty && trimmed != widget.memo.content) {
      widget.onContentChanged(trimmed);
    }
    setState(() => _isEditing = false);
  }
}
