// 新規メモ作成画面

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/create_memo_view_model.dart';
import '../services/memo_service.dart';

class CreateMemo extends StatelessWidget {
  const CreateMemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateMemoViewModel(),
      child: const _CreateTaskBody(),
    );
  }
}

class _CreateTaskBody extends StatefulWidget {
  const _CreateTaskBody();

  @override
  State<_CreateTaskBody> createState() => _CreateTaskBodyState();
}

class _CreateTaskBodyState extends State<_CreateTaskBody> {
  final TextEditingController _controller = TextEditingController();
  final MemoService _memoService = MemoService();

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 入力欄（画面中央）
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TaskInputArea(controller: _controller),
              ),
            ),

            // ボタン（下部固定）
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 64),
                child: CreateMemoButton(
                  controller: _controller,
                  memoService: _memoService,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}



/// ✏️ 入力欄
class TaskInputArea extends StatelessWidget {
  final TextEditingController controller;
  const TaskInputArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [

          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),

            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: controller,

              // テキストスタイル（入力文）
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),

              // テキストスタイル（ヒント）
              decoration: InputDecoration(
                hintText: 'What do you need to do?',
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),

            ),
          ),
        ],
      ),
    );
  }
}

/// 🚀 新規ボタン
class CreateMemoButton extends StatelessWidget {
  final TextEditingController controller;
  final MemoService memoService;

  const CreateMemoButton({
    super.key,
    required this.controller,
    required this.memoService,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final vm = Provider.of<CreateMemoViewModel>(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        minimumSize: const Size(310, 56),
      ),

      // 押下処理：新規メモの作成
      onPressed: vm.isSaving
          ? null
          : () async {
        await vm.saveMemo(context, controller.text);
        controller.clear();
      },

      child: Text(
        'メモを作成',
        style: theme.textTheme.labelLarge,
      ),
    );

  }
}