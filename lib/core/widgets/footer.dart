import 'package:flutter/material.dart';
import '../../../../../core/3_model/model/memo_model.dart';
import '../../../../../core/3_model/model/status_model.dart';
import '../../../../../core/ui/styles/box_decorations.dart';
import '../../../../../core/ui/styles/status_color_circle.dart';
import '../../../../../core/utils/date_formatter.dart';
import 'create_memo_bottom_sheet.dart';


/// ===============================
/// フッター
/// ===============================
///
/// - 新規作成ボタン
/// - メイン画面と設定画面遷移ボタン
///
/// - （※それぞれの表示条件は要追記）



/// ========================
/// Class
/// ========================

class Footer extends StatefulWidget {


  ///
  /// フィールド
  ///


  ///
  /// コンストラクタ
  ///
  const Footer({
    super.key,
  });

  /// Stateインスタンスの生成
  @override
  State<Footer> createState() => _FooterState();
}



/// ========================
/// State
/// ========================

class _FooterState extends State<Footer> {

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
    return Container(
      height: 52,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        // border: Border(top: BorderSide(width: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,


        children: [

          /// 新規ボタン
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E2124),
              shape: const StadiumBorder(),
            ),

            onPressed: () {
              _showCreateMemoBottomSheet(context);
            },

            // 新規アイコン
            icon: const Icon(Icons.add),
            // 新規テキスト
            label: const Text(
                'メモを作成'),
          ),

          /// 画面遷移ボタン
          const Icon(Icons.settings),
        ],
      ),
    );
  }

  void _showCreateMemoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ← キーボード対応で必須
      useSafeArea: true,
      backgroundColor: Colors.transparent, // 角丸を活かす
      barrierColor: Colors.black.withOpacity(0.2), // iOSっぽい
      builder: (context) {
        return const CreateMemoBottomSheet();
      },
    );
  }
}
