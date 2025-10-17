/// ===============================
/// 📝 CreateMemo（新規メモ作成画面）
/// ===============================
///
/// - View層（UI担当）
/// - ViewModel（CreateMemoViewModel）に依存
/// - データ操作はすべてViewModel経由で実施
///

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // 入力欄（中央）
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TaskInputArea(controller: _controller),
              ),
            ),

            // 作成ボタン（下部固定）
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 64),
                child: CreateMemoButton(controller: _controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✏️ 入力欄
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

/// 🚀 作成ボタン
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