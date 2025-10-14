import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/status_color_mapper.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../3_domain/entities/memo.dart';
import '../../3_domain/entities/memo_status.dart';
import '../viewmodels/memo_list_view_model.dart';
import 'status_select_modal.dart';

/// 🪧 メモ1件分のカードUI
/// - 本文表示・編集
/// - ステータス表示（丸）
/// - スワイプ削除
/// - ステータス一覧（長押しでモーダル表示）
class MemoCard extends StatefulWidget {
  final Memo memo;

  const MemoCard({super.key, required this.memo});

  @override
  State<MemoCard> createState() => _MemoCardState();
}

class _MemoCardState extends State<MemoCard> {
  late final TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.memo.content);
  }

  @override
  void didUpdateWidget(covariant MemoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🔄 メモ内容が外部更新された場合に反映
    if (oldWidget.memo.content != widget.memo.content) {
      _controller.text = widget.memo.content;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<MemoListViewModel>();
    final theme = Theme.of(context);
    final memo = widget.memo;

    // 🎨 ステータス関連
    final color = getStatusColor(memo.statusColor ?? '02');
    final statusName = memo.statusName ?? '未完了';
    final dateStr = formatDateTime(memo.updatedAt ?? memo.createdAt);

    return Dismissible(
      key: ValueKey(memo.id),
      direction: DismissDirection.endToStart,

      // 🗑 左スワイプ：削除
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete, color: theme.colorScheme.onError, size: 28),
      ),
      onDismissed: (_) => vm.deleteMemo(context, memo),

      // 🟣 メモカード本体
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🎨 ステータス丸（タップで切替／長押しで一覧）
            GestureDetector(
              onTap: () => vm.toggleStatus(memo),
              onLongPress: () => _showStatusSelectDialog(context),
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),

            // 📝 本文＋日時＋ステータス名
            Expanded(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),

                title: _isEditing
                    ? TextField(
                  controller: _controller,
                  autofocus: true,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onEditingComplete: () {
                    vm.saveIfChanged(widget.memo, _controller.text);
                    setState(() => _isEditing = false);
                  },
                )
                    : GestureDetector(
                  onTap: () => setState(() => _isEditing = true),
                  child: Text(
                    memo.content,
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                  ),
                ),

                // 🕒 更新日時 ＋ ステータス名
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                    ),
                    Text(
                      statusName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 ステータス一覧モーダル（長押し）
  Future<void> _showStatusSelectDialog(BuildContext context) async {
    final vm = context.read<MemoListViewModel>();
    final statuses = await vm.fetchStatuses();
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatusSelectModal(
        statuses: statuses,
        onStatusSelected: (MemoStatus status) async {

          await vm.updateStatus(widget.memo, status.id!);
        },
      ),
    );
  }
}
