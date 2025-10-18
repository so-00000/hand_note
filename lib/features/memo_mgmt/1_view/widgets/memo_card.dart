import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/status_color_mapper.dart';
import '../../../../core/model/memo_model.dart';
import '../../../../core/model/status_model.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../2_view_model/show_memo_list_view_model.dart';
import 'status_select_modal.dart';

/// ===============================
/// 🪧 MemoCard（メモカード）
/// ===============================
///
/// - メモ一覧画面の1行カード
/// - ステータスは statusId 経由で非同期取得
/// - ステータス切替 / 削除 / 編集対応
///
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
    // 🔄 外部でメモ内容が更新された場合に反映
    if (oldWidget.memo.content != widget.memo.content) {
      _controller.text = widget.memo.content!;
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
    final memo = widget.memo;

    final dateStr = formatDateTime(memo.updatedAt ?? memo.createdAt);

    // 🔹 ステータス情報はFutureBuilderで非同期取得
    return FutureBuilder<Status>(
      future: vm.fetchStatusById(memo.statusId ?? 0),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // ステータス未読込時（ロード中）
          return _buildSkeleton(theme);
        }

        final status = snapshot.data!;
        final statusColor = getStatusColor(status.statusColor);
        final statusNm = status.statusNm;

        return Dismissible(
          key: ValueKey(memo.id),
          direction: DismissDirection.endToStart,
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
                  onTap: () => vm.toggleMemoStatus(memo),
                  onLongPress: () => _showStatusSelectDialog(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // 📝 本文＋日時＋ステータス名
                Expanded(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),

                    // 本文
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
                        vm.updateMemoContent(memo, _controller.text);
                        setState(() => _isEditing = false);
                      },
                    )
                        : GestureDetector(
                      onTap: () => setState(() => _isEditing = true),
                      child: Text(
                        memo.content!,
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
                          statusNm,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
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
      },
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
          await vm.updateMemoStatus(widget.memo, status.statusId!);
        },
      ),
    );
  }

  /// ローディング中の仮表示
  Widget _buildSkeleton(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
