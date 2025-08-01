import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart';
import 'package:e_dut/features/schedule/bloc/schedule/calendar_bloc.dart';
import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_bloc.dart';
import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_event.dart';
import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_state.dart';
import 'package:e_dut/features/schedule/data/model/role/student_absent_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/calendar_absent.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/search_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/student_absent_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/student_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UosAbsentTab extends StatefulWidget {
  final String idUos;
  final bool isCheckAbsent;
  final DateTime selectedDay;
  final String noWeek;

  const UosAbsentTab(
      {super.key,
      required this.idUos,
      required this.isCheckAbsent,
      required this.selectedDay,
      required this.noWeek});
  @override
  State<UosAbsentTab> createState() => _UosAbsentTabState();
}

class _UosAbsentTabState extends State<UosAbsentTab> {
  bool _isSellectedAll = false; // True: có mặt
  Map<int, bool> _listIsSellectedAll = {};
  late DateTime _currentDate;
  late String _currentWeek = "";
  int _statusCheckedIn =
      0; // 0: Chưa điểm danh, 1: Đã điểm danh, 2: Đang điểm danh
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _totalPages = 1;

// key: studentId, value: true nếu vắng, false nếu có mặt
  Map<String, bool> _listStudentIsAbsent = {};
  Timer? _debounce;
  bool _hasCheckedAttendanceStatus = false;

  void mergeStudentList(List<StudentAbsentModel> newPageStudents) {
    for (var student in newPageStudents) {
      _listStudentIsAbsent.putIfAbsent(
          student.idStudent,
          () => (_listIsSellectedAll[0] ?? false)
              ? !(_listIsSellectedAll[_currentPage] ?? !student.isAbsent)
              : (_statusCheckedIn == 1 ? student.isAbsent : true));
    }
  }

  // Cập nhập trang thái điểm danh
  void updateAbsentStatus(String idStudent, bool isAbsent) {
    setState(() {
      _listStudentIsAbsent[idStudent] = isAbsent;
      _isSellectedAll =
          _listStudentIsAbsent.values.every((status) => status == false);
      if (isAbsent == true && _isSellectedAll) {
        _listIsSellectedAll[_currentPage] = false;
        _isSellectedAll = false;
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _isSellectedAll = !_isSellectedAll;
      _listStudentIsAbsent.updateAll((key, value) => !_isSellectedAll);
      _listIsSellectedAll.updateAll((key, value) => _isSellectedAll);
      // 0; True => Đã từng sellectedAll
      _listIsSellectedAll[0] = true;
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      final keyword = _searchController.text.trim();
      setState(() {
        _currentPage = 1;
      });
      context.read<UosAbsentBloc>().add(LoadStudentsAbsent(
          idUos: widget.idUos,
          pageNumber: 1,
          keyword: keyword,
          absenceDate: _currentDate));
    });
  }

  DateTime getMondayOfWeek(DateTime focusedDay) {
    int difference = focusedDay.weekday - DateTime.monday;
    return focusedDay.subtract(Duration(days: difference));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _currentDate = widget.selectedDay;
      _currentWeek = "tuần ${widget.noWeek}";
      _listStudentIsAbsent = {};
      _listIsSellectedAll = {};
    });
    context.read<UosAbsentBloc>().add(LoadIsAttendanceDate(
        idUos: widget.idUos, attendanceDate: widget.selectedDay));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _updateCurrentDate(DateTime newValue) {
    if (_statusCheckedIn != 0) {
      CustomAlertDialog.showCustomDialog(
          context,
          'Chuyển ngày điểm danh',
          'Dữ liệu sẽ mất nếu bạn chưa lưu trước đó, bạn có chắc chắn muốn tiếp tục thao tác này không?',
          AlertType.confirm, onConfirm: () {
        setState(() {
          _currentDate = newValue;
          _statusCheckedIn = 0;
          _isSellectedAll = false;
          _listIsSellectedAll = {};
          _listStudentIsAbsent = {};
          _currentPage = 1;
          _hasCheckedAttendanceStatus = false;
        });
        context.read<CalendarBloc>().add(
              LoadCalendarWeek(inputDate: getMondayOfWeek(newValue)),
            );
        Navigator.pop(context);
        context.read<UosAbsentBloc>().add(LoadIsAttendanceDate(
            idUos: widget.idUos, attendanceDate: newValue));
      }, textConfirm: "Tiếp tục");
    } else {
      setState(() {
        _currentDate = newValue;
        _statusCheckedIn = 0;
        _isSellectedAll = false;
        _listIsSellectedAll = {};
        _listStudentIsAbsent = {};
        _currentPage = 1;
        _hasCheckedAttendanceStatus = false;
      });
      context.read<CalendarBloc>().add(
            LoadCalendarWeek(inputDate: getMondayOfWeek(newValue)),
          );
      Navigator.pop(context);
      context.read<UosAbsentBloc>().add(
          LoadIsAttendanceDate(idUos: widget.idUos, attendanceDate: newValue));
    }
  }

