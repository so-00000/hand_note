import 'package:flutter/cupertino.dart';
import '../../../../core/constants/status_codes.dart';
import '../../../../core/dao/memo_dao.dart';
import '../../../../core/dao/status_dao.dart';
import '../../../../core/model/status_model.dart';
import '../../../../main.dart';

/// SettingMgmtRepository
/// 
class SettingMgmtRepository {

  final StatusDao _statusDao = StatusDao();

  
  ///
  /// Statusモデルの操作
  ///

  ///
  /// INSERT
  ///

  // カスタムステータス作成
  Future<void> insertStatus(String statusNm, String statusColor) async {

    await _statusDao.insert(statusNm, statusColor);
  }

  ///
  /// READ
  ///

  // 全ステータス取得（固定＋カスタム含む）
  Future<List<Status>> fetchAllStatuses() async {
    return await _statusDao.fetchAll();
  }

  ///
  /// UPDATE
  ///

  /// 並び順の一括更新
  Future<void> updateStatusOrder(List<Status> statuses) async {
    await _statusDao.updateStatusOrder(statuses);
  }

  Future<void> updateStatus(Status status) async {
    await _statusDao.update(status);
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
  }
}
