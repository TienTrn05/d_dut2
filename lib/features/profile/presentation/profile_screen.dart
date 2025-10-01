import 'package:e_dut/core/bloc/notification_settings/notification_settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/widgets/dialog/custom_alert_dialog.dart';
import '/common/extensions/font_sizes.dart';
import '/common/extensions/custom_theme_extension.dart';
import '/common/routes/routes.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/data/model/role_model.dart';
import './widgets/student_profile.dart';
import './widgets/teacher_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLogoutSuccess) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.auth, (route) => false);
        }
      },
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: 74 + 10,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.theme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final String displayName =
                            (state is AuthUserAuthenticated)
                                ? state.userData.displayName
                                : 'No Name';

                        final String userPrincipalName =
                            (state is AuthUserAuthenticated)
                                ? state.userData.userPrincipalName
                                : 'No Email';

                        final String userRole =
                            state is AuthUserAuthenticated
                                ? state.userData.role.name
                                : '';
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                // shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                child:
                                    userRole == "Student" &&
                                            userPrincipalName.endsWith(
                                              "@sv1.dut.udn.vn",
                                            )
                                        ? Image.network(
                                          'https://cb.dut.udn.vn/ImageSV/${userPrincipalName.substring(3, 5)}/${userPrincipalName.substring(0, 9)}.jpg',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Image.asset(
                                              'assets/images/default_avatar.jpg',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                        : Image.asset(
                                          'assets/images/default_avatar.jpg',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily:
                                          GoogleFonts.notoSans().fontFamily,
                                      fontSize: FontSizes.extraLarge,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userPrincipalName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily:
                                          GoogleFonts.notoSans().fontFamily,
                                      fontSize: FontSizes.medium,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final userRole =
                          (authState is AuthUserAuthenticated)
                              ? authState.userData.role.name
                              : '';
                      return Expanded(
                        child:
                            userRole == RoleModel.roleStudent
                                ? StudentProfile()
                                : TeacherProfile(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 74 + 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () async {
                  CustomAlertDialog.showCustomDialog(
                    context,
                    'Đăng xuất tài khoản',
                    'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản của mình không?',
                    AlertDialogType.confirm,
                    onConfirm: () {
                      final state = context.read<AuthBloc>().state;
                      if (state is AuthUserAuthenticated) {
                        context.read<AuthBloc>().add(
                          AuthLogoutRequested(state.userData.mail),
                        );

                        context.read<NotificationSettingsBloc>().add(
                          RemindBeforeChanged(
                            remindBefore: 15,
                            authToken: state.accessToken,
                            isTeacher:
                                state.userData.role.name ==
                                RoleModel.roleTeacher,
                          ),
                        );
                      }
                    },
                    textConfirm: "Đăng xuất",
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: context.theme.primaryColor,
                  elevation: 2,
                ),
                child: SvgPicture.asset(
                  "assets/icons/svg/solar_logout-3-bold.svg",
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