  void _deleteAbsent() {
    CustomAlertDialog.showCustomDialog(
        context,
        'Xóa ngày điểm danh',
        'Bạn có chắc chắn muốn xóa nhật ký điểm danh ngày ${DateFormat('dd/MM/yyyy').format(_currentDate)} không?',
        AlertType.delete, onConfirm: () {
      context.read<UosAbsentBloc>().add(DeleteAttendanceHistory(
          idUos: widget.idUos, attendanceDate: _currentDate));
    }, textConfirm: "Xóa");
  }

  void _saveAbsent() {
    CustomAlertDialog.showCustomDialog(
        context,
        'Lưu ngày điểm danh',
        'Bạn có chắc chắn muốn lưu nhật ký điểm danh ngày ${DateFormat('dd/MM/yyyy').format(_currentDate)} không?',
        AlertType.confirm, onConfirm: () {
      List<String> idStudentsAbsent = _listStudentIsAbsent.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();
      context.read<UosAbsentBloc>().add(TakeAttendance(
          idUnitOfStudy: widget.idUos,
          absenceDate: _currentDate,
          idStudentsAbsent: idStudentsAbsent));
    }, textConfirm: "Lưu");
  }

  void _alertSuccess({String type = "lưu"}) {
    CustomAlertDialog.showCustomDialog(
        context,
        'Thành công',
        'Danh sách điểm danh của bạn đã được $type thành công.',
        AlertType.success,
        textCancel: "Đóng",
        onCancel: () {});
  }

  void _alertFailure({String type = "lưu"}) {
    CustomAlertDialog.showCustomDialog(
        context,
        'Thất bại',
        'Đã có lỗi xảy ra trong quá trình $type, vui lòng thử lại sau.',
        AlertType.failure,
        textCancel: "Đóng",
        onCancel: () {});
  }

