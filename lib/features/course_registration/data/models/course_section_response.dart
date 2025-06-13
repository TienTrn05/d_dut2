import 'course_section.dart';

enum RegistrationPhase { group, cohort, global }

class CourseSectionResponse {
  final List<CourseSection> courseSections;
  final RegistrationPhase registrationPhase;

  CourseSectionResponse({
    required this.courseSections,
    required this.registrationPhase,
  });

  factory CourseSectionResponse.fromJson(Map<String, dynamic> json) {
    return CourseSectionResponse(
      courseSections: (json['data'] as List<dynamic>)
          .map((e) => CourseSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      registrationPhase: RegistrationPhase.values.firstWhere(
        (e) => e.toString().toLowerCase() == 'RegistrationPhase.${json['metadata']['registrationType']}'.toLowerCase(),
        orElse: () => RegistrationPhase.group,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sections': courseSections.map((e) => e.toJson()).toList(),
      'registrationPhase': registrationPhase.toString().split('.').last,
    };
  }
}