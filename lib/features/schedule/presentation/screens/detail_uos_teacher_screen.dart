import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart' as dialog;
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/schedule/bloc/list_absent/list_absent_bloc.dart';
import 'package:e_dut/features/schedule/bloc/schedule/calendar_bloc.dart';
import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_bloc.dart';
import 'package:e_dut/features/schedule/bloc/uos_detail/uos_detail_bloc.dart';
import 'package:e_dut/features/schedule/data/model/noti_model.dart';
import 'package:e_dut/common/widgets/modal/bottom_modal.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:e_dut/features/schedule/presentation/widgets/detail_uos_tab/uos_absent_tab.dart';
import 'package:e_dut/features/schedule/presentation/widgets/detail_uos_tab/uos_info_tab.dart';
import 'package:e_dut/features/schedule/presentation/widgets/detail_uos_tab/uos_noti_tab.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/edit_field_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetailUOSTeacherScreen extends StatefulWidget {
  final String idUos;
  final DateTime selectedDay;
  final String noWeek;

  const DetailUOSTeacherScreen(
      {super.key,
      required this.idUos,
      required this.selectedDay,
      required this.noWeek});

  @override
  State<DetailUOSTeacherScreen> createState() => _DetailUOSTeacherScreenState();
}

class _DetailUOSTeacherScreenState extends State<DetailUOSTeacherScreen>
    with SingleTickerProviderStateMixin {
  bool _isCheckAbsent = false;
  bool _isNotChecking = false;
  bool _isOverlayVisible = false;
  late TabController _tabController;

  String currentLink = "";

  List<NotiModel> notifications = NotiModel.mockData;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void setIsNotChecking(bool isNotChecked) {
    _isNotChecking = isNotChecked;
  }

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
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      final String userRole = authState is AuthUserAuthenticated
          ? authState.userData.role.name
          : '';
      final String authToken =
          authState is AuthUserAuthenticated ? authState.accessToken : '';
      return MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (_) => UosDetailBloc(getIt.get<ScheduleRepository>())
                  ..add(LoadFullInfoUosDetail(
                      idUos: widget.idUos, authToken: authToken))),
            BlocProvider(
                create: (_) => CalendarBloc(getIt.get<ScheduleRepository>())),
            BlocProvider(
                create: (_) => UosAbsentBloc(getIt.get<ScheduleRepository>())),
            BlocProvider(
                create: (_) => ListAbsentBloc(getIt.get<ScheduleRepository>()))
          ],
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomAppbar(label: "Thông tin chi tiết học phần"),
              body: userRole == RoleModel.roleTeacher
                  ? BlocBuilder<UosDetailBloc, UosDetailState>(
                      builder: (context, infoState) {
                      if (infoState is UosDetailLoading) {
                        return CustomLoadingIndicator.primary();
                      } else if (infoState is FullInfoUosLoaded) {
                        final uosFullInfo = infoState.fullInfoUosDetail;
                        return Stack(
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
                                      uosFullInfo.uosDetail.subjectName,
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
                                      tabs: [
                                        "Thông tin",
                                        "Điểm danh",
                                        "Thông báo"
                                      ],
                                      onTap: (newindex) {
                                        if (newindex != 1 &&
                                            _isCheckAbsent &&
                                            !_isNotChecking) {
                                          CustomAlertDialog.showCustomDialog(
                                              context,
                                              'Lưu ý',
                                              'Dữ liệu chưa được lưu sẽ mất nếu rời trang. Tiếp tục?',
                                              AlertType.confirm, onConfirm: () {
                                            setState(() {
                                              _tabController.index = newindex;
                                              _isCheckAbsent = false;
                                            });
                                          }, textConfirm: "Tiếp tục");
                                        } else {
                                          _tabController.index = newindex;
                                          setState(() {});
                                        }
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
                                              uosDetail: uosFullInfo.uosDetail,
                                              studyShifts:
                                                  uosFullInfo.studyShifts),
                                          UosAbsentTab(
                                            idUos: widget.idUos,
                                            isCheckAbsent: _isCheckAbsent,
                                            selectedDay: widget.selectedDay,
                                            noWeek: widget.noWeek,
                                            setIsNotChecked: setIsNotChecking,
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
                            if (_isOverlayVisible)
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isOverlayVisible = !_isOverlayVisible;
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
                        );
                      } else {
                        return const Center(
                            child: Text(
                                'Không thể tải dữ liệu thông tin chi tiết học phần.'));
                      }
                    })
                  : Center(
                      child: Text(
                        'Bạn không có quyền truy cập vào chức năng này',
                        style: TextStyle(
                          fontSize: FontSizes.large,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
              floatingActionButton: _tabController.index == 1
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isOverlayVisible) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isCheckAbsent ? "Tổng quan" : "Điểm danh",
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
                                        _isCheckAbsent = !_isCheckAbsent;
                                        _isOverlayVisible = !_isOverlayVisible;
                                      });
                                    },
                                    backgroundColor: context.theme.lightBlue,
                                    shape: CircleBorder(),
                                    foregroundColor: Colors.white,
                                    child: SvgPicture.asset(
                                      _isCheckAbsent
                                          ? "assets/icons/svg/student_tracking_overview.svg"
                                          : "assets/icons/svg/student_tracking.svg",
                                      width: 18,
                                      height: 18,
                                      colorFilter: ColorFilter.mode(
                                          Colors.black, BlendMode.srcIn),
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
                            if (_isOverlayVisible) ...[
                              Text(
                                !_isCheckAbsent ? "Tổng quan" : "Điểm danh",
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
                                  _isOverlayVisible = !_isOverlayVisible;
                                });
                              },
                              backgroundColor: context.theme.primaryColor,
                              shape: CircleBorder(),
                              child: SvgPicture.asset(
                                _isCheckAbsent
                                    ? "assets/icons/svg/student_tracking.svg"
                                    : "assets/icons/svg/student_tracking_overview.svg",
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
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
          ));
    });
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
