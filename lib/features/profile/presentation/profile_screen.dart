import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/extensions/custom_theme_extension.dart';
import '../../../common/routes/routes.dart';

import '../../auth/bloc/auth_bloc.dart';
import './widgets/info_card.dart';
import './widgets/info_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLogoutSuccess) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.auth, (route) => false);
        }
      },
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 74 + 10,
              ),
              child: Column(
                children: [
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.theme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              child: Image.network(
                                'https://www.udn.vn/Portals/0/3doan%20bk.jpg',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final String displayName =
                                  (state is AuthUserAuthenticated)
                                      ? state.userData.displayName
                                      : 'No Name';

                              final String userPrincipalName =
                                  (state is AuthUserAuthenticated)
                                      ? state.userData.userPrincipalName
                                      : 'No Email';

                              return Expanded(
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
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      // get string before @
                                      userPrincipalName.split('@').first,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily:
                                            GoogleFonts.notoSans().fontFamily,
                                        fontSize: FontSizes.large,
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      )),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          InfoCart(
                            title: "Thông tin cơ bản",
                            child: Column(
                              children: [
                                InfoItem(
                                    field: "Ngày sinh", value: "21/11/2003"),
                                InfoItem(field: "Giới tính", value: "Nam"),
                                InfoItem(
                                  field: "Số điện thoại",
                                  value: "0337237665",
                                  enabledEdit: true,
                                ),
                                InfoItem(
                                  field: "Email cá nhân",
                                  value: "tranhuutuan26112003@gmail.com",
                                  enabledEdit: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          InfoCart(
                            title: "Thông tin học vấn",
                            child: Column(
                              children: [
                                InfoItem(
                                    field: "Ngành",
                                    value: "Công nghệ thông tin"),
                                InfoItem(field: "Lớp", value: "21TCLC_DT3"),
                                InfoItem(
                                    field: "CTĐT",
                                    value:
                                        "Công nghệ Thông tin K2021CLC Đặc thù_cử nhân_KTMT"),
                                BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                  final String email =
                                      (state is AuthUserAuthenticated)
                                          ? state.userData.mail
                                          : 'Unknown';
                                  return InfoItem(
                                      field: "TK Office365", value: email);
                                })
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          InfoCart(
                            title: "Thông tin liên hệ khẩn cấp",
                            child: Column(
                              children: [
                                InfoItem(
                                  field: "Họ tên/Quan hệ",
                                  value: "Trần Tám/cha",
                                  enabledEdit: true,
                                ),
                                InfoItem(
                                  field: "SĐT",
                                  value: "0377432969",
                                  enabledEdit: true,
                                ),
                                InfoItem(
                                  field: "Số nhà đường",
                                  value: "Tổ dân phố Diên Trường",
                                  enabledEdit: true,
                                ),
                                InfoItem(
                                  field: "Tỉnh/Thành phố",
                                  value: "Thừa Thiên Huế",
                                ),
                                InfoItem(
                                  field: "Huyện/Quận",
                                  value: "Phú Thuận",
                                ),
                                InfoItem(
                                  field: "Xã/Phường",
                                  value: "Thuận An",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 74 + 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {
                  final state = context.read<AuthBloc>().state;
                  if (state is AuthUserAuthenticated) {
                    context
                        .read<AuthBloc>()
                        .add(AuthLogoutRequested(state.userData.mail));
                  }
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
            )
          ],
        ),
      ),
    );
  }
}
