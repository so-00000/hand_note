import 'package:hand_note/core/3_model/model/status_model.dart';
import 'package:hand_note/features/home_widget/status_home_widget_dto.dart';

import '../features/home_widget/memo_home_widget_dto.dart';
import '3_model/model/memo_model.dart';
import 'constants/status_color_mapper.dart';

/// ===============================
///  HomeWidgetMapper
/// ===============================
class HomeWidgetMapper {

  static MemoHomeWidgetDto toMemoDto(Memo memo) {
    return MemoHomeWidgetDto(
      memoId: memo.memoId!,
      content: memo.content!
          .replaceAll('\n', ' ')
          .trim(),
      statusId: memo.statusId,
      prevStatusId: memo.statusId,
    );
  }

  static StatusHomeWidgetDto toStatusDto(Status status) {

    final hexColor = getColorCd(status.statusColor);

    return StatusHomeWidgetDto(
      statusId: status.statusId!,
      sortNo: status.sortNo!,
      statusNm: status.statusNm,
      statusColor: hexColor,
    );
  }
}
