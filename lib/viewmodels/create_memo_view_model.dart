// viewmodels/create_memo_view_model.dart
import 'package:flutter/material.dart';
import '../models/memo.dart';
import '../services/memo_service.dart';
import '../utils/snackbar_util.dart';

class CreateMemoViewModel extends ChangeNotifier {

  final MemoService _memoService = MemoService();

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<void> saveMemo(BuildContext context, String text) async {

    /// 例外処理（本文未入力の場合）
    if (text.trim().isEmpty) {
      SnackBarUtil.error(context, 'メモ内容を入力してください');
      return;
    }

    /// 正常処理

    // state（保存中）をUIに通知
    _isSaving = true;
    notifyListeners();

    // データ登録
    try {

      // 登録処理の呼び出し
      await _memoService.insertMemo(
        Memo(
          content: text.trim(),
          statusId: 0,
          createdAt: DateTime.now(),
        ),
      );

      SnackBarUtil.success(context, 'メモを保存しました！');
    } catch (e) {
      SnackBarUtil.error(context, 'メモの保存に失敗しました');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
