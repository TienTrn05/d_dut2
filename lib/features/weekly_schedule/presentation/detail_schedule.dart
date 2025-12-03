import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';

import '../models/weekly_schedule_model.dart';

import '../utils/html_utils.dart';
import 'widgets/info_row.dart';

class DetailScheduleDialog extends StatelessWidget {
  const DetailScheduleDialog({super.key, required this.item, this.title});
  final WeeklyScheduleItem item;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    final tf = DateFormat('HH:mm');

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header popup
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title ?? 'Chi tiết cuộc họp',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: FontSizes.extraLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body - Sử dụng InfoRow
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(label: 'Ngày', value: df.format(item.day)),
                const SizedBox(height: 8.0),
                InfoRow(
                  label: 'Giờ',
                  value: '${tf.format(item.start)} - ${tf.format(item.end)}',
                ),
                const SizedBox(height: 8.0),
                InfoRow(
                  label: 'Nội dung',
                  value: HtmlUtils.htmlToPlain(item.content),
                  isMultiline: true,
                ),
                const SizedBox(height: 8.0),
                InfoRow(
                  label: 'Người tham gia',
                  value: HtmlUtils.htmlToPlain(item.participants),
                  isMultiline: true,
                ),
                const SizedBox(height: 8.0),
                InfoRow(
                  label: 'Địa điểm',
                  value: HtmlUtils.displayOrPlaceholder(
                    item.location,
                    usePlaceholderWhenEmpty: true,
                  ),
                ),
                const SizedBox(height: 8.0),
                InfoRow(
                  label: 'Người chủ trì',
                  value: HtmlUtils.displayOrPlaceholder(
                    item.host,
                    usePlaceholderWhenEmpty: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailSchedulePage extends StatelessWidget {
  const DetailSchedulePage({super.key, required this.item, this.pageTitle});
  final WeeklyScheduleItem item;
  final String? pageTitle;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    final tf = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          pageTitle ?? 'Chi tiết cuộc họp',
          style: const TextStyle(
            fontSize: FontSizes.large,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          InfoRow(label: 'Ngày', value: df.format(item.day)),
          const SizedBox(height: 8),
          InfoRow(
            label: 'Giờ',
            value: '${tf.format(item.start)} - ${tf.format(item.end)}',
          ),
          const SizedBox(height: 8),
          InfoRow(
            label: 'Địa điểm',
            value: HtmlUtils.displayOrPlaceholder(
              item.location,
              usePlaceholderWhenEmpty: true,
            ),
          ),
          const SizedBox(height: 8),
          InfoRow(
            label: 'Người chủ trì',
            value: HtmlUtils.displayOrPlaceholder(
              item.host,
              usePlaceholderWhenEmpty: true,
            ),
          ),

          const Divider(height: 24),

          _sectionTitle('Nội dung'),
          const SizedBox(height: 8),
          Text(
            HtmlUtils.displayOrPlaceholder(item.content),
            style: const TextStyle(
              fontSize: FontSizes.medium,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 16),

          _sectionTitle('Người tham gia'),
          const SizedBox(height: 8),
          Text(
            HtmlUtils.displayOrPlaceholder(
              HtmlUtils.stripTags(item.participants),
            ),
            style: const TextStyle(
              fontSize: FontSizes.medium,
              color: Colors.black87,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: FontSizes.large,
      fontWeight: FontWeight.bold,
    ),
  );
}
