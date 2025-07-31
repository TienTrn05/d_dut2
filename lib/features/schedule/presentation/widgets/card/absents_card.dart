import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/schedule/bloc/list_absent/list_absent_bloc.dart';
import 'package:e_dut/features/schedule/bloc/list_absent/list_absent_event.dart';
import 'package:e_dut/features/schedule/bloc/list_absent/list_absent_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AbsentsCard extends StatefulWidget {
  final bool isTeacher;
  final String? name;
  final String? mail;
  final String idUos;
  final String idStudent;

  const AbsentsCard({
    super.key,
    this.isTeacher = true,
    this.name,
    this.mail,
    required this.idUos,
    required this.idStudent,
  });

  @override
  State<AbsentsCard> createState() => _AbsentsCardState();
}

class _AbsentsCardState extends State<AbsentsCard> {
  @override
  void initState() {
    super.initState();
    context
        .read<ListAbsentBloc>()
        .add(LoadListAbsent(idUos: widget.idUos, idStudent: widget.idStudent));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.name?.isNotEmpty == true &&
                    widget.mail?.isNotEmpty == true)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name!,
                                style: TextStyle(
                                  fontSize: FontSizes.medium,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true, // Cho phép xuống hàng
                                overflow: TextOverflow.visible, // Không cắt chữ
                              ),
                              Text(
                                widget.mail!,
                                style: TextStyle(
                                  fontSize: FontSizes.small,
                                ),
                                softWrap: true, // Cho phép xuống hàng
                                overflow: TextOverflow.visible, // Không cắt chữ
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                BlocBuilder<ListAbsentBloc, ListAbsentState>(
                    builder: (context, state) {
                  if (state is ListAbsentLoaded) {
                    final absentDates = state.listAbsentDate;
                    if (absentDates.isNotEmpty) {
                      return Flexible(
                          child: ListView.builder(
                        shrinkWrap: true,
                        // physics: const BouncingScrollPhysics(),
                        itemCount: absentDates.length,
                        itemBuilder: (context, index) => Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(absentDates[index])
                                    .toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: FontSizes.medium),
                              ),
                            ),
                          ),
                        ),
                      ));
                    } else {
                      return Text(
                        'Không có buổi vắng nào',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: FontSizes.medium,
                            color: context.theme.grey ?? Colors.grey),
                      );
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.theme.primaryColor,
                    ),
                  );
                }),
                // const SizedBox(height: 10),
                const SizedBox(
                  height: 10,
                ),
                Divider(color: context.theme.primaryColor ?? Colors.blue),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Các buổi vắng',
                  style: TextStyle(
                      fontSize: FontSizes.extraLarge,
                      fontWeight: FontWeight.w900,
                      color: context.theme.primaryColor ?? Colors.blue),
                ),
              ],
            ),
          )),
    );
  }
}
