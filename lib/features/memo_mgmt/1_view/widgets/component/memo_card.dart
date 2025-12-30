import 'package:flutter/material.dart';
import '../../../../../core/3_model/model/memo_model.dart';
import '../../../../../core/3_model/model/status_model.dart';
import '../../../../../core/ui/styles/box_decorations.dart';
import '../../../../../core/ui/styles/status_color_circle.dart';
import '../../../../../core/utils/date_formatter.dart';


/// ===============================
/// 🪧 MemoCard（メモカード）
/// ===============================
///
/// - メモ一覧画面の1行カード
/// - ステータスは statusId 経由で非同期取得
/// - ステータス切替 / 削除 / 編集対応
/// - MEMO_ID指定時は自動編集モードON



/// ========================
/// Class
/// ========================

class MemoCard extends StatefulWidget {


  ///
  /// フィールド
  ///
  final Memo memo;
  final Status status;
  final Color statusColor; /// UI専用のColor変換済みステータス色

  final bool isInitiallyEditing;

  // コールバック（ユーザー操作を親に通知）
  final VoidCallback onDelete;                        // カードをスワイプ
  final VoidCallback onToggleStatus;                  // ステータス丸をタップ
  final Future<void> Function() onRequestStatusList;  // ステータス丸を長押し
  final VoidCallback onTapStatusName;                 // ステータス名をタップ
  final ValueChanged<String> onUpdateContent;         // 編集完了時

  ///
  /// コンストラクタ
  ///
  const MemoCard({
    super.key,
    required this.memo,
    required this.status,
    required this.statusColor,
    required this.onDelete,
    required this.onToggleStatus,
    required this.onRequestStatusList,
    required this.onTapStatusName,
    required this.onUpdateContent,
    this.isInitiallyEditing = false,
  });

  /// Stateインスタンスの生成
  @override
  State<MemoCard> createState() => _MemoCardState();
}



/// ========================
/// State
/// ========================

class _MemoCardState extends State<MemoCard> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.memo.content);
    _focusNode = FocusNode();
    _isEditing = widget.isInitiallyEditing;


    // 編集対象なら、ビルド後にフォーカス
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
          _controller.selection = TextSelection.collapsed(
            offset: _controller.text.length,
          );
        }
      });
    }
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
    _focusNode.dispose();
    super.dispose();
  }



  /// ========================
  /// UIビルド
  /// ========================
  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final memo = widget.memo;
    final status = widget.status;
    final dateStr = formatDateTime(memo.updatedAt ?? memo.createdAt);

    return Dismissible(
      key: ValueKey(memo.memoId),
      direction: DismissDirection.endToStart,

      /// swipe時の背景
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete, color: theme.colorScheme.onError, size: 28),
      ),

      onDismissed: (_) => widget.onDelete(),


      ///
      /// カード本体
      ///
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: boxDecoration(theme),
        height: 80,


        // レイアウト：横3列（縦中央揃え）
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            /// ステータス色サークル
            GestureDetector(
              // タップ：ステータス順送り
              onTap: widget.onToggleStatus,
              // 長押し：一覧表示
              onLongPress: widget.onRequestStatusList,

              // レイアウト要素
              child: StatusColorCircle(color: widget.statusColor),

            ),

            const SizedBox(width: 16),

            /// 本文・日時
            Expanded(

              // レイアウト：縦2行（左揃え）
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /// メモ内容
                  _isEditing
                      ? TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                    ),

                    onEditingComplete: () {
                      widget.onUpdateContent(_controller.text);
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

                  /// 更新日時
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                  ),
                ]
              ),
            ),

            /// ステータス名
            GestureDetector(
              onTap: widget.onTapStatusName,
              child: Text(
                status.statusNm,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