  List<Widget> _buildPageButtons() {
    List<Widget> buttons = [];

    void addPageButton(int i) {
      buttons.add(
        InkWell(
          onTap: () {
            if (i != _currentPage) {
              setState(() {
                _currentPage = i;
              });
              context.read<UosAbsentBloc>().add(LoadStudentsAbsent(
                    idUos: widget.idUos,
                    pageNumber: _currentPage,
                    keyword: _searchController.text.trim(),
                    absenceDate: _currentDate,
                  ));
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  i == _currentPage ? context.theme.primaryColor : Colors.white,
              border: Border.all(
                color: i == _currentPage
                    ? context.theme.primaryColor ?? Colors.blue
                    : context.theme.grey ?? Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$i',
              style: TextStyle(
                color: i == _currentPage ? Colors.white : Colors.black,
                fontWeight:
                    i == _currentPage ? FontWeight.bold : FontWeight.normal,
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
            ),
          ),
        ),
      );
    }

    if (_totalPages <= 5) {
      for (int i = 1; i <= _totalPages; i++) {
        addPageButton(i);
      }
      return buttons;
    }

    // Luôn hiển thị trang đầu tiên
    addPageButton(1);

    // Nếu cần dấu "..." giữa trang đầu và các trang tiếp theo
    if (_currentPage > 3) {
      addEllipsis();
    }

    // Hiển thị current -1, current, current +1 (nếu hợp lệ)
    for (int i = _currentPage - 1; i <= _currentPage + 1; i++) {
      if (i > 1 && i < _totalPages) {
        addPageButton(i);
      }
    }

    // Nếu cần dấu "..." trước trang cuối
    if (_currentPage < _totalPages - 2) {
      addEllipsis();
    }

    // Luôn hiển thị trang cuối
    addPageButton(_totalPages);

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UosAbsentBloc, UosAbsentState>(listener:
        (context, state) {
      if (state is UosCheckIsAttendanceDateLoaded) {
        setState(() {
          _statusCheckedIn = state.isAttendanceDate ? 1 : 0;
          _hasCheckedAttendanceStatus = true;
        });
        context.read<UosAbsentBloc>().add(LoadStudentsAbsent(
              idUos: widget.idUos,
              pageNumber: _currentPage,
              absenceDate: _currentDate,
              keyword: _searchController.text.trim(),
            ));
      }

      if (state is UosTakeAttendanceLoaded) {
        final result = state.isSuccess;
        if (result) {
          _alertSuccess(type: "lưu");
          context.read<UosAbsentBloc>().add(LoadIsAttendanceDate(
              idUos: widget.idUos, attendanceDate: widget.selectedDay));
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
          context.read<UosAbsentBloc>().add(LoadStudentsAbsent(
                idUos: widget.idUos,
                pageNumber: _currentPage,
                absenceDate: _currentDate,
                keyword: _searchController.text.trim(),
              ));
        } else {
          _alertFailure(type: "xóa");
        }
      }
    }, child:
        BlocBuilder<UosAbsentBloc, UosAbsentState>(builder: (context, state) {
      if (!_hasCheckedAttendanceStatus) {
        return Center(
          child: CircularProgressIndicator(
            color: context.theme.primaryColor,
          ),
        );
      }
      if (state is UosAbsentLoaded) {
        final listStudentAbsent = state.listStudentAbsent.studentsPaged;
        final totalItems = listStudentAbsent.totalItems;
        final pageSize = listStudentAbsent.pageSize;
        _totalPages = (totalItems / pageSize).ceil();
        _currentPage = listStudentAbsent.pageNumber;
        if (_listIsSellectedAll.isEmpty) {
          _listIsSellectedAll = {
            // 0; True => Đã từng sellectedAll
            for (int i = 0; i <= _totalPages; i++) i: _isSellectedAll
          };
        }
        mergeStudentList(listStudentAbsent.items);

        return Column(
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
                      child: BlocListener<CalendarBloc, CalendarState>(
                          listenWhen: (previous, current) =>
                              current is CalendarWeekLoaded,
                          listener: (context, state) {
                            if (state is CalendarWeekLoaded) {
                              setState(() {
                                if (state.noWeek.isNotEmpty) {
                                  _currentWeek = "tuần ${state.noWeek}";
                                } else {
                                  _currentWeek = "Không phải tuần học";
                                }
                              });
                            }
                          },
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
                                          ),
                                        ))
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color:
                                      context.theme.primaryColor ?? Colors.blue,
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
                          }))),
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
                                    color: context.theme.red ?? Colors.red,
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
                                    context.theme.primaryColor ?? Colors.blue,
                                side: BorderSide(
                                  color:
                                      context.theme.primaryColor ?? Colors.blue,
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
            if (_statusCheckedIn == 0 && widget.isCheckAbsent) ...[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Bạn có muốn tạo danh sách điểm danh hôm nay không?",
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
                        onPressed: () => setState(() {
                              _statusCheckedIn = 2;
                            }),
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              context.theme.primaryColor ?? Colors.blue,
                          side: BorderSide(
                            color: context.theme.primaryColor ?? Colors.blue,
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
                              'Tạo điểm danh hôm nay',
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
                    itemCount: listStudentAbsent.items.length,
                    itemBuilder: (context, index) {
                      if (index == (listStudentAbsent.items.length)) {
                        // Thêm khoảng trống cuối danh sách
                        return SizedBox(height: 56);
                      }

                      return widget.isCheckAbsent
                          ? StudentAbsentItem(
                              name: listStudentAbsent.items[index].studentName,
                              mail: listStudentAbsent.items[index].noStudent,
                              isAbsentToday: _listStudentIsAbsent[
                                      listStudentAbsent
                                          .items[index].idStudent] ??
                                  false,
                              onAbsentChanged: (isAbsent) {
                                updateAbsentStatus(
                                    listStudentAbsent.items[index].idStudent,
                                    isAbsent);
                              },
                            )
                          : StudentItem(
                              idUos: widget.idUos,
                              idStudent:
                                  listStudentAbsent.items[index].idStudent,
                              name: listStudentAbsent.items[index].studentName,
                              mail: listStudentAbsent.items[index].noStudent,
                              absentCount:
                                  listStudentAbsent.items[index].absentTimes,
                            );
                    },
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageButtons(),
                ),
              ]
            ]
          ],
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
