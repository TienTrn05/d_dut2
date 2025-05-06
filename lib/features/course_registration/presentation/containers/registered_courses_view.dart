import 'package:flutter/material.dart';

class RegisteredCoursesView extends StatefulWidget {
  const RegisteredCoursesView({super.key});

  @override
  State<RegisteredCoursesView> createState() => _RegisteredCoursesViewState();
}

class _RegisteredCoursesViewState extends State<RegisteredCoursesView> {
  final List<String> courses = [
    'Course 1',
    'Course 2',
    'Course 3',
    'Course 4',
    'Course 5',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(courses[index]),
          onTap: () {
            // Handle course selection
          },
        );
      },
    );
  }
}
