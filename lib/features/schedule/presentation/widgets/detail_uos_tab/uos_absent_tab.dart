import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart';
import 'package:e_dut/features/schedule/bloc/schedule/calendar_bloc.dart';
import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_bloc.dart';
import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_event.dart';
import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_state.dart';
import 'package:e_dut/features/schedule/data/model/role/student_absent_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/students_paged_absent_model.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
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
  bool _isSellectedAll = false;
  late DateTime _currentDate;
  late String _currentWeek = "";
  bool _isCheckedIn = false;
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _totalPages = 1;

// key: studentId, value: true nếu có mặt, false nếu vắng
  Map<String, bool> _studentStatus = {};
  Timer? _debounce;

  void mergeStudentList(List<StudentAbsentModel> newPageStudents) {
    for (var student in newPageStudents) {
      // Nếu student chưa từng được lưu thì mặc định là vắng
      _studentStatus.putIfAbsent(student.idStudent, () => false);
    }
  }

  // Cập nhập trang thái điểm danh
  void updateAbsentStatus(String idStudent, bool isAbsent) {
    setState(() {
      _studentStatus[idStudent] = isAbsent;
      if (isAbsent == false && _isSellectedAll) {
        _isSellectedAll = false;
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _isSellectedAll = !_isSellectedAll;
      _studentStatus.updateAll((key, value) => _isSellectedAll);
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      final keyword = _searchController.text.trim();
      print("====>>>> keyword: ${keyword}");
      setState(() {
        _currentPage = 1;
      });
      context.read<UosAbsentBloc>().add(LoadStudentsAbsent(
            idUos: widget.idUos,
            pageNumber: 1,
            keyword: keyword,
          ));
    });
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
    });
    if (widget.isCheckAbsent) {
      context.read<UosAbsentBloc>().add(LoadIsAttendanceDate(
          idUos: widget.idUos, attendanceDate: widget.selectedDay));
    }
    context.read<UosAbsentBloc>().add(LoadStudentsAbsent(
          idUos: widget.idUos,
          pageNumber: 1,
        ));
  }

  void _updateCurrentDate(DateTime newValue) {
    setState(() {
      _currentDate = newValue;
      _isCheckedIn = !_isCheckedIn;
    });
    context.read<CalendarBloc>().add(
          LoadCalendarWeek(inputDate: getMondayOfWeek(newValue)),
        );
    Navigator.pop(context);
  }

  void _deleteAbsent() {
    CustomAlertDialog.showCustomDialog(
        context,
        'Xóa ngày điểm danh',
        'Bạn có chắc chắn muốn xóa nhật ký điểm danh ngày ${DateFormat('dd/MM/yyyy').format(_currentDate)} không?',
        AlertType.delete,
        onConfirm: () => {setState(() {})},
        textConfirm: "Xóa");
  }

  void _saveAbsent() {
    CustomAlertDialog.showCustomDialog(
        context,
        'Lưu ngày điểm danh',
        'Bạn có chắc chắn muốn lưu nhật ký điểm danh ngày ${DateFormat('dd/MM/yyyy').format(_currentDate)} không?',
        AlertType.confirm,
        onConfirm: () => {setState(() {})},
        textConfirm: "Lưu");
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UosAbsentBloc, UosAbsentState>(listener:
        (context, state) {
      if (state is UosCheckIsAttendanceDateLoaded) {
        setState(() {
          _isCheckedIn = state.isAttendanceDate;
        });
      }
      // if (state is UosAbsentLoaded) {
      //   setState(() {
      //     _currentPageStudents = state.listStudentAbsent.studentsPaged;
      //   });
      // }
    }, child:
        BlocBuilder<UosAbsentBloc, UosAbsentState>(builder: (context, state) {
      if (state is UosAbsentLoading) {
        return Center(child: CircularProgressIndicator());
      }
      if (state is UosAbsentLoaded) {
        final listStudentAbsent = state.listStudentAbsent.studentsPaged;
        mergeStudentList(listStudentAbsent.items);
        final totalItems = listStudentAbsent.totalItems;
        final pageSize = listStudentAbsent.pageSize;
        _totalPages = (totalItems / pageSize).ceil();
        _currentPage = listStudentAbsent.pageNumber;

        if (totalItems == 0) {
          return const Center(
            child: Text(
              'Không có dữ liệu danh sách sinh viên',
              style: TextStyle(
                fontSize: FontSizes.medium,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            if (!(widget.isCheckAbsent && !_isCheckedIn)) ...[
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
                                    builder: (context) => BlocProvider(
                                          create: (_) => CalendarBloc(
                                              getIt.get<ScheduleRepository>()),
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
                  if (_isCheckedIn) ...[
                    Flexible(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                          ),
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
            if (!_isCheckedIn && widget.isCheckAbsent) ...[
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
                              _isCheckedIn = true;
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
              Expanded(
                child: ListView.builder(
                  // Thêm 1 phần tử cho SizedBox
                  itemCount: (listStudentAbsent.items.length) + 1,
                  itemBuilder: (context, index) {
                    if (index == (listStudentAbsent.items.length)) {
                      // Thêm khoảng trống cuối danh sách
                      return SizedBox(height: 56);
                    }

                    return widget.isCheckAbsent
                        ? StudentAbsentItem(
                            name: listStudentAbsent.items[index].studentName,
                            mail: listStudentAbsent.items[index].noStudent,
                            isAbsentToday: _studentStatus[
                                    listStudentAbsent.items[index].idStudent] ??
                                false,
                            onAbsentChanged: (isAbsent) {
                              updateAbsentStatus(
                                  listStudentAbsent.items[index].idStudent,
                                  isAbsent);
                              // setState(() {
                              //   isSellectedAll =                             //       ._currentPageStudents
                              //       .every((s) => s["isAbsentToday"] == true);
                              // });
                            },
                          )
                        : StudentItem(
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
          ],
        );
      }
      return const Center(
        child: Text("Không có dữ liệu danh sách sinh viên"),
      );
    }));
  }
}
