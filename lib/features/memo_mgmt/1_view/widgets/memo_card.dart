import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/status_color_mapper.dart';
import '../../../../core/model/memo_model.dart';
import '../../../../core/model/status_model.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/services/memo_launch_handler.dart'; // ← 追加
import 'status_list_modal.dart';
import '../../2_view_model/show_memo_list_view_model.dart';
import '../../../setting_mgmt/1_view/widgets/status_color_modal.dart';

/// ===============================
/// 🪧 MemoCard（メモカード）
/// ===============================
///
/// - メモ一覧画面の1行カード
/// - ステータスは statusId 経由で非同期取得
/// - ステータス切替 / 削除 / 編集対応
/// - MEMO_ID指定時は自動編集モードON
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

    // ✅ ウィジェット経由の起動時、自動編集モードON
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ShowMemoListVM>();
      final memoId = MemoLaunchHandler.memoIdToOpen ?? vm.editingMemoId;
      if (memoId != null && memoId == widget.memo.memoId && mounted) { // ←ここをmemo.memoIdに統一
        setState(() => _isEditing = true);
        print('✏️ 自動編集モード開始: MEMO_ID=${widget.memo.memoId}');
      }
    });

  }

  @override
  void didUpdateWidget(covariant MemoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🔄 外部でメモ内容が更新された場合に反映
    if (oldWidget.memo.content != widget.memo.content) {
      _controller.text = widget.memo.content ?? '';
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
          key: ValueKey(memo.memoId),
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
                  onLongPress: () async {
                    final statuses = await vm.fetchStatuses();
                    vm.showStatusListModal(memo, statuses);
                  },

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
                      autofocus: true, // ← 編集モード時に自動フォーカス
                      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                      ),
                      onEditingComplete: () {
                        vm.updateMemoContent(memo, _controller.text);
                        setState(() => _isEditing = false);
                        FocusScope.of(context).unfocus();
                      },
                    )
                        : GestureDetector(
                      onTap: () => setState(() => _isEditing = true),
                      child: Text(
                        memo.content ?? '',
                        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                      ),
                    ),

                    // 🕒 更新日時 ＋ ステータス名
                    subtitle: SizedBox(
                      height: 20,  //高さ固定（全角が混在時の高さ変化防止）
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center, // ← 縦中央揃え
                        children: [
                          Text(
                            dateStr,
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () => vm.cycleStatusBySortNo(memo),
                            child: Text(
                              statusNm,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                                height: 1.0, // ← 行間を固定（さらに安定）
                              ),
                            ),
                          ),
                        ],
                      ),
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


  /// ローディング中の仮表示　※画面のちらつき防止
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
