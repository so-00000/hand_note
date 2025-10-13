import '../db/dao/memo_status_dao.dart';
import '../models/memo_status.dart';
import '../constants/status_codes.dart';

import '../db/dao/memo_dao.dart';
import '../models/memo.dart';


/// 🟢 ステータス管理サービス（sqfliteローカル版）
///
/// Firestoreなど外部同期を使用せず、
/// すべてローカルDB（statusテーブル）で完結。
class StatusService {

  final MemoDao _memoDao = MemoDao();
  final MemoStatusDao _statusDao = MemoStatusDao();


  /// ステータスをトグル（完了 ⇄ 未完了）
  ///
  /// DB初期データ：
  /// - id=1 → 完了（color_code: "01"）
  /// - id=2 → 未完了（color_code: "02"）
  ///
  Future<void> toggleStatus(Memo memo) async {

    final newStatusId = (memo.statusId == 1) ? 2 : 1;

    // ステータス情報を取得
    final statusInfo = await _statusDao.fetchById(newStatusId);
    if (statusInfo == null) return;

    // 更新情報のセット
    final updated = memo.copyWith(
      statusId: newStatusId,
      statusName: statusInfo.name,
      statusColor: statusInfo.colorCode,
    );

    await _memoDao.update(updated);
  }

  // /// 🎯 任意ステータスに更新（設定画面や長押し選択用）
  // Future<void> updateStatus(
  //     Memo memo,
  //     int newStatusId,
  //     String newStatusName,
  //     String newStatusColor,
  //     ) async {
  //
  //   final updated = memo.copyWith(
  //     statusId: newStatusId,
  //     statusName: newStatusName,
  //     statusColor: newStatusColor,
  //     updatedAt: DateTime.now(),
  //   );
  //
  //   // 更新処理
  //   await _memoDao.update(updated);
  // }




  /// 🔍 全ステータス取得（固定＋カスタム含む）
  Future<List<MemoStatus>> fetchAllStatuses() async {
    return await _statusDao.fetchAll();
  }

  /// 🔧 カスタムステータス追加
  ///
  /// - 同じカラーコードが既に登録されている場合はエラーを投げる。
  Future<void> addCustomStatus(String name, String colorCode) async {
    final all = await _statusDao.fetchAll();

    // 重複チェック
    final exists = all.any((s) => s.colorCode == colorCode);
    if (exists) {
      throw Exception('同じカラーコードはすでに存在します');
    }

    final newStatus = MemoStatus(name: name, colorCode: colorCode);
    await _statusDao.insert(newStatus);
  }

  /// ❌ ステータス削除（固定ステータスは削除不可）
  Future<void> deleteStatus(int id) async {
    final all = await _statusDao.fetchAll();
    final target = all.firstWhere(
          (s) => s.id == id,
      orElse: () => throw Exception('対象のステータスが見つかりません'),
    );

    if (isFixedStatus(target.colorCode)) {
      throw Exception('固定ステータスは削除できません');
    }

    await _statusDao.delete(id);
  }

  /// 🩹 初期ステータスが存在しない場合のみ登録
  ///
  /// DatabaseHelperの_createDBで自動登録済みだが、
  /// 万が一削除された場合の補填用。
  Future<void> ensureDefaultStatuses() async {
    final existing = await _statusDao.fetchAll();
    if (existing.isNotEmpty) return;

    final defaultStatuses = [
      MemoStatus(name: '完了', colorCode: '01'),
      MemoStatus(name: '未完了', colorCode: '02'),
    ];

    for (final s in defaultStatuses) {
      await _statusDao.insert(s);
    }
  }
}
