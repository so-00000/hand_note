import 'package:flutter/cupertino.dart';
import '../../../../core/constants/status_codes.dart';
import '../../../../core/dao/memo_dao.dart';
import '../../../../core/dao/status_dao.dart';
import '../../../../core/model/status_model.dart';
import '../../../../main.dart';

/// StettingMgmtRepository
/// 
class StettingMgmtRepository {

  final StatusDao _statusDao = StatusDao();

  
  ///
  /// Statusモデルの操作
  ///

  ///
  /// INSERT
  ///

  // カスタムステータス作成
  Future<void> insertStatus(String statusNm, String colorCd) async {

    final newStatus = Status(statusNm: statusNm, statusColor: colorCd);
    await _statusDao.insert(newStatus);

    // ホームウィジェットの同期
    await syncHomeWidget();
  }

  ///
  /// READ
  ///

  // 全ステータス取得（固定＋カスタム含む）
  Future<List<Status>> fetchAllStatuses() async {
    return await _statusDao.fetchAll();
  }

  ///
  /// DELETE
  ///

  /// ステータス削除（固定ステータスは削除不可）
  Future<void> deleteStatus(int statusId) async {
    final all = await _statusDao.fetchAll();

    final target = all.firstWhere(
          (s) => s.statusId == statusId,
      orElse: () => throw Exception('対象のステータスが見つかりません'),
    );

    if (isFixedStatus(target.statusColor)) {
      throw Exception('固定ステータスは削除できません');
    }

    await _statusDao.delete(statusId);

    // ホームウィジェットの同期
    await syncHomeWidget();
  }
}
