import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';

class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  const Pagination(
      {super.key,
      required this.currentPage,
      required this.totalPages,
      required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildPageButtons(context),
    );
  }

  List<Widget> _buildPageButtons(BuildContext context) {
    List<Widget> buttons = [];

    void addPageButton(int i) {
      buttons.add(
        GestureDetector(
          onTap: () {
            if (i != currentPage) {
              onPageChanged(i);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  i == currentPage ? context.theme.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$i',
              style: TextStyle(
                color: i == currentPage ? Colors.white : Colors.black,
                fontWeight:
                    i == currentPage ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    void addEllipsis() {
      buttons.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: const Text(
            "...",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Nếu tổng số trang <= 5, hiển thị tất cả
    if (totalPages <= 5) {
      for (int i = 1; i <= totalPages; i++) {
        addPageButton(i);
      }
      return buttons;
    }

    // Logic cho nhiều trang hơn
    // Luôn hiển thị trang đầu tiên
    addPageButton(1);

    // Nếu cần dấu "..." giữa trang đầu và các trang tiếp theo
    if (currentPage > 3) {
      addEllipsis();
    }

    // Hiển thị current -1, current, current +1 (nếu hợp lệ)
    for (int i = currentPage - 1; i <= currentPage + 1; i++) {
      if (i > 1 && i < totalPages) {
        addPageButton(i);
      }
    }

    // Nếu cần dấu "..." trước trang cuối
    if (currentPage < totalPages - 2) {
      addEllipsis();
    }

    // Luôn hiển thị trang cuối
    if (totalPages > 1) {
      addPageButton(totalPages);
    }

    return buttons;
  }
}
