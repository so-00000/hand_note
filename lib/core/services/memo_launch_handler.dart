import 'dart:async';

/// 🧭 ウィジェット経由で開くMEMO_IDを保持・通知するクラス
class MemoLaunchHandler {
  static int? memoIdToOpen;

  // Streamでリスナーに通知（warm start対応）
  static final StreamController<int> _memoIdStreamController =
  StreamController<int>.broadcast();

  static Stream<int> get memoIdStream => _memoIdStreamController.stream;

  /// MEMO_IDをセット＆通知
  static void setMemoId(int memoId) {
    memoIdToOpen = memoId;
    _memoIdStreamController.add(memoId);
  }

  static void clear() {
    memoIdToOpen = null;
  }
}
