import '../../../core/entities/status_entity.dart';
import '../../../core/dao/status_dao.dart';
import '../../../core/constants/status_codes.dart';

/// ===============================
/// 🟢 ステータス管理サービス（sqfliteローカル版）
/// ===============================
///
/// - DAO層への橋渡しを担当
///
/// - 呼び出し先：StatusDaoのみ
/// - 呼び出し元：StatusService
///
class StatusService {

  final StatusDao _statusDao = StatusDao();

  /// 🔍 全ステータス取得（固定＋カスタム含む）
  Future<List<StatusEntity>> fetchAllStatuses() async {
    return await _statusDao.getAllStatuses();
  }

  /// 🔧 カスタムステータス追加
  Future<void> addCustomStatus(String statusNm, String colorCd) async {
    final newStatus = StatusEntity(statusNm: statusNm, colorCd: colorCd);
    await _statusDao.insertStatus(newStatus);
  }

  /// ❌ ステータス削除（固定ステータスは削除不可）
  Future<void> deleteStatus(int statusId) async {
    final all = await _statusDao.getAllStatuses();
    final target = all.firstWhere(
          (s) => s.statusId == statusId,
      orElse: () => throw Exception('対象のステータスが見つかりません'),
    );

    if (isFixedStatus(target.colorCd)) {
      throw Exception('固定ステータスは削除できません');
    }

    await _statusDao.deleteStatus(statusId);
  }

  /// 🩹 初期ステータスが存在しない場合のみ登録
  ///
  /// DatabaseHelperの_createDBで自動登録済みだが、
  /// 万が一削除された場合の補填用。
  Future<void> ensureDefaultStatuses() async {
    final existing = await _statusDao.getAllStatuses();
    if (existing.isNotEmpty) return;

    final defaultStatuses = [
      StatusEntity(statusNm: '完了', colorCd: '01'),
      StatusEntity(statusNm: '未完了', colorCd: '02'),
    ];

    for (final s in defaultStatuses) {
      await _statusDao.insertStatus(s);
    }
  }
}