// viewmodels/create_memo_view_model.dart
import 'package:flutter/material.dart';
import 'package:hand_note/core/result/operation_result.dart';
import '../../../core/db/database_helper.dart';
import '../../../core/3_model/model/memo_model.dart';
import '../3_model/repository/memo_mgmt_repository.dart';

import '../../../core/services/home_widget_service.dart';

class CreateMemoVM extends ChangeNotifier {

  final MemoMgmtRepository _memoRepository = MemoMgmtRepository();

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<OpeResult> saveMemo(String text) async {

    ///
    /// 例外処理（本文未入力の場合）
    ///

    if (text.trim().isEmpty) {
      return OpeResult.empty;
    }

    ///
    /// 正常処理
    ///

    // UI通知：保存中
    _isSaving = true;
    notifyListeners();

    /// データ登録処理
    try {

      // 登録処理の呼び出し
      await _memoRepository.insertMemo(
        Memo(
          content: text.trim(),
          statusId: 2,
          createdAt: DateTime.now(),
        ),
      );

      // ホームウィジェットにデータ同期
      await HomeWidgetService.syncHomeWidgetFromApp();

      // 処理結果（成功）をUI通知
      return OpeResult.success;

    } catch (e) {

      // 処理結果（失敗）をUI通知
      return OpeResult.fail;

    } finally {

      // ログ出力
      await DatabaseHelper.instance.logAllTables();

      // UI通知：保存中解除
      _isSaving = false;
      notifyListeners();
    }
  }
}
