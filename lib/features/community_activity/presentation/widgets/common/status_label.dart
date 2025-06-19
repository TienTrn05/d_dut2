import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

class StatusLabel extends StatelessWidget {
  final String statusCode;
  const StatusLabel({super.key, required this.statusCode});

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(statusCode);
    final displayLabel = statusData['label'] as String;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: statusData['bgColor'],
        border: Border.all(color: statusData['borderColor']),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
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
    switch (code) {
      case 'registration_open':
        return {
          'label': 'Mở đăng ký',
          'bgColor': const Color(0xFFFFFBE6),
          'borderColor': const Color(0xFFFFE58F),
          'textColor': const Color(0xFFD48806),
        };
      case 'registered':
        return {
          'label': 'Đã đăng ký',
          'bgColor': const Color(0xFFF6FFED),
          'borderColor': const Color(0xFFB7EB8F),
          'textColor': const Color(0xFF389E0D),
        };
      case 'completed':
        return {
          'label': 'Hoàn thành',
          'bgColor': const Color(0xFFE6FFFB),
          'borderColor': const Color(0xFFC3F4EE),
          'textColor': const Color(0xFF47B5C1),
        };
      case 'full':
        return {
          'label': 'Đã đầy',
          'bgColor': const Color(0xFFFFF1F0),
          'borderColor': const Color(0xFFFFA39E),
          'textColor': const Color(0xFFCF1322),
        };
      case 'registration_expired':
        return {
          'label': 'Hết hạn đăng ký',
          'bgColor': const Color(0xFFFCFFE6),
          'borderColor': const Color(0xFFEAFF8F),
          'textColor': const Color(0xFF7CB305),
        };
      default:
        return {
          'label': code,
          'bgColor': Colors.grey[200],
          'borderColor': Colors.grey,
          'textColor': Colors.black,
        };
    }
  }
}
