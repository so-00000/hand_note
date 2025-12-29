import 'package:flutter/material.dart';
import '../../../../core/constants/status_color_mapper.dart';
import '../../../../core/3_model/model/status_model.dart';

class StatusListModal extends StatelessWidget {
  final List<Status> statuses;
  final ValueChanged<Status> onSelected;

  const StatusListModal({
    super.key,
    required this.statuses,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 36),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ...statuses.map((s) {
            final color = getStatusColor(s.statusColor);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              // dense: true,
              visualDensity: const VisualDensity(vertical: -.5),  // ステータスリストの間隔調整
              leading: CircleAvatar(radius: 10, backgroundColor: color),
              title: Text(
                s.statusNm,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => onSelected(s),
            );
          }),
        ],
      ),
    );
  }
}
