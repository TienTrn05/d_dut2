import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart';
import 'package:e_dut/common/widgets/snackbar/custom_snackbar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/schedule/bloc/schedule/calendar_bloc.dart';
import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_bloc.dart';
import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_event.dart';
import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_state.dart';
import 'package:e_dut/features/schedule/data/model/role/student_absent_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/calendar_absent.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/search_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/student_absent_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/student_item.dart';
import 'package:e_dut/features/schedule/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UosAbsentTab extends StatefulWidget {
  final String idUos;
  final bool isCheckAbsent;
  final DateTime selectedDay;
  final Function setIsNotChecked;
  final Function setIsCheckAbsent;

  const UosAbsentTab({
    super.key,
    required this.idUos,
    required this.isCheckAbsent,
    required this.selectedDay,
    this.setIsNotChecked = defaultFunc,
    this.setIsCheckAbsent = defaultFunc,
  });

  static void defaultFunc() {}
  @override
  State<UosAbsentTab> createState() => _UosAbsentTabState();
}

class _UosAbsentTabState extends State<UosAbsentTab> {
  bool _isSellectedAll = false; // True: có mặt
  late DateTime _currentDate;
  late String _currentWeek = "";

  // 0: Chưa điểm danh, 1: Đã điểm danh, 2: Đang điểm danh
  int _statusCheckedIn = 0;
  bool _isTeachingDate = false;
  bool _isEditing = false;

  final TextEditingController _searchController = TextEditingController();

// key: studentId, value: true nếu vắng, false nếu có mặt
  Map<String, bool> _listStudentIsAbsent = {};
  List<StudentAbsentModel> _listStudentAbsent = [];
  List<StudentAbsentModel> _currentListStudentAbsent = [];
  Timer? _debounce;
  bool _hasCheckedAttendanceStatus = false;
  String _authToken = "";

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _authToken =
        authState is AuthUserAuthenticated ? authState.accessToken : '';

