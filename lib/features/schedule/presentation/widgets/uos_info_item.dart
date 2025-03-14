import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UosInfoItem extends StatelessWidget {
  final String field;
  final Widget value;
  final String? linkAttached;
  final String? linkIconAsset;
  final Function()? action;
  const UosInfoItem(
      {super.key,
      required this.field,
      required this.value,
      this.linkAttached,
      this.linkIconAsset,
      this.action});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$field:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF747474),
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                value,
                if (linkIconAsset != null) ...[
                  Flexible(
                    child:
                        SizedBox(width: 10), // Co giãn theo không gian còn lại
                  ),
                  GestureDetector(
                    onTap: action,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        linkIconAsset!,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
