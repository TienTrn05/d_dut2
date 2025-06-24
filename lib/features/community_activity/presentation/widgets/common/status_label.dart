import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/data/model/activity_status_style.dart';
import 'package:e_dut/features/community_activity/constant/activity_status.dart';
import 'package:e_dut/features/community_activity/constant/user_activity_status.dart';
import 'package:flutter/material.dart';

enum StatusType {
  activity,
  userActivity,
}

class StatusLabel extends StatelessWidget {
  final String statusCode;
  final StatusType statusType;
  final bool isFullWidth;

  const StatusLabel({
    super.key,
    required this.statusCode,
    required this.statusType,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(statusCode);
    final displayLabel = statusData['label'] as String;

    return Container(
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: statusData['bgColor'],
        border: Border.all(color: statusData['borderColor']),
        borderRadius: BorderRadius.circular(4),
      ),
      padding:
          EdgeInsets.symmetric(vertical: 4, horizontal: isFullWidth ? 0 : 16),
      child: Text(
        displayLabel,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: statusData['textColor'],
          fontSize: FontSizes.small,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusData(String code) {
    final ActivityStatusStyle? style;

    switch (statusType) {
      case StatusType.activity:
        style = ActivityStatus.activityStatusStyles[code];
        break;
      case StatusType.userActivity:
        style = UserActivityStatus.activityStatusStyles[code];
        break;
    }

    if (style != null) {
      return {
        'label': style.label,
        'bgColor': style.bgColor,
        'borderColor': style.borderColor,
        'textColor': style.textColor,
      };
    }

    return {
      'label': code,
      'bgColor': Colors.grey[200],
      'borderColor': Colors.grey,
      'textColor': Colors.black,
    };
  }
}
