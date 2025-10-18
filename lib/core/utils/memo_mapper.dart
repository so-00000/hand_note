/// ===============================
/// 🧩 MemoMapper
/// ===============================
///
/// - MemoWithStatus → Memo 変換を担当
/// - Repository層での更新・保存時に利用
/// - ViewModel層からも呼び出し可能
///

import '../model/memo_model.dart';
import '../model/memo_with_status_model.dart';

class MemoMapper {
  /// 🔁 MemoWithStatus → Memo
  static Memo toMemo(MemoWithStatus mws) {
    return Memo(
      id: mws.id,
      content: mws.content,
      statusId: mws.statusId,
      createdAt: mws.createdAt,
      updatedAt: mws.updatedAt,
    );
  }
}
