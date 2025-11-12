import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weekly_schedule_model.dart';

class DetailScheduleDialog extends StatelessWidget {
  const DetailScheduleDialog({super.key, required this.item, this.title});
  final WeeklyScheduleItem item;
  final String? title;

  static const _placeholder = '--/--';

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
                    style: TextStyle(
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

          // Body
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv(context, 'Ngày', df.format(item.day)),
                const SizedBox(height: 8.0),
                _kv(
                  context,
                  'Giờ',
                  '${tf.format(item.start)} - ${tf.format(item.end)}',
                ),
                const SizedBox(height: 8.0),
                _kvMultiline(
                  context,
                  'Nội dung',
                  _formatHtmlForDisplay(item.content),
                ),
                const SizedBox(height: 8.0),
                _kvMultiline(
                  context,
                  'Người tham gia',
                  _formatHtmlForDisplay(item.participants),
                ),
                const SizedBox(height: 8.0),
                _kv(
                  context,
                  'Địa điểm',
                  _displayOrPlaceholder(
                    item.location,
                    usePlaceholderWhenEmpty: true,
                  ),
                ),
                const SizedBox(height: 8.0),
                _kv(
                  context,
                  'Người chủ trì',
                  _displayOrPlaceholder(
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

  String _htmlToPlain(String? html) {
    final s = (html ?? '').trim();
    if (s.isEmpty) return '';

    var out = s;

    out = out.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n- ');
    out = out.replaceAll(RegExp(r'</li>', caseSensitive: false), '');

    out = out.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    out = out.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');
    out = out.replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '');

    out = out.replaceAll(RegExp(r'<[^>]+>'), '');

    out = out.replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&');

    out = out.replaceAll(RegExp(r'\)\s*;\s*\+', caseSensitive: false), ')\n- ');
    out = out.replaceAll(RegExp(r';\s*\+', caseSensitive: false), ';\n- ');
    out = out.replaceAll(RegExp(r':\s*\+', caseSensitive: false), ':\n- ');

    out = out.replaceAll(RegExp(r'(^|\n)\s*\+\s*'), '\n- ');

    out = out.replaceAll(RegExp(r':\+'), ':\n- ');

    out = out.replaceAll(RegExp(r';\s*\n\s*-'), '\n- ');

    out = out.replaceAllMapped(RegExp(r'(\n|^)\+(\d)'), (m) => '\n- ${m[2]}');

    final lines =
        out
            .split('\n')
            .map((l) => l.replaceAll(RegExp(r'\s+'), ' ').trim())
            .toList();
    final filtered = <String>[];
    for (var line in lines) {
      if (line.isEmpty) {
        if (filtered.isNotEmpty && filtered.last.isEmpty) continue;
        filtered.add('');
      } else {
        filtered.add(line);
      }
    }

    var result = filtered.join('\n').trim();

    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    result = result.replaceFirst(RegExp(r'^\-+\s*'), '- ').trimLeft();

    return result;
  }

  String _formatHtmlForDisplay(
    String? html, {
    bool usePlaceholderWhenEmpty = false,
  }) {
    final raw = (html ?? '').trim();
    if (raw.isEmpty && usePlaceholderWhenEmpty) return _placeholder;
    final plain = _htmlToPlain(raw);
    if (plain.isEmpty) return _placeholder;
    return plain;
  }

  String _displayOrPlaceholder(
    String? s, {
    bool usePlaceholderWhenEmpty = false,
  }) {
    final v = (s ?? '').trim();
    if (v.isEmpty && usePlaceholderWhenEmpty) return _placeholder;
    return (v.isEmpty || v == 'null') ? _placeholder : v;
  }

  Widget _kv(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140.0,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: FontSizes.medium,
              color: context.theme.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: FontSizes.medium,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _kvMultiline(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: FontSizes.medium,
            color: context.theme.grey,
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          value,
          style: const TextStyle(
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.35,
          ),
        ),
      ],
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
          style: TextStyle(
            fontSize: FontSizes.large,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _kv(context, 'Ngày', df.format(item.day)),
          const SizedBox(height: 8),
          _kv(
            context,
            'Giờ',
            '${tf.format(item.start)} - ${tf.format(item.end)}',
          ),
          const SizedBox(height: 8),
          _kv(
            context,
            'Địa điểm',
            _displayOrPlaceholder(item.location, usePlaceholderWhenEmpty: true),
          ),
          const SizedBox(height: 8),
          _kv(
            context,
            'Người chủ trì',
            _displayOrPlaceholder(item.host, usePlaceholderWhenEmpty: true),
          ),
          const Divider(height: 24),
          _sectionTitle('Nội dung'),
          const SizedBox(height: 8),
          Text(
            _displayOrPlaceholder(item.content),
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
            _displayOrPlaceholder(_stripTags(item.participants)),
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

  String _stripTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _displayOrPlaceholder(
    String? s, {
    bool usePlaceholderWhenEmpty = false,
  }) {
    final v = (s ?? '').trim();
    if (v.isEmpty && usePlaceholderWhenEmpty) {
      return DetailScheduleDialog._placeholder;
    }
    return (v.isEmpty || v == 'null') ? DetailScheduleDialog._placeholder : v;
  }

  Widget _kv(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140.0,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: FontSizes.medium,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: FontSizes.medium,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
