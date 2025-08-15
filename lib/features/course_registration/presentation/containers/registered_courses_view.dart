import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/features/auth/bloc/auth_bloc.dart';

import '../../bloc/course_sections/course_sections_bloc.dart';
import '../../presentation/widgets/registered_course_section_item.dart';
import '../widgets/dialogs/registered_course_section_dialog.dart';

class RegisteredCoursesView extends StatefulWidget {
  const RegisteredCoursesView({super.key});

  @override
  State<RegisteredCoursesView> createState() => _RegisteredCoursesViewState();
}

class _RegisteredCoursesViewState extends State<RegisteredCoursesView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, stateAuth) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<CourseSectionsBloc>().add(
                RegisteredCourseSectionSubscriptionRequested(
                  token: (stateAuth as AuthUserAuthenticated).accessToken,
                ),
              );
        },
        color: context.theme.primaryColor,
        backgroundColor: Colors.white,
        child: BlocBuilder<CourseSectionsBloc, CourseSectionsState>(
            builder: (context, state) {
          if (state.registeredCoursesStatus ==
              RegisteredCoursesStatus.loading) {
            return Center(
                child: CircularProgressIndicator(
              color: context.theme.primaryColor,
            ));
          }

          var numOfRegisteredCredits = state.registeredCourses.fold<int>(
              0,
              (sum, courseSections) =>
                  sum +
                  (courseSections.isRegistering
                      ? 0
                      : courseSections.course.credits));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                "Số tín chỉ tối đa cho phép đăng ký: ${30}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.theme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (state.registeredCoursesStatus ==
                            RegisteredCoursesStatus.failure)
                          Center(
                            child: Text(
                              state.errorRegisteredCoursesMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        else
                          // Hiển thị các học phần đã đăng ký
                          const Text(
                            'Các học phần đã đăng ký',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          "$numOfRegisteredCredits tín chỉ",
                          style: TextStyle(
                            fontSize: 14,
                            color: context.theme.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    state.registeredCourses
                            .where((c) => !c.isRegistering)
                            .isEmpty
                        ? const Center(
                            child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Bạn chưa đăng ký học phần nào!'),
                          ))
                        : const SizedBox.shrink(),
                    ...state.registeredCourses
                        .where((c) => !c.isRegistering)
                        .map(
                          (course) => RegisteredCourseSectionItem(
                            courseSection: course,
                            onDetail: () {
                              RegisteredCourseSectionDialog.showCustomDialog(
                                context,
                                course,
                                () {
                                  context.read<CourseSectionsBloc>().add(
                                        UnregisterCourseRequested(
                                          token: (stateAuth
                                                  as AuthUserAuthenticated)
                                              .accessToken,
                                          courseSectionId: course.id,
                                        ),
                                      );
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                    const SizedBox(height: 20),
                    const Text(
                      'Các học phần đang đăng ký',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    state.registeredCourses
                            .where((c) => c.isRegistering)
                            .isEmpty
                        ? const Center(
                            child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child:
                                Text('Bạn không có học phần nào đang đăng ký!'),
                          ))
                        : const SizedBox.shrink(),
                    ...state.registeredCourses
                        .where((c) => c.isRegistering)
                        .map(
                          (course) => RegisteredCourseSectionItem(
                            courseSection: course,
                            onDetail: () {
                              RegisteredCourseSectionDialog.showCustomDialog(
                                context,
                                course,
                                () {
                                  context.read<CourseSectionsBloc>().add(
                                        UnregisterCourseRequested(
                                          token: (stateAuth
                                                  as AuthUserAuthenticated)
                                              .accessToken,
                                          courseSectionId: course.id,
                                        ),
                                      );
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                  ],
                ),
              ),
            ],
          );
        }),
      );
    });
  }
}
