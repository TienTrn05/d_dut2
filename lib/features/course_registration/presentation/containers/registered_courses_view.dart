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
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              if (state.registeredCoursesStatus ==
                  RegisteredCoursesStatus.failure)
                Center(
                  child: Text(
                    state.errorRegisteredCoursesMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (state.registeredCourses.isEmpty)
                const Center(child: Text('No registered courses'))
              else
                ...state.registeredCourses.map(
                  (course) => RegisteredCourseSectionItem(
                    courseSection: course,
                    onDetail: () {
                      RegisteredCourseSectionDialog.showCustomDialog(
                        context,
                        course,
                        () {
                          context.read<CourseSectionsBloc>().add(
                                UnregisterCourseRequested(
                                  token: (stateAuth as AuthUserAuthenticated)
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
          );
        }),
      );
    });
  }
}
