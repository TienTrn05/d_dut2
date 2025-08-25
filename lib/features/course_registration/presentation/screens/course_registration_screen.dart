import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/widgets/snackbar/custom_snackbar.dart';
import '/common/extensions/font_sizes.dart';
import '/common/extensions/custom_theme_extension.dart';
import '/common/utils/getit_utils.dart';
import '/common/routes/routes.dart';
import '/features/auth/bloc/auth_bloc.dart';

import '../../domain/repositories/course_section_repository.dart';
import '../../domain/repositories/registration_signalr_repository.dart';
import '../../bloc/course_sections/course_sections_bloc.dart';
import '../../bloc/registration_signalr/registration_signalr_bloc.dart';
import '../containers/available_courses_view.dart';
import '../containers/registered_courses_view.dart';
import '../widgets/buttons/grade_button.dart';

class CourseRegistrationScreen extends StatelessWidget {
  const CourseRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context2, state) {
      if (state is! AuthUserAuthenticated) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: context.theme.primaryColor ?? Colors.blue,
              elevation: 0, // Xóa bóng dưới AppBar
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context); // Quay lại màn hình trước
                  },
                ),
              ),
              title: Text(
                'Đăng ký lớp học phần',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSizes.medium,
                ),
              ),
              centerTitle: true,
            ),
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Bạn cần đăng nhập để sử dụng tính năng này.',
                  style: TextStyle(
                      color: context.theme.grey!, fontSize: FontSizes.large),
                  textAlign: TextAlign.center,
                ),
              ),
            ));
      }

      return MultiBlocProvider(
        providers: [
          BlocProvider<CourseSectionsBloc>(
            create: (context) => CourseSectionsBloc(
              courseRepository: getIt.get<CourseSectionRepository>(),
            )
              ..add(AvailableCourseSectionsSubscriptionRequested(
                token: state.accessToken,
              ))
              ..add(RegisteredCourseSectionSubscriptionRequested(
                token: state.accessToken,
              )),
          ),
          BlocProvider<RegistrationSignalRBloc>(
            create: (context) => RegistrationSignalRBloc(
              getIt.get<RegistrationSignalRRepository>(),
            ),
          ),
        ],
        child: BlocListener<CourseSectionsBloc, CourseSectionsState>(
          listener: (context, state) {
            if (state.registrationStatus == RegistrationStatus.success) {
              CustomSnackbar.showSnackBar(
                context,
                "Thành công",
                state.registrationMessage.isNotEmpty
                    ? state.registrationMessage
                    : "Đăng ký khóa học thành công!",
                AlertType.success,
              );
            } else if (state.registrationStatus == RegistrationStatus.failure) {
              CustomSnackbar.showSnackBar(
                context,
                "Thất bại",
                state.errorCourseSectionMessage.isNotEmpty
                    ? state.errorCourseSectionMessage
                    : "Đăng ký khóa học thất bại!",
                AlertType.error,
              );
            }
          },
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: context.theme.primaryColor ?? Colors.blue,
                elevation: 0, // Xóa bóng dưới AppBar
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Quay lại màn hình trước
                    },
                  ),
                ),
                title: Text(
                  'Đăng ký lớp học phần',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSizes.medium,
                  ),
                ),
                centerTitle: true,
                actions: true
                    ? []
                    : [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GradeButton(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(Routes.courseRegistrationGrade);
                            },
                          ),
                        ),
                      ],
              ),
              backgroundColor: Colors.white,
              body: true
                  ? Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/svg/hugeicons_note-edit.svg",
                              width: 54,
                              height: 54,
                              colorFilter: ColorFilter.mode(
                                  context.theme.grey!, BlendMode.srcIn),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Hiện không phải thời gian đăng ký tín chỉ.',
                              style: TextStyle(
                                  color: context.theme.grey!,
                                  fontSize: FontSizes.large),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  )
                  : Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          TabBar(
                              labelPadding: EdgeInsets.all(
                                  0), // Khoảng cách giữa chữ và tab
                              dividerColor: context
                                  .theme.primaryColor, // Màu đường chia tab
                              indicator: BoxDecoration(
                                color: context.theme
                                    .primaryColor, // Màu nền tab được chọn
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                              labelColor:
                                  Colors.white, // Màu chữ của tab được chọn
                              unselectedLabelColor: context
                                  .theme.grey, // Màu chữ của tab chưa chọn
                              tabs: [
                                Tab(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Center(
                                      child: Text("Học phần",
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Center(
                                      child: Text("Đã đăng ký",
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                  ),
                                ),
                              ]),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: TabBarView(
                                children: [
                                  AvailableCoursesView(), // Nội dung tab 1
                                  RegisteredCoursesView(), // Nội dung tab 2
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }
}
