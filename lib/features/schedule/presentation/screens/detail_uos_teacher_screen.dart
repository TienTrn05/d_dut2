import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart';
import 'package:e_dut/features/schedule/data/model/noti_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/bottom_modal.dart';
import 'package:e_dut/features/schedule/presentation/widgets/detail_uos_tabs/uos_info_tab.dart';
import 'package:e_dut/features/schedule/presentation/widgets/detail_uos_tabs/uos_noti_tab.dart';
import 'package:e_dut/features/schedule/presentation/widgets/items/edit_field_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/search_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/items/student_item.dart';
import 'package:flutter/material.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/dashboard/presentation/widgets/notification_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../widgets/custom/calendar_absent.dart';

class DetailUOSTeacherScreen extends StatefulWidget {
  final String idUos;
  const DetailUOSTeacherScreen({super.key, required this.idUos});

  @override
  State<DetailUOSTeacherScreen> createState() => _DetailUOSTeacherScreenState();
}

class _DetailUOSTeacherScreenState extends State<DetailUOSTeacherScreen>
    with SingleTickerProviderStateMixin {
  bool isCheckAbsent = false;
  bool isOverlayVisible = false;
  late TabController _tabController;
  bool isSellectedAll = false;
  DateTime currentDate = DateTime.now();
  var selectedDate = "17/03/2025, tuần 3";
  DateTime startdWeek = DateTime(2025, 3, 3);
  String currentLink = "";

  // Giả lập sinh viên
  List<Map<String, dynamic>> students = [
    {
      "name": "Nguyễn Văn A",
      "mail": "a@example.com",
      "absentCount": 0,
      "isCheckAbsent": false,
      "isAbsentToday": false
    },
    {
      "name": "Trần Thị B",
      "mail": "b@example.com",
      "absentCount": 1,
      "isCheckAbsent": false,
      "isAbsentToday": false
    },
    {
      "name": "Lê Văn C",
      "mail": "c@example.com",
      "absentCount": 2,
      "isCheckAbsent": false,
      "isAbsentToday": true
    },
    {
      "name": "Nhật Hạ",
      "mail": "102210159@sv1.dut.udn.vn",
      "absentCount": 0,
      "isCheckAbsent": false,
      "isAbsentToday": true
    },
  ];

  List<NotiModel> notifications = NotiModel.mockData;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Cập nhập trang thái điểm danh
  void updateAbsentStatus(int index, bool isAbsent) {
    setState(() {
      students[index]["isAbsentToday"] = isAbsent;
      if (isAbsent == false && isSellectedAll) {
        isSellectedAll = false;
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      isSellectedAll = !isSellectedAll;
      // Tạo một danh sách mới để Flutter nhận diện sự thay đổi
      students = students.map((student) {
        return {
          ...student, // Sao chép toàn bộ dữ liệu
          "isAbsentToday": isSellectedAll, // Cập nhật giá trị mới
        };
      }).toList();
    });
  }

  void _updateCurrentDate(DateTime newValue) {
    currentDate = newValue;
    String formattedDate = DateFormat('dd/MM/yyyy').format(currentDate);
    if (currentDate.isAfter(startdWeek)) {
      int weekDifference = currentDate.difference(startdWeek).inDays ~/ 7;
      selectedDate = "$formattedDate, tuần ${weekDifference + 1}";
    } else {
      selectedDate = "$formattedDate, tuần 0";
    }
    setState(() {});
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Lắng nghe sự thay đổi tab và cập nhật state
    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != _tabController.previousIndex) {
        setState(() {}); // Cập nhật giao diện khi tab thay đổi
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addNotification(String title, String content) {
    final newItem = NotiModel(
      title: title,
      content: content,
      date: DateTime.now(),
    );
    setState(() {
      notifications.insert(0, newItem);
    });
  }

  void _deleteNotification(int index, String title) {
    String truncatedTitle =
        title.length > 50 ? '${title.substring(0, 47)}...' : title;
    CustomAlertDialog.showCustomDialog(
        context,
        'Xóa thông báo',
        'Bạn có chắc chắn muốn xóa thông báo: $truncatedTitle?',
        AlertType.delete,
        onConfirm: () => setState(() {
              notifications.removeAt(index);
            }),
        textConfirm: "Xóa");
  }

  void _showCreatNewNoti(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return BottomModal(
            title: "Thêm thông báo mới",
            mainAction: () {
              // Giả định bạn lấy dữ liệu từ các controller
              final title = _titleController.text.trim();
              final content = _contentController.text.trim();
              _addNotification(title, content);
              Navigator.pop(context);
            },
            onClose: () {
              _titleController.clear();
              _contentController.clear();
            },
            child: Column(
              children: [
                EditFieldItem(
                  field: "Tiêu đề",
                  controller: _titleController,
                  minLine: 1,
                  maxLine: 2,
                ),
                const SizedBox(height: 10),
                EditFieldItem(
                  field: "Nội dung",
                  controller: _contentController,
                  minLine: 3,
                )
              ],
            ));
      },
    ).whenComplete(() {
      _titleController.clear();
      _contentController.clear();
    });
  }

  void _confirmAction(
      BuildContext context, VoidCallback onConfirm, String confirmText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận"),
        content: Text(confirmText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text("Xác nhận"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: context.theme.primaryColor,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Text(
            'Thông tin chi tiết học phần',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: FontSizes.medium,
            ),
          ),
          centerTitle: true,
          actions: [
            NotificationButton(
              notificationCount: 2,
              onTap: () =>
                  {Navigator.of(context).pushNamed(Routes.notification)},
            ),
          ],
        ),
        body: Stack(
          children: [
            // Nội dung chính
            Container(
              margin: EdgeInsets.all(24),
              child: Column(
                spacing: 10,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Mạng máy tính",
                      style: TextStyle(
                        fontSize: FontSizes.extraLarge,
                        fontWeight: FontWeight.bold,
                        color: context.theme.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: TabBar.secondary(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: context.theme.grey,
                      dividerColor: context.theme.primaryColor,
                      indicator: BoxDecoration(
                        color: context.theme.primaryColor,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: FontSizes.medium,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: FontSizes.medium,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(text: "Thông tin"),
                        Tab(text: "Điểm danh"),
                        Tab(text: "Thông báo"),
                      ],
                    ),
                  ),
                  // TabBarView
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: TabBarView(
                        controller: _tabController,
                        physics:
                            ClampingScrollPhysics(), // Ngăn trượt quá đà khi bấm tab
                        children: [
                          UosInfoTab(
                            idUos: widget.idUos,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              SearchBarCustom(),
                              if (isCheckAbsent) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 5,
                                      child: ElevatedButton(
                                        onPressed: () => {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  CalendarAbsent(
                                                    initDate: currentDate,
                                                    onValueChange:
                                                        _updateCurrentDate,
                                                  ))
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            color: context.theme.primaryColor ??
                                                Colors.blue,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 8,
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          selectedDate,
                                          style: TextStyle(
                                            fontSize: FontSizes.medium,
                                            color: context.theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 4,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: OutlinedButton(
                                              onPressed: () => {
                                                _confirmAction(context, () {},
                                                    "Bạn có chắc chắn muốn xóa nhật ký điểm danh ngày $selectedDate không?")
                                              },
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                side: BorderSide(
                                                  color: context.theme.red ??
                                                      Colors.red,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4,
                                                  horizontal: 8,
                                                ),
                                              ),
                                              child: Text(
                                                'Xóa',
                                                style: TextStyle(
                                                  fontSize: FontSizes.medium,
                                                  color: context.theme.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: OutlinedButton(
                                              onPressed: () => {
                                                _confirmAction(context, () {},
                                                    "Bạn có chắc chắn muốn lưu nhật ký điểm danh ngày $selectedDate không?")
                                              },
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: context
                                                        .theme.primaryColor ??
                                                    Colors.blue,
                                                side: BorderSide(
                                                  color: context
                                                          .theme.primaryColor ??
                                                      Colors.blue,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4,
                                                  horizontal: 8,
                                                ),
                                              ),
                                              child: Text(
                                                'Lưu',
                                                style: TextStyle(
                                                  fontSize: FontSizes.medium,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!isCheckAbsent) ...[
                                    Text(
                                      "Sinh viên (10)",
                                      style: TextStyle(
                                        fontSize: FontSizes.medium,
                                        color: context.theme.grey,
                                      ),
                                    ),
                                    Text(
                                      "Vắng",
                                      style: TextStyle(
                                        fontSize: FontSizes.medium,
                                        color: context.theme.red,
                                      ),
                                    )
                                  ] else ...[
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: Checkbox(
                                            value: isSellectedAll,
                                            activeColor:
                                                context.theme.primaryColor,
                                            onChanged: (bool? newValue) {
                                              _toggleSelectAll();
                                            },
                                            visualDensity:
                                                VisualDensity.compact,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Chọn tất cả (10)",
                                          style: TextStyle(
                                            fontSize: FontSizes.medium,
                                            color: context.theme.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      "Điểm danh",
                                      style: TextStyle(
                                        fontSize: FontSizes.medium,
                                        color: context.theme.grey,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                  // Thêm 1 phần tử cho SizedBox
                                  itemCount: students.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == students.length) {
                                      // Thêm khoảng trống cuối danh sách
                                      return SizedBox(height: 56);
                                    }
                                    return StudentItem(
                                      name: students[index]["name"],
                                      mail: students[index]["mail"],
                                      absentCount: students[index]
                                          ["absentCount"],
                                      isCheckAbsent: isCheckAbsent,
                                      isAbsentToday: students[index]
                                          ["isAbsentToday"],
                                      onAbsentChanged: (isAbsent) {
                                        updateAbsentStatus(index, isAbsent);
                                        setState(() {
                                          isSellectedAll = students.every((s) =>
                                              s["isAbsentToday"] == true);
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          UosNotiTab(
                            notifications: notifications,
                            onDelete: _deleteNotification,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Overlay
            if (isOverlayVisible)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isOverlayVisible = !isOverlayVisible;
                    });
                  },
                  child: Container(
                    alignment: Alignment.topRight,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.7),
                    ),
                  ),
                ),
              )
          ],
        ),
        floatingActionButton: _tabController.index == 1
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOverlayVisible) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isCheckAbsent ? "Tổng quan" : "Điểm danh",
                          style: TextStyle(
                            fontSize: FontSizes.large,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: Center(
                            child: FloatingActionButton.small(
                              onPressed: () {
                                setState(() {
                                  isCheckAbsent = !isCheckAbsent;
                                  isOverlayVisible = !isOverlayVisible;
                                });
                              },
                              backgroundColor: context.theme.lightBlue,
                              shape: CircleBorder(),
                              foregroundColor: Colors.white,
                              child: SvgPicture.asset(
                                isCheckAbsent
                                    ? "assets/icons/svg/student_tracking_overview.svg"
                                    : "assets/icons/svg/student_tracking.svg",
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ], // Khoảng cách giữa hai FAB]
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOverlayVisible) ...[
                        Text(
                          !isCheckAbsent ? "Tổng quan" : "Điểm danh",
                          style: TextStyle(
                            fontSize: FontSizes.large,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            isOverlayVisible = !isOverlayVisible;
                          });
                        },
                        backgroundColor: context.theme.primaryColor,
                        shape: CircleBorder(),
                        child: SvgPicture.asset(
                          isCheckAbsent
                              ? "assets/icons/svg/student_tracking.svg"
                              : "assets/icons/svg/student_tracking_overview.svg",
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : _tabController.index == 2
                ? Container(
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(2, 5),
                      )
                    ]),
                    child: FloatingActionButton(
                      elevation: 0,
                      onPressed: () => _showCreatNewNoti(context),
                      backgroundColor: context.theme.primaryColor,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.add_rounded,
                          size: 28, color: Colors.white),
                    ),
                  )
                : null,
      ),
    );
  }
}
