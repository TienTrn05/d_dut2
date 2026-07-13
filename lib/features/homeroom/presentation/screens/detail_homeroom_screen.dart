import 'package:auto_route/auto_route.dart';
import 'package:e_dut/common/utils/logger.dart';
import 'package:e_dut/features/homeroom/presentation/widgets/teacher_detail_tab/list_student_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';
import '/common/utils/getit_utils.dart';
import '/common/widgets/appbar/custom_appbar.dart';
import '/common/widgets/dialog/custom_alert_dialog.dart' as dialog;
import '/common/widgets/loading/loading_progress_bar.dart';
import '/common/widgets/snackbar/custom_snackbar.dart';

import '/features/auth/bloc/auth_bloc.dart';
import '/features/auth/data/model/role_model.dart';
import '../../bloc/homeroom_bloc.dart';
import '../../data/model/student_model.dart';
import '../../domain/repository/homeroom_repo.dart';
import '../widgets/teacher_detail_tab/notifications_tab.dart';
import '../../presentation/widgets/items/student_item.dart';
import '/features/profile/bloc/student_profile/student_profile_bloc.dart';
import '/features/profile/domain/repository/profile_repository.dart';
import '/features/schedule/presentation/widgets/custom/search_bar.dart';
import '/features/schedule/util/functions.dart';
import './create_new_homeroom_noti_screen.dart';
import '/common/widgets/errors/error_view.dart';
import '../../../notification/domain/repositories/notification_repository.dart';
import '../../bloc/notification/noti_bloc.dart';

@RoutePage()
class DetailHomeroomScreen extends StatefulWidget {
  const DetailHomeroomScreen({super.key, this.classId, this.homeroomName});

  final String? classId;
  final String? homeroomName;

  @override
  State<DetailHomeroomScreen> createState() => _DetailHomeroomScreenState();
}

