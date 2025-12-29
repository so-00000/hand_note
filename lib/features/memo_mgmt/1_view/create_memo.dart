import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/memo_launch_handler.dart';
import '../2_view_model/create_memo_view_model.dart';

class CreateMemo extends StatelessWidget {
  const CreateMemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateMemoVM(),
      child: const _CreateMemoBody(),
    );
  }
}

class _CreateMemoBody extends StatefulWidget {
  const _CreateMemoBody();

  @override
  State<_CreateMemoBody> createState() => _CreateMemoBodyState();
}

class _CreateMemoBodyState extends State<_CreateMemoBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🧮 キーボード高さ（0のとき＝閉じている）
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Spacer(), // 上側スペース（入力欄を中央付近に押し下げる）

              // 📝 入力欄（中央寄せ）
              TaskInputArea(controller: _controller),

              const Spacer(flex: 1),

              // 🚀 AnimatedPaddingでボタンを下寄せ＋キーボード時は上昇
              AnimatedPadding(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: keyboardHeight > 0 ? keyboardHeight + 24 : 32,
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
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),

      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: TextField(
        controller: controller,
        autofocus: MemoLaunchHandler.memoIdToOpen == 0,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),

        decoration: InputDecoration(
          hintText: 'What do you need to do?',
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
        await vm.saveMemo(context, controller.text);
        controller.clear();
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
