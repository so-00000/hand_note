import 'package:flutter/material.dart';
import 'package:hand_note/features/setting_mgmt/1_view/widgets/status_color_modal.dart';
import '../../../../core/constants/status_color_mapper.dart';
import '../../../../core/ui/styles/box_decorations.dart';
import '../../../../core/ui/styles/status_color_circle.dart';

/// ステータス項目カード
/// - タップ：名前編集モードに切替
/// - 長押し：色変更モーダルを表示
/// - 削除ボタン対応（固定は非表示）
class StatusCard extends StatefulWidget {
  final String name;
  final Color color;

  final VoidCallback? onTap;
  final bool isAddButton;
  final ValueChanged<String>? onColorChanged;
  final ValueChanged<String>? onNameChanged;
  final VoidCallback? onDelete;

  const StatusCard({
    super.key,
    required this.name,
    required this.color,
    this.onTap,
    this.isAddButton = false,
    this.onColorChanged,
    this.onNameChanged,
    this.onDelete,
  });

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveIfChanged() {
    final newName = _controller.text.trim();
    if (newName.isNotEmpty && newName != widget.name) {
      widget.onNameChanged?.call(newName);
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    /// ➕ 追加ボタン
    if (widget.isAddButton) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 56,
          decoration: boxDecoration(theme),
          child: const Center(
            child: Text(
              '+',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }



    /// メイン

    return GestureDetector(

      /// ========================
      /// ユーザ操作時の挙動
      /// ========================

      /// タップ時
      onTap: () {
        if (widget.onNameChanged != null) {
          setState(() => _isEditing = true);
        }
      },

      /// 長押し時
      onLongPress: () async {
        final selectedColorCode = await showModalBottomSheet<String>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => StatusColorSelectModal(
            onColorSelected: (code) => Navigator.pop(context, code),
          ),
        );

        if (selectedColorCode != null && widget.onColorChanged != null) {
          widget.onColorChanged!(selectedColorCode);
        }
      },



      /// ========================
      /// UI
      /// ========================

      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: boxDecoration(theme),
        child: Row(
          children: [

            /// ステータス色サークル
            StatusColorCircle(color: widget.color),
            const SizedBox(width: 16),

            ///ステータス名
            Expanded(
              child: _isEditing
                  ? Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) _saveIfChanged();
                },
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onSubmitted: (_) => _saveIfChanged(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              )
                  : Text(
                widget.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            /// 削除ボタン（デフォルトステータスには表示させない）
            if (widget.onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: widget.onDelete,
                tooltip: '削除',
              ),
          ],
        ),
      ),
    );
  }
}
