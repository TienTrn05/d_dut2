import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/extensions/font_sizes.dart';
import '/common/routes/routes.dart';
import '/common/utils/getit_utils.dart';

import '../../data/domain/repositories/course_section_repository.dart';
import '../../../dashboard/presentation/widgets/notification_button.dart';
import '../../bloc/available_courses/available_courses_bloc.dart';
import '../containers/available_courses_view.dart';
import '../containers/registered_courses_view.dart';
import '/common/extensions/custom_theme_extension.dart';

class CourseRegistrationScreen extends StatelessWidget {
  const CourseRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AvailableCoursesBloc>(
          create: (context) => AvailableCoursesBloc(
            courseRepository: getIt.get<CourseSectionRepository>(),
          )..add(AvailableCoursesSubscriptionRequested(
              studentCardNumber: "105210028", academicYearCode: "2410")),
        ),
        // BlocProvider<RegisteredCoursesBloc>(
        //   create: (context) => RegisteredCoursesBloc(
        //     courseSectionService: context.read<CourseSectionService>(),
        //   )..add(LoadRegisteredCoursesEvent()),
        // ),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: context.theme.primaryColor ?? Colors.blue,
            elevation: 0, // Xóa bóng dưới AppBar
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: IconButton(
                icon:
                    Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
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
            actions: [
              NotificationButton(
                notificationCount: 2,
                onTap: () =>
                    {Navigator.of(context).pushNamed(Routes.notification)},
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TabBar(
                    labelPadding:
                        EdgeInsets.all(0), // Khoảng cách giữa chữ và tab
                    dividerColor:
                        context.theme.primaryColor, // Màu đường chia tab
                    indicator: BoxDecoration(
                      color:
                          context.theme.primaryColor, // Màu nền tab được chọn
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    labelColor: Colors.white, // Màu chữ của tab được chọn
                    unselectedLabelColor:
                        context.theme.grey, // Màu chữ của tab chưa chọn
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
    );
  }
}
