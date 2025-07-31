import 'package:e_dut/features/community_activity/data/model/user_proof_model.dart';

class ProofsPagedModel {
  final List<UserProofModel> proofs;
  final int total;
  final String page;
  final String limit;

  ProofsPagedModel(
      {required this.proofs,
      required this.total,
      required this.page,
      required this.limit});

  factory ProofsPagedModel.fromJson(Map<String, dynamic> json) {
    return ProofsPagedModel(
        proofs: json['proofs'] != null
            ? (json['proofs'] as List)
                .map((proof) => UserProofModel.fromJson(proof))
                .toList()
            : [],
        total: (json['total'] as int?) ?? 0,
        page: json['page'] ?? '',
        limit: json['limit'] ?? '');
  }
}
