import 'package:flutter/material.dart';
import '../../../core/model/status_model.dart';
import '../3_model/repository/setting_mgmt_repository.dart';

/// 🧭 設定画面の状態管理（ViewModel層）
/// - ステータス一覧の取得
/// - ステータス追加・削除
/// - 表示モードの管理
class SettingsVM extends ChangeNotifier {
  final StettingMgmtRepository StettingMgmtRepo = StettingMgmtRepository();

  String _displayMode = 'auto';
  List<Status> _statusList = [];

  String get displayMode => _displayMode;
  List<Status> get statusList => _statusList;

  /// ステータスを取得
  Future<void> loadStatuses() async {
    _statusList = await StettingMgmtRepo.fetchAllStatuses();
    notifyListeners();
  }

  /// ステータス追加
  Future<bool> addStatus(String name, String colorCd) async {
    try {
      await StettingMgmtRepo.insertStatus(name, colorCd);
      await loadStatuses();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// ステータス削除
  Future<bool> deleteStatus(int id, String colorCd) async {
    try {
      await StettingMgmtRepo.deleteStatus(id);
      await loadStatuses();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 表示モード更新
  void updateDisplayMode(String mode) {
    _displayMode = mode;
    notifyListeners();
  }
}
