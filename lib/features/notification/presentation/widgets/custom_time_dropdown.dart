import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/core/data/local/storage.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/core/bloc/notification_settings/notification_settings_bloc.dart';

class CustomTimeDropdown extends StatefulWidget {
  const CustomTimeDropdown({super.key});

  @override
  State<CustomTimeDropdown> createState() => _CustomTimeDropdownState();
}

class _CustomTimeDropdownState extends State<CustomTimeDropdown> {
  String formatTime(int minutes) {
    if (minutes < 60) {
      return '$minutes phút';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      return '$hours giờ ${remainingMinutes > 0 ? '$remainingMinutes phút' : ''}';
    }
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
        return BlocBuilder<NotificationSettingsBloc, NotificationSettingsState>(
          builder: (context, state) {
            return IgnorePointer(
              ignoring: !Storage.examNotification,
              child: PopupMenuButton<int>(
                elevation: 2,
                borderRadius: BorderRadius.circular(8.0),
                color: context.theme.lightBlue,
                offset: const Offset(0, 48),
                menuPadding: EdgeInsets.all(8),
                onSelected: (int value) {
                  context.read<NotificationSettingsBloc>().add(
                    RemindBeforeChanged(
                      remindBefore: value,
                      isTeacher: userRole == RoleModel.roleTeacher,
                      authToken: authToken,
                    ),
                  );
                },
                style: ButtonStyle(enableFeedback: false),
                itemBuilder: (BuildContext context) {
                  return remindTimes.map((int choice) {
                    return PopupMenuItem<int>(
                      padding: EdgeInsets.zero,
                      value: choice,
                      child: InkWell(
                        onTap:
                            () => Navigator.pop(
                              context,
                              choice,
                            ), // cần đóng menu và trả value
                        splashColor: Colors.transparent,
                        highlightColor: Colors.grey.withAlpha(25),
                        borderRadius: BorderRadius.circular(4.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                Storage.remindBefore == choice
                                    ? Colors.white
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Center(
                            child: Text(
                              formatTime(choice),
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Storage.examNotification
                            ? context.theme.lightBlue
                            : context.theme.lightGrey,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        Assets.icons.svg.solarBellBold,
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(
                          context.theme.grey!,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Trước',
                        style: TextStyle(
                          color: context.theme.grey,
                          fontSize: FontSizes.medium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 1,
                        color: context.theme.grey,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Text(
                        formatTime(state.remindBefore),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizes.medium,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