    setState(() {
      _currentDate = widget.selectedDay;
      _listStudentIsAbsent = {};
    });
    context.read<CalendarBloc>().add(
          LoadCalendarWeek(
              inputDate: getMondayOfWeek(widget.selectedDay),
              authToken: _authToken),
        );
    // Check có phải ngày dạy không trước
    context.read<UosAbsentBloc>().add(LoadIsAttendanceDateValid(
        idUos: widget.idUos,
        attendanceDate: widget.selectedDay,
        authToken: _authToken));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Cập nhập trang thái điểm danh
  void updateAbsentStatus(String idStudent, bool isAbsent) {
    setState(() {
      _listStudentIsAbsent[idStudent] = isAbsent;
      _isSellectedAll =
          _listStudentIsAbsent.values.every((status) => status == false);
      if (isAbsent == true && _isSellectedAll) {
        _isSellectedAll = false;
      }
      if (!_isEditing) {
        _isEditing = true;
        widget.setIsNotChecked(false);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _isSellectedAll = !_isSellectedAll;
      _listStudentIsAbsent.updateAll((key, value) => !_isSellectedAll);
      if (!_isEditing) {
        _isEditing = true;
        widget.setIsNotChecked(false);
      }
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      final keyword = _searchController.text.trim();
      if (keyword.isEmpty) {
        _currentListStudentAbsent = List.from(_listStudentAbsent);
      } else {
        final pattern = Functions.buildVietnamesePattern(keyword.toLowerCase());
        final regex = RegExp(pattern, caseSensitive: false);

        _currentListStudentAbsent = _listStudentAbsent.where((student) {
          final name = student.studentName.toLowerCase();
          final no = student.noStudent;
          return regex.hasMatch(name) || regex.hasMatch(no);
        }).toList();
      }
      setState(() {});
    });
  }

  DateTime getMondayOfWeek(DateTime focusedDay) {
    int difference = focusedDay.weekday - DateTime.monday;
    return focusedDay.subtract(Duration(days: difference));
  }

  void _updateCurrentDate(DateTime newValue) {
    if (_statusCheckedIn != 0 && _isEditing) {
      CustomAlertDialog.showCustomDialog(
          context,
          'Chuyển ngày điểm danh',
          'Dữ liệu sẽ mất nếu bạn chưa lưu trước đó, bạn có chắc chắn muốn tiếp tục thao tác này không?',
          AlertDialogType.confirm, onConfirm: () {
        setState(() {
          _currentDate = newValue;
          _statusCheckedIn = 0;
          _isSellectedAll = false;
          _listStudentIsAbsent = {};
          _hasCheckedAttendanceStatus = false;
          _isTeachingDate = true;
          _isEditing = false;
        });
        widget.setIsNotChecked(true);

        context.read<CalendarBloc>().add(
              LoadCalendarWeek(
                  inputDate: getMondayOfWeek(newValue), authToken: _authToken),
            );
        Navigator.pop(context);
        context.read<UosAbsentBloc>().add(LoadIsAttendanceDate(
            idUos: widget.idUos,
            attendanceDate: newValue,
            authToken: _authToken));
      }, textConfirm: "Tiếp tục");
    } else {
      setState(() {
        _currentDate = newValue;
        _statusCheckedIn = 0;
        _isSellectedAll = false;
        _listStudentIsAbsent = {};
        _hasCheckedAttendanceStatus = false;
        _isTeachingDate = true;
        _isEditing = false;
      });
      widget.setIsNotChecked(true);

      context.read<CalendarBloc>().add(
            LoadCalendarWeek(
                inputDate: getMondayOfWeek(newValue), authToken: _authToken),
          );
      Navigator.pop(context);
      context.read<UosAbsentBloc>().add(LoadIsAttendanceDate(
          idUos: widget.idUos,
          attendanceDate: newValue,
          authToken: _authToken));
    }
  }

  void _deleteAbsent() {
    CustomAlertDialog.showCustomDialog(
        context,
        'Xóa ngày điểm danh',
        'Bạn có chắc chắn muốn xóa nhật ký điểm danh ngày ${DateFormat('dd/MM/yyyy').format(_currentDate)} không?',
        AlertDialogType.delete, onConfirm: () {
      context.read<UosAbsentBloc>().add(DeleteAttendanceHistory(
          idUos: widget.idUos,
          attendanceDate: _currentDate,
          authToken: _authToken));
    }, textConfirm: "Xóa");
  }

  void _saveAbsent() {
    CustomAlertDialog.showCustomDialog(
        context,
        'Lưu ngày điểm danh',
        'Bạn có chắc chắn muốn lưu nhật ký điểm danh ngày ${DateFormat('dd/MM/yyyy').format(_currentDate)} không?',
        AlertDialogType.confirm, onConfirm: () {
      List<String> idStudentsAbsent = _listStudentIsAbsent.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();
      context.read<UosAbsentBloc>().add(TakeAttendance(
          idUnitOfStudy: widget.idUos,
          absenceDate: _currentDate,
          idStudentsAbsent: idStudentsAbsent,
          authToken: _authToken));
    }, textConfirm: "Lưu");
  }

  void _alertSuccess({String type = "lưu"}) {
    widget.setIsCheckAbsent(false);
    CustomSnackbar.showSnackBar(
      context,
      "Thành công",
      'Danh sách điểm danh của bạn đã được $type thành công.',
      AlertType.success,
    );
  }

  void _alertFailure({String type = "lưu"}) {
    CustomSnackbar.showSnackBar(
      context,
      'Thất bại',
      'Đã có lỗi xảy ra trong quá trình $type, vui lòng thử lại sau.',
      AlertType.error,
    );
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<UosAbsentBloc, UosAbsentState>(
              listener: (context, state) {
            if (state is UosCheckIsAttendanceDateValidLoaded) {
              setState(() {
                _isTeachingDate = state.isAttendanceDateValid;
              });
              if (state.isAttendanceDateValid) {
                context.read<UosAbsentBloc>().add(LoadIsAttendanceDate(
                    idUos: widget.idUos,
                    attendanceDate: widget.selectedDay,
                    authToken: _authToken));
              } else {
                setState(() {
                  _statusCheckedIn = 0;
                  _hasCheckedAttendanceStatus = true;
                });
                context.read<UosAbsentBloc>().add(LoadStudentsAbsent(
                    idUos: widget.idUos,
                    absenceDate: _currentDate,
                    authToken: _authToken));
              }
            }
            if (state is UosCheckIsAttendanceDateLoaded) {
              setState(() {
                _statusCheckedIn = state.isAttendanceDate ? 1 : 0;
                _hasCheckedAttendanceStatus = true;
              });
              context.read<UosAbsentBloc>().add(LoadStudentsAbsent(
                  idUos: widget.idUos,
                  absenceDate: _currentDate,
                  authToken: _authToken));
            }

            if (state is UosTakeAttendanceLoaded) {
              final result = state.isSuccess;
              if (result) {
                _alertSuccess(type: "lưu");
                context.read<UosAbsentBloc>().add(LoadIsAttendanceDate(
                    idUos: widget.idUos,
                    attendanceDate: widget.selectedDay,
                    authToken: _authToken));
              } else {
                _alertFailure(type: "lưu");
              }
            }
            if (state is UosDeleteAttendanceHistoryLoaded) {
              final result = state.isSuccess;
              if (result) {
                _alertSuccess(type: "xóa");
                _listStudentIsAbsent = {};
                _statusCheckedIn = 0;
                _isEditing = false;
                widget.setIsNotChecked(true);
                context.read<UosAbsentBloc>().add(LoadStudentsAbsent(
                    idUos: widget.idUos,
                    absenceDate: _currentDate,
                    authToken: _authToken));
              } else {
                _alertFailure(type: "xóa");
              }
            }
          }),
          BlocListener<CalendarBloc, CalendarState>(listener: (context, state) {
            if (state is CalendarWeekLoaded) {
              setState(() {
                if (state.noWeek.isNotEmpty) {
                  _currentWeek = "tuần ${state.noWeek}";
                } else {
                  _currentWeek = "Không phải tuần học";
                }
              });
            }
          })
        ],
        child: BlocBuilder<UosAbsentBloc, UosAbsentState>(
            builder: (context, state) {
          if (!_hasCheckedAttendanceStatus) {
            return Center(
              child: CircularProgressIndicator(
                color: context.theme.primaryColor,
              ),
            );
          }
          if (state is UosAbsentLoaded) {
            final listStudentAbsent = state.listStudentAbsent.students;
            final totalItems = state.listStudentAbsent.studentsQuantity;
            if (_listStudentIsAbsent.isEmpty) {
              for (var student in listStudentAbsent) {
                _listStudentIsAbsent[student.idStudent] =
                    _statusCheckedIn == 1 ? student.isAbsent : false;
              }
              _isSellectedAll = _listStudentIsAbsent.values
                  .every((status) => status == false);
            }
            _listStudentAbsent = listStudentAbsent;
            _currentListStudentAbsent = listStudentAbsent;

            return RefreshIndicator(
              color: context.theme.primaryColor,
              backgroundColor: Colors.white,
              onRefresh: () async {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  if (!(widget.isCheckAbsent && _statusCheckedIn == 0)) ...[
                    SearchBarCustom(
                      controller: _searchController,
                      onChanged: (_) => _onSearchChanged(),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                  if (widget.isCheckAbsent) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            flex: 5,
                            child: BlocBuilder<CalendarBloc, CalendarState>(
                                builder: (context, state) {
                              return ElevatedButton(
                                onPressed: () => {
                                  showDialog(
                                      context: context,
                                      builder: (dialogContext) =>
                                          BlocProvider.value(
                                            value: context.read<CalendarBloc>(),
                                            child: CalendarAbsent(
                                              initDate: _currentDate,
                                              onValueChange: _updateCurrentDate,
                                              idUos: widget.idUos,
                                            ),
                                          ))
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: context.theme.primaryColor ??
                                        Colors.blue,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "${DateFormat('dd/MM/yyyy').format(_currentDate)}, $_currentWeek",
                                  style: TextStyle(
                                    fontSize: FontSizes.medium,
                                    color: context.theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            })),
                        if (_statusCheckedIn != 0) ...[
                          Flexible(
                            flex: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (_statusCheckedIn == 1) ...[
                                  Flexible(
                                    child: OutlinedButton(
                                      onPressed: _deleteAbsent,
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                          color:
                                              context.theme.red ?? Colors.red,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
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
                                  )
                                ],
                                SizedBox(width: 4),
                                Flexible(
                                  child: OutlinedButton(
                                    onPressed: _saveAbsent,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          context.theme.primaryColor ??
                                              Colors.blue,
                                      side: BorderSide(
                                        color: context.theme.primaryColor ??
                                            Colors.blue,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
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
                        ]
                      ],
                    ),
                  ],
                  if (!_isTeachingDate && widget.isCheckAbsent) ...[
                    Expanded(
                      child: Center(
                        child: Text(
                          isToday(_currentDate)
                              ? "Bạn không có tiết dạy hôm nay, vui lòng chọn ngày khác để điểm danh."
                              : "Bạn không có tiết dạy ngày này, vui lòng chọn ngày khác để điểm danh.",
                          style: TextStyle(
                            fontSize: FontSizes.medium,
                            color: context.theme.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ] else if (_statusCheckedIn == 0 && widget.isCheckAbsent) ...[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            isToday(_currentDate)
                                ? "Bạn có muốn tạo danh sách điểm danh hôm nay không?"
                                : "Bạn có muốn tạo danh sách điểm danh ngày này không?",
                            style: TextStyle(
                              fontSize: FontSizes.medium,
                              color: context.theme.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _statusCheckedIn = 2;
                                  _isEditing = true;
                                });
                                widget.setIsNotChecked(false);
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    context.theme.primaryColor ?? Colors.blue,
                                side: BorderSide(
                                  color:
                                      context.theme.primaryColor ?? Colors.blue,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    isToday(_currentDate)
                                        ? 'Tạo điểm danh hôm nay'
                                        : 'Tạo điểm danh ngày này',
                                    style: TextStyle(
                                      fontSize: FontSizes.medium,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ] else
                    // Body: list students
                    ...[
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!widget.isCheckAbsent) ...[
                          Text(
                            "Sinh viên ($totalItems)",
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
                          GestureDetector(
                            onTap: () => _toggleSelectAll(),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: Checkbox(
                                    value: _isSellectedAll,
                                    activeColor: context.theme.primaryColor,
                                    onChanged: (bool? newValue) {
                                      _toggleSelectAll();
                                    },
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Điểm danh tất cả ($totalItems)",
                                  style: TextStyle(
                                    fontSize: FontSizes.medium,
                                    color: context.theme.grey,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Text(
                            "${_listStudentIsAbsent.values.where((v) => v == true).length} vắng",
                            style: TextStyle(
                              fontSize: FontSizes.medium,
                              color: context.theme.red,
                            ),
                          )
                        ]
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                      color: context.theme.grey,
                      thickness: 1,
                      height: 1,
                    ),
                    if (totalItems == 0) ...[
                      Center(
                        child: Text(
                          'Không có dữ liệu',
                          style: TextStyle(
                            fontSize: FontSizes.medium,
                            fontWeight: FontWeight.normal,
                            color: context.theme.grey,
                          ),
                        ),
                      )
                    ],
                    if (totalItems > 0) ...[
                      Expanded(
                        child: ListView.builder(
                          // Thêm 1 phần tử cho SizedBox
                          itemCount: _currentListStudentAbsent.length + 1,
                          itemBuilder: (context, index) {
                            if (index == (_currentListStudentAbsent.length)) {
                              // Thêm khoảng trống cuối danh sách
                              return SizedBox(height: 56);
                            }

                            return widget.isCheckAbsent
                                ? StudentAbsentItem(
                                    name: _currentListStudentAbsent[index]
                                        .studentName,
                                    mail: _currentListStudentAbsent[index]
                                        .noStudent,
                                    isAbsentToday: _listStudentIsAbsent[
                                            _currentListStudentAbsent[index]
                                                .idStudent] ??
                                        false,
                                    onAbsentChanged: (isAbsent) {
                                      updateAbsentStatus(
                                          _currentListStudentAbsent[index]
                                              .idStudent,
                                          isAbsent);
                                    },
                                  )
                                : StudentItem(
                                    idUos: widget.idUos,
                                    idStudent: _currentListStudentAbsent[index]
                                        .idStudent,
                                    name: _currentListStudentAbsent[index]
                                        .studentName,
                                    mail: _currentListStudentAbsent[index]
                                        .noStudent,
                                    absentCount:
                                        _currentListStudentAbsent[index]
                                            .absentTimes,
                                  );
                          },
                        ),
                      ),
                    ]
                  ]
                ],
              ),
            );
          }

          return Center(
            child: CircularProgressIndicator(
              color: context.theme.primaryColor,
            ),
          );
        }));
  }
}
