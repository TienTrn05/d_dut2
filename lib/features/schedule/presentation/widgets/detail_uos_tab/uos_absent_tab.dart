import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart';
import 'package:e_dut/features/schedule/bloc/schedule/calendar_bloc.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/calendar_absent.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/search_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/student_absent_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/student_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UosAbsentTab extends StatefulWidget {
  final bool isCheckAbsent;
  final DateTime selectedDay;
  final String noWeek;

  const UosAbsentTab(
      {super.key,
      required this.isCheckAbsent,
      required this.selectedDay,
      required this.noWeek});
  @override
  State<UosAbsentTab> createState() => _UosAbsentTabState();
}

class _UosAbsentTabState extends State<UosAbsentTab> {
  bool isSellectedAll = false;
  late DateTime _currentDate;
  // var _selectedDate;
  late String _currentWeek = "";
  bool _isCheckedIn = false;
  final TextEditingController _searchController = TextEditingController();
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
  }

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (!(widget.isCheckAbsent && !_isCheckedIn)) ...[
          SearchBarCustom(
            controller: _searchController,
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
                              color: context.theme.primaryColor ?? Colors.blue,
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
                              color: context.theme.primaryColor ?? Colors.blue,
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
                    onPressed: _saveAbsent,
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
                GestureDetector(
                  onTap: () => _toggleSelectAll(),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: Checkbox(
                          value: isSellectedAll,
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
                        "Điểm danh tất cả (10)",
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
              itemCount: students.length + 1,
              itemBuilder: (context, index) {
                if (index == students.length) {
                  // Thêm khoảng trống cuối danh sách
                  return SizedBox(height: 56);
                }
                return widget.isCheckAbsent
                    ? StudentAbsentItem(
                        name: students[index]["name"],
                        mail: students[index]["mail"],
                        isAbsentToday: students[index]["isAbsentToday"],
                        onAbsentChanged: (isAbsent) {
                          updateAbsentStatus(index, isAbsent);
                          setState(() {
                            isSellectedAll = students
                                .every((s) => s["isAbsentToday"] == true);
                          });
                        },
                      )
                    : StudentItem(
                        name: students[index]["name"],
                        mail: students[index]["mail"],
                        absentCount: students[index]["absentCount"],
                      );
              },
            ),
          ),
        ]
      ],
    );
  }
}
