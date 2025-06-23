import 'package:injectable/injectable.dart';

@module
abstract class CommunityModule {
  @Named('communityAPIUrl')
  String get communityAPIUrl => "https://doanthanhnien.dev.dut.navia.io.vn";
}
