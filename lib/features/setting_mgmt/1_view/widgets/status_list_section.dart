import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/status_codes.dart';
import '../../../../core/constants/status_color_mapper.dart';
import '../../2_view_model/settings_view_model.dart';
import 'status_card.dart';
import 'status_add_modal.dart';

/// 🎨 ステータス一覧セクション
/// - 並び替え対応（ReorderableListView）
/// - 名前インライン編集対応（フォーカス外/Enterで保存）
/// - 削除ボタン（完了・未完了は非表示）
/// - 色変更（長押し）
/// - 追加ボタン（最大4件まで）
class StatusListSection extends StatelessWidget {
  const StatusListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<SettingsVM>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 並び替えリスト
        ReorderableListView(
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) async {
            await vm.reorderStatus(oldIndex, newIndex);
          },

          // 💡 ドラッグ中のカード（proxy）を透明にする設定
          proxyDecorator: (child, index, animation) {
            return Material(
              color: Colors.transparent, // 背景を完全透明
              child: child,
            );
          },

          // ステータスカード群
          children: [
            for (final s in vm.statusList)
              Padding(
                key: ValueKey('card_${s.statusId}'),
                padding: const EdgeInsets.only(bottom: 12),
                child: ReorderableDragStartListener(
                  index: vm.statusList.indexOf(s),
                  child: StatusCard(
                    name: s.statusNm,
                    color: getStatusColor(s.statusColor),

                    // 🎨 色変更（長押し）
                    onColorChanged: (newColorCode) async {
                      final updatedStatus = s.copyWith(statusColor: newColorCode);
                      await context.read<SettingsVM>().updateStatus(updatedStatus);
                    },

                    // 📝 名前インライン編集
                    onNameChanged: (newName) async {
                      final updatedStatus = s.copyWith(statusNm: newName);
                      await context.read<SettingsVM>().updateStatus(updatedStatus);
                    },

                    // 🗑️ 削除ボタン（完了・未完了は非表示）
                    onDelete: (s.statusId == 1 || s.statusId == 2)
                        ? null
                        : () async {
                      await vm.deleteStatus(s.statusId ?? 0, s.statusColor);
                      _showSnack(context, '「${s.statusNm}」を削除しました');
                    },
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // ➕ 追加ボタン（カスタムステータス4件未満のときのみ表示）
        if (vm.statusList.where((s) => !isFixedStatus(s.statusColor)).length < 4)
          StatusCard(
            name: '+',
            color: theme.colorScheme.surfaceContainerHighest,
            isAddButton: true,
            onTap: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (_) => const StatusAddModal(),
              );

              if (result == true && context.mounted) {
                _showSnack(context, 'ステータスを追加しました');
              }
            },
          ),
      ],
    );
  }

  /// 🧩 スナックバー表示
  void _showSnack(BuildContext context, String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
