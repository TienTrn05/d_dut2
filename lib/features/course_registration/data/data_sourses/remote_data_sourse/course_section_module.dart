import 'package:injectable/injectable.dart';

@module
abstract class CourseSectionModule {
  @Named('courseRegistrationAPIUrl')
  String get courseRegistrationAPIUrl => "http://10.10.52.52:5283";
}
