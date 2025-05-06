import 'package:e_dut/features/course_registration/bloc/available_courses/available_courses_bloc.dart';
import 'package:e_dut/features/course_registration/data/models/course_section.dart';
import 'package:e_dut/features/course_registration/presentation/widgets/course_card.dart';
import 'package:e_dut/features/course_registration/presentation/widgets/course_section_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvailableCoursesView extends StatefulWidget {
  const AvailableCoursesView({super.key});

  @override
  State<AvailableCoursesView> createState() => _AvailableCoursesViewState();
}

class _AvailableCoursesViewState extends State<AvailableCoursesView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvailableCoursesBloc, AvailableCoursesState>(
        builder: (context, state) {
      final groupedCourses = CourseSection.groupByCourse(state.courses);

      if (state.status == AvailableCoursesStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state.status == AvailableCoursesStatus.failure) {
        return Center(
          child: Text(
            state.errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        );
      } else if (groupedCourses.isEmpty) {
        return const Center(child: Text('No available courses'));
      }

      return ListView(
        children: groupedCourses.entries.map((entry) {
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
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      );
    });
  }
}
