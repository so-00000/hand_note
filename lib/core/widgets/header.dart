import 'package:flutter/material.dart';
import '../../../../../core/3_model/model/memo_model.dart';
import '../../../../../core/3_model/model/status_model.dart';
import '../../../../../core/ui/styles/box_decorations.dart';
import '../../../../../core/ui/styles/status_color_circle.dart';
import '../../../../../core/utils/date_formatter.dart';


/// ===============================
/// ヘッダー
/// ===============================
///
/// - 戻るボタン
/// - カスタマイズボタン
///
/// - （※それぞれの表示条件は要追記）



/// ========================
/// Class
/// ========================

class Header extends StatefulWidget {


  ///
  /// フィールド
  ///


  ///
  /// コンストラクタ
  ///
  const Header({
    super.key,
  });

  /// Stateインスタンスの生成
  @override
  State<Header> createState() => _HeaderState();
}



/// ========================
/// State
/// ========================

class _HeaderState extends State<Header> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }



  /// ========================
  /// UIビルド
  /// ========================
  @override
  Widget build(BuildContext context) {
    return Padding(
      // padding: const EdgeInsets.symmetric(vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          Icon(Icons.more_horiz, color: Color(0xFF373739)),
        ],
      ),
    );
  }
}
