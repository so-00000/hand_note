import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/status_color_mapper.dart';
import '../../../../core/model/memo_with_status_model.dart';
import '../../../../core/model/status_model.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../2_view_model/show_memo_list_view_model.dart';
import 'status_select_modal.dart';

/// ===============================
/// 🪧 MemoCard（メモカード）
/// ===============================
///
/// - メモ一覧画面の1行カード
/// - ステータス切替・削除・編集に対応
///
class MemoCard extends StatefulWidget {
  final MemoWithStatus memoWithStatus;

  const MemoCard({super.key, required this.memoWithStatus});

  @override
  State<MemoCard> createState() => _MemoCardState();
}

class _MemoCardState extends State<MemoCard> {
  late final TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.memoWithStatus.content);
  }

  @override
  void didUpdateWidget(covariant MemoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🔄 メモ内容が外部更新された場合に反映
    if (oldWidget.memoWithStatus.content != widget.memoWithStatus.content) {
      _controller.text = widget.memoWithStatus.content!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ShowMemoListVM>();
    final theme = Theme.of(context);
    final mws = widget.memoWithStatus;

    final color = getStatusColor(mws.colorCd ?? '02');
    final statusNm = mws.statusNm ?? '未完了';
    final dateStr = formatDateTime(mws.updatedAt ?? mws.createdAt);

    return Dismissible(


      key: ValueKey(mws.id),
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
      onDismissed: (_) => vm.deleteMemo(context, mws),

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
              onTap: () => vm.toggleMemoStatus(mws),
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
                    vm.updateMemoContent(mws, _controller.text);
                    setState(() => _isEditing = false);
                  },
                )
                    : GestureDetector(
                  onTap: () => setState(() => _isEditing = true),
                  child: Text(
                    mws.content!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                    ),
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
                      (mws.statusNm ?? ''),
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
    final vm = context.read<ShowMemoListVM>();
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
        onStatusSelected: (Status status) async {
          await vm.updateMemoStatus(
            widget.memoWithStatus,
            status.statusId!,
          );
        },
      ),
    );
  }
}