class _DetailHomeroomScreenState extends State<DetailHomeroomScreen>
    with SingleTickerProviderStateMixin {
  List<StudentModel> students = [];
  List<StudentModel> filteredStudents = [];

  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  String _currentSearchKeyword = '';
  bool _isDataInitialized = false;

  void _deleteNotification(int index, String title) {
    String truncatedTitle =
        title.length > 50 ? '${title.substring(0, 47)}...' : title;
    dialog.CustomAlertDialog.showCustomDialog(
      context,
      'Xóa thông báo',
      'Bạn có chắc chắn muốn xóa thông báo: $truncatedTitle?',
      dialog.AlertDialogType.delete,
      onConfirm:
          () => {
            // context
            //     .read<NotiBloc>()
            //     .add(DeleteNotiEvent(
            //         notifications[index].id, widget.classId!, authToken)),
            Navigator.pop(context),
          },
      textConfirm: "Xóa",
    );
  }

  void _onSearchChanged() {
    final keyword = _searchController.text.trim();
    _currentSearchKeyword = keyword;
    _performSearch();
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
    if (students.isEmpty) return;

    setState(() {
      filteredStudents = searchVietnamese(students, _currentSearchKeyword);
    });
  }

  void _initializeStudentsList(List<StudentModel> newData) {
    students = newData;
    filteredStudents = searchVietnamese(newData, _currentSearchKeyword);
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final String userRole =
            authState is AuthUserAuthenticated
                ? authState.userData.role.name
                : '';
        final String authToken =
            authState is AuthUserAuthenticated ? authState.accessToken : '';

        final bool isStudent = userRole == RoleModel.roleStudent;

        if (isStudent) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppbar(label: 'Chi tiết lớp sinh hoạt'),
            body: SafeArea(
              child: BlocProvider(
                create:
                    (context) => StudentProfileBloc(
                      repository: getIt.get<ProfileRepository>(),
                    )..add(LoadStudentProfile(authToken)),
                child: BlocBuilder<StudentProfileBloc, StudentProfileState>(
                  builder: (context, profileState) {
                    if (profileState.studentProfileStatus ==
                            StudentProfileStatus.loading ||
                        profileState.studentProfileStatus ==
                            StudentProfileStatus.initial) {
                      return CustomLoadingIndicator.primary();
                    } else if (profileState.studentProfileStatus ==
                        StudentProfileStatus.failure) {
                      return ErrorView(
                        message:
                            "Lỗi khi tải thông tin.\nVui lòng thử lại sau.",
                        errorType: ErrorType.internalError,
                      );
                    }

                    // Get classId from student profile
                    final String classId =
                        profileState.profile?.homeroomId ?? '';
                    final String homeroomName =
                        profileState.profile?.homeroom ?? '';

                    return Container(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        spacing: 20.0,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              homeroomName,
                              style: TextStyle(
                                fontSize: FontSizes.extraLarge,
                                fontWeight: FontWeight.bold,
                                color: context.theme.primaryColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: BlocProvider(
                              create:
                                  (_) => HomeroomBloc(
                                    getIt.get<HomeroomRepository>(),
                                  )..add(
                                    LoadStudentsOfHomeroom(
                                      token: authToken,
                                      classId: classId,
                                    ),
                                  ),
                              child: BlocBuilder<HomeroomBloc, HomeroomState>(
                                builder: (context, homeroomState) {
                                  if (homeroomState is HomeroomError) {
                                    return Center(
                                      child: Text(
                                        'Xảy ra lỗi',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color:
                                              context.theme.grey ?? Colors.grey,
                                        ),
                                      ),
                                    );
                                  }
                                  if (homeroomState is HomeroomLoaded) {
                                    final newData = List<StudentModel>.from(
                                      homeroomState.students,
                                    )..sort(
                                      (a, b) => a.studentCardNumber.compareTo(
                                        b.studentCardNumber,
                                      ),
                                    );

                                    // Only initialize if data changed or not initialized yet
                                    if (!_isDataInitialized ||
                                        students != newData) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            _initializeStudentsList(newData);
                                            setState(() {
                                              _isDataInitialized = true;
                                            });
                                          });
                                    }
                                  }

                                  return _buildStudentsList();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        } else {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create:
                    (_) => HomeroomBloc(getIt.get<HomeroomRepository>())..add(
                      LoadStudentsOfHomeroom(
                        token: authToken,
                        classId: widget.classId!,
                      ),
                    ),
              ),
              BlocProvider(
                create:
                    (_) => NotiBloc(
                      getIt.get<NotificationRepository>(),
                      getIt.get<ProfileRepository>(),
                      getIt.get<HomeroomRepository>(),
                    )..add(
                      LoadNotiEvent(
                        authToken: authToken,
                        classId: widget.classId!,
                      ),
                    ),
              ),
            ],
            child: BlocBuilder<HomeroomBloc, HomeroomState>(
              builder: (context, homeroomState) {
                // Gán students từ state
                if (homeroomState is HomeroomLoaded) {
                  final newData = List<StudentModel>.from(
                    homeroomState.students,
                  )..sort(
                    (a, b) =>
                        a.studentCardNumber.compareTo(b.studentCardNumber),
                  );

                  // Only initialize if data changed or not initialized yet
                  if (!_isDataInitialized || students != newData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _initializeStudentsList(newData);
                      setState(() {
                        _isDataInitialized = true;
                      });
                    });
                  }
                }

                return _buildTeacherView(
                  context,
                  userRole,
                  authToken,
                  homeroomState,
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildTeacherView(
    BuildContext context,
    String userRole,
    String authToken,
    HomeroomState homeroomState,
  ) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppbar(label: 'Chi tiết lớp chủ nhiệm'),
        body: BlocListener<NotiBloc, NotiState>(
          listener: (context, state) {
            if (state.status == NotiStatus.failure &&
                state.errorMessage != '') {
              CustomSnackbar.showSnackBar(
                context,
                "Lỗi",
                state.errorMessage,
                AlertType.error,
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              spacing: 20.0,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.homeroomName ?? '',
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
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
                BlocBuilder<NotiBloc, NotiState>(
                  builder: (context, state) {
                    return Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: ClampingScrollPhysics(),
                        children: [
                          Stack(
                            children: [
                              NotificationsTab(
                                notifications: state.notifications,
                                onDelete: _deleteNotification,
                              ),
                              if (state.status == NotiStatus.loading)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: context.theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          ListStudentTab(students: students),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton:
            _tabController.index == 0
                ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(2, 5),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    elevation: 0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (contextPageRoute) => CreateNewHomeroomNotiScreen(
                                classId: widget.classId!,
                                className: widget.homeroomName!,
                                authToken: authToken,
                                onAddNoti: (newItem) async {
                                  // Logic xử lý thêm noti nằm ở ngoài screen
                                  context.read<NotiBloc>().add(
                                    AddNotiEvent(
                                      newItem,
                                      widget.classId!,
                                      widget.homeroomName!,
                                      authToken,
                                    ),
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    backgroundColor: context.theme.primaryColor,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                )
                : null,
      ),
    );
  }

  Widget _buildStudentsList() {
    return Column(
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
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return StudentItem(student: student);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
