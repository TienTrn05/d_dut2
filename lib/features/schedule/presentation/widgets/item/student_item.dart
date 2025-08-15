import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/schedule/bloc/list_absent/list_absent_bloc.dart';
import 'package:e_dut/features/schedule/presentation/widgets/card/absents_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentItem extends StatelessWidget {
  const StudentItem({
    super.key,
    this.idUos = "",
    this.idStudent = "",
    required this.name,
    required this.mail,
    this.absentCount = -1,
  });

  final String idUos;
  final String idStudent;
  final String name;
  final String mail;
  final int absentCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromRGBO(116, 116, 116, 1),
            width: 0.5,
          ), // Chỉ border bottom
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: FontSizes.medium,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true, // Cho phép xuống hàng
                        overflow: TextOverflow.visible, // Không cắt chữ
                      ),
                      Text(
                        mail,
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
          if (absentCount != -1)
            // ignore: dead_code
            Container(
              width: 39,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                            value: context.read<ListAbsentBloc>(),
                            child: AbsentsCard(
                              isTeacher: true,
                              name: name,
                              mail: mail,
                              idUos: idUos,
                              idStudent: idStudent,
                            ),
                          ));
                },
                child: Text(
                  "$absentCount",
                  style: TextStyle(
                    fontSize: FontSizes.medium,
                    color: absentCount > 0
                        ? context.theme.red
                        : context.theme.grey,
                    decoration: TextDecoration.underline,
                    decorationColor: absentCount > 0
                        ? context.theme.red
                        : context.theme.grey,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
