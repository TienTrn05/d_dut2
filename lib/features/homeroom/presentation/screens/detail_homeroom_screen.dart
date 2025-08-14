import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart' as dialog;
import 'package:e_dut/common/widgets/modal/bottom_modal.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/homeroom/data/model/student_model.dart';
import 'package:e_dut/features/homeroom/presentation/widgets/detail_tab/notifications_tab.dart';
import 'package:e_dut/features/homeroom/presentation/widgets/items/student_item.dart';
import 'package:e_dut/features/schedule/data/model/noti_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/search_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/edit_field_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailHomeroomScreen extends StatefulWidget {
  const DetailHomeroomScreen({super.key});

  @override
  State<DetailHomeroomScreen> createState() => _DetailHomeroomScreenState();
}

class _DetailHomeroomScreenState extends State<DetailHomeroomScreen>
    with SingleTickerProviderStateMixin {
  List<NotiModel> notifications = NotiModel.mockData;
  List<StudentModel> students = [
    StudentModel(
      id: '1',
      name: 'Nguyễn Văn A',
      studentCode: '21TCLC001',
      phoneNumber: '0901234567',
      mail: 'thaonguyenvy109@gmail.com',
      relativePhoneNumber: '0912345678',
    ),
    StudentModel(
      id: '2',
      name: 'Trần Thị B',
      studentCode: '21TCLC002',
      phoneNumber: '0987654321',
      mail: 'tranthib@example.com',
      relativePhoneNumber: '0934567890',
    ),
    StudentModel(
      id: '3',
      name: 'Lê Văn C',
      studentCode: '21TCLC003',
      phoneNumber: '0971122334',
      mail: 'levanc@example.com',
      relativePhoneNumber: '0922334455',
    ),
    StudentModel(
      id: '4',
      name: 'Phạm Thị D',
      studentCode: '21TCLC004',
      phoneNumber: '0965566778',
      mail: 'phamthid@example.com',
      relativePhoneNumber: '0944455667',
    ),
    StudentModel(
      id: '5',
      name: 'Hoàng Văn E',
      studentCode: '21TCLC005',
      phoneNumber: '0956677889',
      mail: 'hoangvane@example.com',
      relativePhoneNumber: '0933344556',
    ),
    StudentModel(
      id: '6',
      name: 'Đỗ Thị F',
      studentCode: '21TCLC006',
      phoneNumber: '0919988776',
      mail: 'dothif@example.com',
      relativePhoneNumber: '0908877665',
    ),
    StudentModel(
      id: '7',
      name: 'Vũ Minh G',
      studentCode: '21TCLC007',
      phoneNumber: '0927766554',
      mail: 'vuminhg@example.com',
      relativePhoneNumber: '0912233445',
    ),
    StudentModel(
      id: '8',
      name: 'Ngô Thị H',
      studentCode: '21TCLC008',
      phoneNumber: '0936655443',
      mail: 'ngothih@example.com',
      relativePhoneNumber: '0945566778',
    ),
  ];
  late TabController _tabController;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _currentPage = 1;
  int _totalPages = 1;

  void _deleteNotification(int index, String title) {
    String truncatedTitle =
        title.length > 50 ? '${title.substring(0, 47)}...' : title;
    dialog.CustomAlertDialog.showCustomDialog(
        context,
        'Xóa thông báo',
        'Bạn có chắc chắn muốn xóa thông báo: $truncatedTitle?',
        dialog.AlertDialogType.delete,
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
                  dialog.AlertDialogType.confirm,
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

  void _onSearchChanged() {
    // if (_debounce?.isActive ?? false) _debounce?.cancel();
    // _debounce = Timer(const Duration(milliseconds: 800), () {
    //   final keyword = _searchController.text.trim();

    //   setState(() {
    //     _currentPage = 1;
    //   });
    //   final authState = context.read<AuthBloc>().state;

    //   final String authToken =
    //       authState is AuthUserAuthenticated ? authState.accessToken : '';

    //   context.read<UosDetailBloc>().add(
    //         LoadExamShiftDetail(
    //             idExamShift: widget.idExamShift,
    //             keyword: keyword,
    //             pageNumber: 1,
    //             authToken: authToken),
    //       );
    // });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      final String userRole = authState is AuthUserAuthenticated
          ? authState.userData.role.name
          : '';

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppbar(
              label: userRole == RoleModel.roleTeacher
                  ? 'Chi tiết lớp chủ nhiệm'
                  : 'Chi tiết lớp sinh hoạt'),
          body: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              spacing: 20.0,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '21TCLC_DT2',
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
                    indicator: BoxDecoration(
                      color: context.theme.primaryColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    dividerColor: context.theme.primaryColor,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 13.0,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: "Thông báo"),
                      Tab(text: "Danh sách sinh viên"),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: ClampingScrollPhysics(),
                    children: [
                      NotificationsTab(
                          notifications: notifications,
                          onDelete: _deleteNotification),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SearchBarCustom(
                              controller: _searchController,
                              onChanged: (_) => _onSearchChanged(),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              "Sinh viên (${students.length})",
                              style: TextStyle(
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.normal,
                                color: context.theme.grey,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: students.length,
                                      itemBuilder: (context, index) {
                                        final student = students[index];
                                        return StudentItem(
                                          student: student,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            )
                          ])
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _tabController.index == 0 &&
                  userRole == RoleModel.roleTeacher
              ? Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
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
    });
  }
}
