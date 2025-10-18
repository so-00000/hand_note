// viewmodels/create_memo_view_model.dart
import 'package:flutter/material.dart';
import '../../../core/model/memo_model.dart';
import '../../../core/utils/snackbar_util.dart';
import '../3_model/repository/memo_mgmt_repository.dart';

class CreateMemoVM extends ChangeNotifier {

  final MemoMgmtRepository _memoRepository = MemoMgmtRepository();

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
      await _memoRepository.insertMemo(
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
