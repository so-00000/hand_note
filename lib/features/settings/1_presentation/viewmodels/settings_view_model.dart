// viewmodels/memo_list_view_model.dart

import 'package:flutter/material.dart';
import '../../2_application/status_service.dart';
import '../../../../core/entities/status_entity.dart';

/// 🧭 設定画面の状態管理（ViewModel層）
/// - ステータス一覧の取得
/// - ステータス追加・削除
/// - 表示モードの管理
class SettingsViewModel extends ChangeNotifier {
  final StatusService _statusService = StatusService();

  String _displayMode = 'auto';
  List<StatusEntity> _statusList = [];

  String get displayMode => _displayMode;
  List<StatusEntity> get statusList => _statusList;

  /// ステータスを取得
  Future<void> loadStatuses() async {
    _statusList = await _statusService.fetchAllStatuses();
    notifyListeners();
  }

  /// ステータス追加
  Future<bool> addStatus(String name, String colorCode) async {
    try {
      await _statusService.addCustomStatus(name, colorCode);
      await loadStatuses();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// ステータス削除
  Future<bool> deleteStatus(int id, String colorCode) async {
    try {
      await _statusService.deleteStatus(id);
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
