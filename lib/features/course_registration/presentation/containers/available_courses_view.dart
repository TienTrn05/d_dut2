import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/features/auth/bloc/auth_bloc.dart';

import '../../bloc/course_sections/course_sections_bloc.dart';
import '../../data/models/course_section.dart';
import '../../presentation/widgets/course_card.dart';
import '../../presentation/widgets/course_section_item.dart';
import '../widgets/dialogs/course_section_dialog.dart';

class AvailableCoursesView extends StatefulWidget {
  const AvailableCoursesView({super.key});

  @override
  State<AvailableCoursesView> createState() => _AvailableCoursesViewState();
}

class _AvailableCoursesViewState extends State<AvailableCoursesView> {
  @override
Widget build(BuildContext context) {
  return BlocBuilder<AuthBloc, AuthState>(
    builder: (context, stateAuth) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<CourseSectionsBloc>().add(
                AvailableCourseSectionsSubscriptionRequested(
                  token: (stateAuth as AuthUserAuthenticated).accessToken,
                ),
              );
        },
        color: context.theme.primaryColor,
        backgroundColor: Colors.white,
        child: BlocBuilder<CourseSectionsBloc, CourseSectionsState>(
          builder: (context, state) {
            final groupedCourses = CourseSection.groupByCourse(state.courses);

            // Dùng ListView luôn, dù trạng thái nào
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (state.status == AvailableCoursesStatus.loading)
                  const Center(child: CircularProgressIndicator())
                else if (state.status == AvailableCoursesStatus.failure)
                  Center(
                    child: Text(
                      state.errorCourseSectionMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                else if (groupedCourses.isEmpty)
                  const Center(child: Text('No available courses'))
                else
                  ...groupedCourses.entries.map((entry) {
                    final course = entry.key;
                    final sections = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CourseCard(
                          course: course,
                          child: Column(
                            children: sections
                                .map((section) => CourseSectionItem(
                                      courseSection: section,
                                      onDetail: () {
                                        CourseSectionDialog.showCustomDialog(
                                          context,
                                          section,
                                          () {
                                            context
                                                .read<CourseSectionsBloc>()
                                                .add(
                                                  RegisterCourseRequested(
                                                    token: (stateAuth
                                                            as AuthUserAuthenticated)
                                                        .accessToken,
                                                    courseSectionId:
                                                        section.id,
                                                  ),
                                                );
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
              ],
            );
          },
        ),
      );
    },
  );
}

}
