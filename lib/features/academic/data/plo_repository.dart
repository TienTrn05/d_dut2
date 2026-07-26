import 'package:injectable/injectable.dart';

import 'plo_service.dart';
import '../models/plo_model.dart';

@injectable
class PLORepository {
  final PLOService _ploService;

  PLORepository(this._ploService);

  Future<List<PLOModel>> getPLO(String token) async {
    try {
      final notifications = await _ploService.getPLO(token);
      return notifications;
    } catch (e) {
      throw Exception('Failed to load PLO: $e');
    }
  }
}
