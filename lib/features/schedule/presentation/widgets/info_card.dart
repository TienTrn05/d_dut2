import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromRGBO(116, 116, 116, 1),
            width: 0.5,
          ), // Chỉ border bottom
        ),
      ),
      child: Row(
        spacing: 8,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                'https://www.udn.vn/Portals/0/3doan%20bk.jpg',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error,
                      size: 40, color: Colors.red); // Hiển thị icon lỗi
                },
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nhật Hạ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "102210159@sv1.dut.udn.vn",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
