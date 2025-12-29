import 'package:flutter/material.dart';
import 'package:hand_note/features/setting_mgmt/3_model/display_mode.dart';
import '../../../core/3_model/model/status_model.dart';
import '../../../core/services/home_widget_service.dart';
import '../3_model/repository/setting_mgmt_repository.dart';

/*🧭 設定画面の状態管理（ViewModel層）

  - ステータス一覧の取得 / 追加 / 削除 / 並び替え
  - 表示モード管理
  - HomeWidget 同期
*/
class SettingsVM extends ChangeNotifier {
  final SettingMgmtRepository settingMgmtRepo = SettingMgmtRepository();

  DisplayMode _displayMode = DisplayMode.auto;
  List<Status> _statusList = [];

  DisplayMode get displayMode => _displayMode;
  List<Status> get statusList => _statusList;



  /// ========================
  /// 表示モード切り替え
  /// ========================

  /// 表示モード更新
  void updateDisplayMode(DisplayMode mode) {
    _displayMode = mode;
    notifyListeners();
  }



  /// ========================
  /// ステータス操作
  /// ========================

  /// ステータス一覧を取得
  Future<void> loadStatuses() async {
    _statusList = await settingMgmtRepo.fetchAllStatuses();
    notifyListeners();
  }

  /// ステータス追加
  Future<bool> addStatus(String statusNm, String statusColor) async {
    try {
      await settingMgmtRepo.insertStatus(statusNm, statusColor);
      await loadStatuses();

      // 🔄 ホームウィジェットにデータ同期
      await HomeWidgetService.syncHomeWidgetFromApp();

      return true;
    } catch (_) {
      return false;
    }
  }

  /// ステータス色の更新 🎨
  Future<void> updateStatus(Status status) async {
    try {
      // 対象のstatus_colorを更新
      await settingMgmtRepo.updateStatus(status);
      await loadStatuses();

      // ホームウィジェットにデータ同期
      await HomeWidgetService.syncHomeWidgetFromApp();

      print("ログ：更新完了");

    } catch (e) {
      debugPrint('⚠️ updateStatusColor error: $e');
    }
  }

  /// ステータス削除
  Future<bool> deleteStatus(int id, String statusColor) async {
    try {
      await settingMgmtRepo.deleteStatus(id);
      await loadStatuses();

      // 🔄 ホームウィジェットにデータ同期
      await HomeWidgetService.syncHomeWidgetFromApp();

      return true;
    } catch (_) {
      return false;
    }
  }

  /// 並び替え処理
  Future<void> reorderStatus(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;

    // 並び替え
    final item = _statusList.removeAt(oldIndex);
    _statusList.insert(newIndex, item);

    // sort_no を再割り振り
    _statusList = [
      for (int i = 0; i < _statusList.length; i++)
        _statusList[i].copyWith(sortNo: i + 1)
    ];

    notifyListeners();

    // ✅ DBへ反映（Repository経由）
    await settingMgmtRepo.updateStatusOrder(_statusList);

    // 🔄 ウィジェットへも同期（順序変更時も反映）
    await HomeWidgetService.syncHomeWidgetFromApp();
  }

}
