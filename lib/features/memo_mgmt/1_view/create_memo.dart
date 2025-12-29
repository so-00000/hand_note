import 'package:flutter/material.dart';
import 'package:hand_note/core/utils/snackbar_util.dart';
import 'package:provider/provider.dart';
import '../../../core/result/operation_result.dart';
import '../../../core/services/memo_launch_handler.dart';
import '../../../core/ui/styles/box_decorations.dart';
import '../2_view_model/create_memo_view_model.dart';

/// ========================
/// Class
/// ========================
class CreateMemo extends StatefulWidget {

  ///
  /// フィールド
  ///



  ///
  /// コンストラクタ
  ///
  const CreateMemo({super.key});

  @override
  State<CreateMemo> createState() => _CreateMemoState();
}



/// ========================
/// State
/// ========================

class _CreateMemoState extends State<CreateMemo> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  /// ========================
  /// UIビルド
  /// ========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Spacer(), // 上側スペース（入力欄を中央付近に押し下げる）

              // 入力欄（中央寄せ）
              TaskInputArea(controller: _controller),

              const Spacer(flex: 1),

              // 作成ボタン
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: CreateMemoButton(controller: _controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ✏️ 入力欄
//
class TaskInputArea extends StatelessWidget {
  final TextEditingController controller;
  const TaskInputArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: textBoxDecoration(theme),

      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: TextField(
        controller: controller,
        autofocus: MemoLaunchHandler.memoIdToOpen == 0,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),

        decoration: InputDecoration(
          hintText: 'メモを作成入力しましょう！',
          hintStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

//
// 🚀 作成ボタン
//
class CreateMemoButton extends StatelessWidget {
  final TextEditingController controller;
  const CreateMemoButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 状態監視
    final vm = context.watch<CreateMemoVM>();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        minimumSize: const Size(310, 56),
      ),
      onPressed: vm.isSaving
          ? null
          : () async {

        // 保存処理の呼び出し
        final result = await vm.saveMemo(controller.text);

        // 処理結果からSnackBar表示
        switch (result) {
          case OpeResult.success:
            controller.clear();
            SnackBarUtil.success(context, 'メモを保存しました！');
            break;

          case OpeResult.empty:
            SnackBarUtil.error(context, 'メモ内容を入力してください');
            break;

          case OpeResult.fail:
            SnackBarUtil.error(context, 'メモの保存に失敗しました');
            break;
        }
      },
      child: vm.isSaving
          ? const CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      )
          : Text('メモを作成', style: theme.textTheme.labelLarge),
    );
  }
}