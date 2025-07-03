import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/activity_icon_path.dart';
import 'package:e_dut/features/community_activity/constant/user_activity_status.dart';
import 'package:e_dut/features/community_activity/data/model/user_proof_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/cards/user_proof_card.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class UserScores extends StatefulWidget {
  const UserScores({super.key});

  @override
  State<UserScores> createState() => _UserScoresState();
}

class _UserScoresState extends State<UserScores> {
  List<UserProofModel> userScores = [];
  bool _isInitialized = false;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool sortAscending = false;

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      final keyword = _searchController.text.trim();
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthUserAuthenticated) {
        final accessToken = authState.accessToken;
        context.read<CommunityActivityBloc>().add(
              LoadUserProofs(
                token: accessToken,
                keyword: keyword,
              ),
            );
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  List<UserProofModel> get filteredScores {
    final filtered = userScores;

    filtered.sort((a, b) {
      final aValue = a.userActivity.activity.score;
      final bValue = b.userActivity.activity.score;

      if (sortAscending) {
        return aValue.compareTo(bValue);
      } else {
        return bValue.compareTo(aValue);
      }
    });
    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bloc = context.read<CommunityActivityBloc>();
        final authState = context.read<AuthBloc>().state;

        if (authState is AuthUserAuthenticated) {
          final accessToken = authState.accessToken;
          bloc.add(LoadUserProofs(
            token: accessToken,
            keyword: _searchController.text.trim(),
          ));
        }
      });
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        BlocBuilder<CommunityActivityBloc, CommunityActivityState>(
            builder: (context, state) {
          if (state is CommunityActivityLoading) {
            return CustomLoadingIndicator.primary();
          }
          return const SizedBox.shrink();
        }),
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchTextField(
                  controller: _searchController,
                  onFilterPressed: () {
                    setState(() {
                      sortAscending = !sortAscending;
                    });
                  },
                  iconUrl: sortAscending
                      ? 'assets/icons/svg/lucide_sort-asc.svg'
                      : 'assets/icons/svg/lucide_sort-desc.svg',
                  textColor: context.theme.grey ?? Colors.grey),
              const SizedBox(height: 20),
              BlocBuilder<CommunityActivityBloc, CommunityActivityState>(
                  buildWhen: (previous, current) =>
                      current is UserProofsLoaded ||
                      current is CommunityActivityError,
                  builder: (context, state) {
                    if (state is UserProofsLoaded) {
                      userScores = state.userProofs
                          .where((proof) =>
                              proof.userActivity.status ==
                              UserActivityStatus.approved)
                          .toList();
                      final totalScore = userScores.fold<int>(
                        0,
                        (sum, proof) => sum + proof.userActivity.activity.score,
                      );

                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding:
                                const EdgeInsets.only(bottom: 4, right: 16),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: context.theme.grey ??
                                            Colors.grey))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tổng điểm',
                                  style: TextStyle(
                                      fontSize: FontSizes.medium,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      ActivityIconPath.score,
                                      colorFilter: const ColorFilter.mode(
                                        Color(0XFFFFFF01),
                                        BlendMode.srcIn,
                                      ),
                                      width: 13,
                                      height: 13,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      totalScore.toString(),
                                      style: TextStyle(
                                          fontSize: FontSizes.medium,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: filteredScores
                                .map((proof) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: UserProofCard(
                                        nameActivity:
                                            proof.userActivity.activity.name,
                                        score:
                                            proof.userActivity.activity.score,
                                      ),
                                    ))
                                .toList(),
                          )
                        ],
                      );
                    } else if (state is CommunityActivityError) {
                      return const Center(
                          child:
                              Text('Không thể tải dữ liệu minh chứng của tôi'));
                    } else {
                      return const SizedBox.shrink();
                    }
                  })
            ],
          ),
        ))
      ],
    ));
  }
}
