import 'package:e_dut/features/homeroom/data/model/student_model.dart';
import 'package:e_dut/features/homeroom/presentation/widgets/custom/search_filter_bar.dart';
import 'package:e_dut/features/homeroom/presentation/widgets/items/student_item.dart';
import 'package:e_dut/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';
import '/common/widgets/modal/bottom_modal.dart';
import '/features/schedule/util/functions.dart';

class ListStudentTab extends StatefulWidget {
  final List<StudentModel> students;

  const ListStudentTab({super.key, required this.students});

  @override
  State<ListStudentTab> createState() => _ListStudentTabState();
}

class _ListStudentTabState extends State<ListStudentTab> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchKeyword = '';

  Set<String> _selectedStatusFilters = {};
  List<StudentModel> filteredStudents = [];
  bool _isSummaryExpanded = false;

  final List<String> _availableStatuses = [
    'Bình thường',
    'Cảnh báo (Lần 1)',
    'Cảnh báo (Lần 2)',
    'Ngừng học',
    'Buộc thôi học',
  ];

  @override
  void initState() {
    super.initState();
    filteredStudents = List.from(widget.students);

    // Thêm listener để lắng nghe mỗi khi người dùng gõ phím
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant ListStudentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.students != widget.students) {
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final keyword = _searchController.text.trim();
    if (_currentSearchKeyword != keyword) {
      _currentSearchKeyword = keyword;
      _performSearch();
    }
  }

  List<StudentModel> searchVietnamese(
    List<StudentModel> students,
    String keyword,
  ) {
    if (keyword.isEmpty) return List.from(students);

    final pattern = Functions.buildVietnamesePattern(keyword.toLowerCase());
    final regex = RegExp(pattern, caseSensitive: false);

    return students.where((student) {
      final name = student.fullName.toLowerCase();
      final no = student.studentCardNumber.toLowerCase();

      return regex.hasMatch(name) || regex.hasMatch(no);
    }).toList();
  }

  void _performSearch() {
    if (widget.students.isEmpty) return;

    setState(() {
      List<StudentModel> temp = searchVietnamese(
        widget.students,
        _currentSearchKeyword,
      );

      if (_selectedStatusFilters.isNotEmpty) {
        temp =
            temp.where((student) {
              // GỌI computedStatus THAY VÌ status
              return _selectedStatusFilters.contains(student.computedStatus);
            }).toList();
      }

      filteredStudents = temp;
    });
  }

  void _showFilterModal(BuildContext context) {
    Set<String> localSelectedStatus = {..._selectedStatusFilters};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return BottomModal(
              title: "Lọc theo trạng thái",
              mainActionText: "Áp dụng",
              mainAction: () {
                setState(() {
                  _selectedStatusFilters = localSelectedStatus;
                });
                Navigator.pop(modalContext);
                _performSearch();
              },
              onCloseText: "Đặt lại",
              onClose: () {
                setModalState(() {
                  localSelectedStatus.clear();
                });
                setState(() {
                  _selectedStatusFilters.clear();
                });
                _performSearch();
              },
              heightFactor: 0.5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children:
                        _availableStatuses.map((status) {
                          final bool isSelected = localSelectedStatus.contains(
                            status,
                          );
                          return TextButton(
                            onPressed: () {
                              setModalState(() {
                                if (isSelected) {
                                  localSelectedStatus.remove(status);
                                } else {
                                  localSelectedStatus.add(status);
                                }
                              });
                            },
                            style: TextButton.styleFrom(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: FontSizes.small,
                              ),
                              backgroundColor:
                                  isSelected
                                      ? context.theme.primaryColor
                                      : context.theme.lightGrey,
                              foregroundColor:
                                  isSelected
                                      ? Colors.white
                                      : context.theme.grey,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(status),
                                if (isSelected)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: FontSizes.small,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 16,
            color: color,
            margin: const EdgeInsets.only(right: 8),
          ),
          Text(
            "$count $label",
            style: TextStyle(
              fontSize: FontSizes.medium,
              color: color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary() {
    int countStatus(String status) =>
        widget.students.where((s) => s.computedStatus == status).length;

    final int normalCount = countStatus("Bình thường");

    final List<Map<String, dynamic>> alertStatuses = [
      {"label": "Cảnh báo (Lần 1)", "color": const Color(0XFFD69700)},
      {"label": "Cảnh báo (Lần 2)", "color": const Color(0XFFFF8D28)},
      {"label": "Ngừng học", "color": const Color(0XFF606166)},
      {"label": "Buộc thôi học", "color": const Color(0XFFF20014)},
    ];

    List<Widget> activeAlertWidgets = [];
    for (var item in alertStatuses) {
      final count = countStatus(item["label"]);
      if (count > 0) {
        activeAlertWidgets.add(
          _buildSummaryItem(item["label"], count, item["color"]),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${filteredStudents.length} sinh viên",
                style: TextStyle(
                  fontSize: FontSizes.medium,
                  color: context.theme.grey,
                ),
              ),

              GestureDetector(
                behavior: HitTestBehavior.opaque, // Giúp vùng bấm dễ ăn hơn
                onTap: () {
                  setState(() {
                    _isSummaryExpanded = !_isSummaryExpanded;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      _isSummaryExpanded ? "Thu gọn" : "Thống kê",
                      style: TextStyle(
                        fontSize: FontSizes.small,
                        color: context.theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Áp dụng TweenAnimationBuilder từ InfoCard để xoay icon mượt mà
                    TweenAnimationBuilder(
                      tween: Tween<double>(
                        begin: 0,
                        end:
                            _isSummaryExpanded
                                ? 0
                                : 1, // 0: hướng xuống, -1: hướng sang phải
                      ),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, double value, child) {
                        return Transform.rotate(
                          angle: value * (3.1415926535 / 2),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: context.theme.primaryColor,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment:
                Alignment
                    .topCenter, // Cố định điểm neo ở trên cùng để hiệu ứng trượt xuống mượt hơn
            child:
                _isSummaryExpanded
                    ? SizedBox(
                      width:
                          double
                              .infinity, // Khóa chiều ngang để AnimatedSize chỉ animate chiều dọc
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),

                          if (normalCount > 0) ...[
                            _buildSummaryItem(
                              "Bình thường",
                              normalCount,
                              const Color(0xFF5BA876),
                            ),
                          ],

                          if (activeAlertWidgets.isNotEmpty)
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final double halfWidth =
                                    constraints.maxWidth / 2;

                                return Wrap(
                                  children:
                                      activeAlertWidgets.map((widget) {
                                        return SizedBox(
                                          width: halfWidth,
                                          child: widget,
                                        );
                                      }).toList(),
                                );
                              },
                            ),
                        ],
                      ),
                    )
                    : const SizedBox(), // Áp dụng SizedBox() như InfoCard thay vì shrink() để đảm bảo ổn định
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchFilterBar(
          controller: _searchController,
          onFilterPressed: () => _showFilterModal(context),
          iconUrl: Assets.icons.svg.tablerFilterSearch,
          textColor: context.theme.grey ?? Colors.grey,
          isFilterActive: _selectedStatusFilters.isNotEmpty,
        ),
        _buildStatusSummary(),

        Expanded(
          child:
              filteredStudents.isEmpty
                  ? Center(
                    child: Text(
                      'Không tìm thấy sinh viên phù hợp.',
                      style: TextStyle(color: context.theme.grey),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return StudentItem(student: student);
                    },
                  ),
        ),
      ],
    );
  }
}
