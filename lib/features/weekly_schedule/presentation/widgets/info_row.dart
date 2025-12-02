import 'package:flutter/material.dart';
import '../../../../common/extensions/font_sizes.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiline;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: FontSizes.medium,
      color: Colors.grey[600],
    );
    const valueStyle = TextStyle(
      fontSize: FontSizes.medium,
      fontWeight: FontWeight.w500,
      color: Colors.black,
      height: 1.35,
    );

    final content = Text(value, style: valueStyle);

    if (isMultiline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: labelStyle),
          const SizedBox(height: 6.0),
          content,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 140.0, child: Text('$label:', style: labelStyle)),
        Expanded(child: content),
      ],
    );
  }
}
