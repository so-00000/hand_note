import 'package:flutter/material.dart';
import '../constants/status_color_mapper.dart';
import '../constants/status_codes.dart';
import '../db/database_helper.dart';

/// 設定画面（Darkモード専用）
class SettingsDark extends StatefulWidget {
  const SettingsDark({super.key});

  @override
  State<SettingsDark> createState() => _SettingsDarkState();
}

class _SettingsDarkState extends State<SettingsDark> {
  String _displayMode = 'auto';
  List<Map<String, dynamic>> _statusList = [];

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  // ===== データ読込 =====
  Future<void> _loadStatuses() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('status', orderBy: 'id ASC');
    setState(() => _statusList = result);
  }

  // ===== ステータス追加 =====
  Future<void> _addStatusDialog() async {
    String newName = '';
    String? selectedColorCode;

    // ✅ カスタムステータス数チェック
    final customCount = _statusList.where((s) => !isFixedStatus(s['color_code'] as String)).length;
    if (customCount >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('追加できるステータスは最大4件までです')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1C1E),
              title: const Text(
                '新しいステータスを追加',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ステータス名入力欄
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'ステータス名を入力',
                      hintStyle: TextStyle(color: Color(0x66FFFFFF)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0x33FFFFFF)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFFFFFF)),
                      ),
                    ),
                    onChanged: (val) => newName = val.trim(),
                  ),
                  const SizedBox(height: 16),

                  // const Text('カラー選択：',
                  //     style: TextStyle(color: Colors.white, fontSize: 14)),
                  // const SizedBox(height: 8),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: kStatusColorPalette.map((colorMap) {
                      final code = colorMap['code'];
                      final color = (colorMap['color'] ?? Colors.grey) as Color;
                      final isSelected = selectedColorCode == code;
                      return GestureDetector(
                        onTap: () {
                          setInnerState(() => selectedColorCode = code);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () async {
                    if (newName.isNotEmpty && selectedColorCode != null) {
                      final db = await DatabaseHelper.instance.database;
                      await db.insert('status', {
                        'name': newName,
                        'color_code': selectedColorCode,
                      });
                      Navigator.pop(context);
                      await _loadStatuses();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('「$newName」を追加しました')),
                      );
                    }
                  },
                  child: const Text('追加', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===== ステータス削除 =====
  Future<void> _deleteStatus(int id, String name, String colorCode) async {
    if (isFixedStatus(colorCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('固定ステータスは削除できません')),
      );
      return;
    }

    final db = await DatabaseHelper.instance.database;
    await db.delete('status', where: 'id = ?', whereArgs: [id]);
    await _loadStatuses();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('「$name」を削除しました')),
    );
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Display Mode =====
              const Text(
                'Display:',
                style: TextStyle(
                  color: Color(0xFFEBEBF5),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF373739),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: 'light',
                      label: Icon(
                        Icons.wb_sunny_outlined,
                        color: _displayMode == 'light'
                            ? Colors.black
                            : Colors.white,
                        size: 22,
                      ),
                    ),
                    ButtonSegment(
                      value: 'dark',
                      label: Icon(
                        Icons.nightlight_round,
                        color:
                        _displayMode == 'dark' ? Colors.black : Colors.white,
                        size: 20,
                      ),
                    ),
                    ButtonSegment(
                      value: 'auto',
                      label: Text(
                        'auto',
                        style: TextStyle(
                          color: _displayMode == 'auto'
                              ? Colors.black
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  selected: {_displayMode},
                  onSelectionChanged: (value) {
                    setState(() => _displayMode = value.first);
                  },
                  style: ButtonStyle(
                    side: WidgetStateProperty.all(BorderSide.none),
                    backgroundColor:
                    WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return const Color(0xFF373739);
                    }),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ===== Status =====
              const Text(
                'Status:',
                style: TextStyle(
                  color: Color(0xFFEBEBF5),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Column(
                children: [
                  for (final s in _statusList)
                    Dismissible(
                      key: Key(s['id'].toString()),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        // ✅ 削除確認（固定は削除不可）
                        if (isFixedStatus(s['color_code'] as String)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('固定ステータスは削除できません')),
                          );
                          return false;
                        }
                        return true;
                      },
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteStatus(
                        s['id'] as int,
                        s['name'] as String,
                        s['color_code'] as String,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF373739),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: getStatusColor(s['color_code']),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              s['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: _addStatusDialog,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF373739),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          '+',
                          style: TextStyle(
                            color: Color(0x99EBEBF5),
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ===== Info =====
              const Text(
                'Info:',
                style: TextStyle(
                  color: Color(0xFFEBEBF5),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF373739),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edition : Free',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'ver 1.0.0 © xxxx',
                          style: TextStyle(
                            color: Color(0x99EBEBF5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, color: Color(0xFF007AFF), size: 8),
                        SizedBox(width: 6),
                        Text(
                          'Buy Now',
                          style: TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
