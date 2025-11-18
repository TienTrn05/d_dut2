import 'dart:convert';

import 'package:flutter/services.dart';

import '../../common/utils/logger.dart';
import '../../features/schedule/data/model/schedule_item_model.dart';

class ScheduleWidgetService {
  Future<void> updateWidget(List<ScheduleItemModel> schedules) async {
    try {
        const channel = MethodChannel("schedule_widget/channel");

        final jsonString = jsonEncode(schedules.map((e) => e.toMap()).toList());
        await channel.invokeMethod("saveSchedule", {"json": jsonString});

        await channel.invokeMethod("refreshWidget");
      } catch (e) {
        logger.e(e);
      }
  }
}