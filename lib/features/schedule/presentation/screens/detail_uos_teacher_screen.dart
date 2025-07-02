import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart' as dialog;
import 'package:e_dut/features/schedule/data/model/noti_model.dart';
import 'package:e_dut/common/widgets/modal/bottom_modal.dart';
import 'package:e_dut/features/schedule/presentation/widgets/detail_uos_tab/uos_absent_tab.dart';
import 'package:e_dut/features/schedule/presentation/widgets/detail_uos_tab/uos_info_tab.dart';
import 'package:e_dut/features/schedule/presentation/widgets/detail_uos_tab/uos_noti_tab.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/edit_field_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  bool _isAbsentDate = true;
  late TabController _tabController;

  String currentLink = "";

  List<NotiModel> notifications = NotiModel.mockData;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deleteNotification(int index, String title) {
    String truncatedTitle =
        title.length > 50 ? '${title.substring(0, 47)}...' : title;
    dialog.CustomAlertDialog.showCustomDialog(
        context,
        'Xóa thông báo',
        'Bạn có chắc chắn muốn xóa thông báo: $truncatedTitle?',
        dialog.AlertType.delete,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setModalState) {
          _titleController.addListener(() => setModalState(() {}));
          _contentController.addListener(() => setModalState(() {}));

          final title = _titleController.text.trim();
          final content = _contentController.text.trim();

          void addNotification() {
            if (title.isNotEmpty && content.isNotEmpty) {
              String truncatedTitle =
                  title.length > 50 ? '${title.substring(0, 47)}...' : title;
              final newItem = NotiModel(
                  date: DateTime.now(), title: title, content: content);

              dialog.CustomAlertDialog.showCustomDialog(
                  context,
                  'Lưu thông báo',
                  'Bạn có chắc chắn muốn lưu thông báo: $truncatedTitle?',
                  dialog.AlertType.confirm,
                  onConfirm: () => {
                        setState(() {
                          notifications.insert(0, newItem);
                        }),
                        Navigator.pop(context)
                      },
                  textConfirm: "Lưu");
            }
          }

          return BottomModal(
              title: "Thêm thông báo mới",
              enabledMainAction: title.isNotEmpty && content.isNotEmpty,
              mainAction: addNotification,
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
        });
      },
    ).whenComplete(() {
      _titleController.clear();
      _contentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppbar(label: "Thông tin chi tiết học phần"),
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
                    child: CustomTabBar(
                      controller: _tabController,
                      tabs: ["Thông tin", "Điểm danh", "Thông báo"],
                      onTap: (newindex) {
                        _tabController.index = newindex;
                        setState(() {});
                      },
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
                          UosAbsentTab(
                            isCheckAbsent: isCheckAbsent,
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
        floatingActionButton: _tabController.index == 1 && _isAbsentDate
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
                          colorFilter:
                              ColorFilter.mode(Colors.white, BlendMode.srcIn),
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

class CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final void Function(int index) onTap;

  const CustomTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = controller.index == index;
              return Expanded(
                  child: GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                      color: isSelected
                          ? context.theme.primaryColor
                          : Colors.transparent,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8))),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: FontSizes.medium,
                    ),
                  ),
                ),
              ));
            }),
          ),
        ),
        Container(
          height: 1,
          color: context.theme.primaryColor,
        )
      ],
    );
  }
}
