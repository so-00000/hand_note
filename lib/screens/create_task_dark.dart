import 'package:flutter/material.dart';
import '../models/memo.dart';
import '../services/memo_service.dart';

/// 📝 メモ作成画面
class CreateTaskDark extends StatefulWidget {
  const CreateTaskDark({super.key});

  @override
  State<CreateTaskDark> createState() => _CreateTaskDarkState();
}

class _CreateTaskDarkState extends State<CreateTaskDark> {
  final TextEditingController _controller = TextEditingController();
  final MemoService _memoService = MemoService(); // ✅ Service層経由でDB操作

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: TaskInputArea(controller: _controller)),
            CreateMemoButton(
              controller: _controller,
              memoService: _memoService,
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

/// ✏️ メモ入力欄
class TaskInputArea extends StatelessWidget {
  final TextEditingController controller;
  const TaskInputArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'What do you need to do?',
                hintStyle: TextStyle(
                  color: Color(0x99EBEBF5),
                  fontSize: 18,
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

/// 🚀 メモ作成ボタン
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
          minimumSize: const Size(310, 56),
        ),
        onPressed: () async {
          final text = controller.text.trim();
          if (text.isEmpty) {
            _showSnackBar(context, 'メモ内容を入力してください', Colors.redAccent);
            return;
          }

          // ✅ 新規メモ作成（Service経由）
          await memoService.insertMemo(
            Memo(
              content: text,
              statusId: 1, // 「未完了」のid
              createdAt: DateTime.now(), // ✅ DateTime型で保持
            ),
          );

          if (!context.mounted) return;

          _showSnackBar(context, 'メモを保存しました！', Colors.green);
          controller.clear();
        },
        child: const Text(
          'メモを作成',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// ✅ SnackBar共通処理
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 70, left: 16, right: 16),
      ),
    );
  }
}
