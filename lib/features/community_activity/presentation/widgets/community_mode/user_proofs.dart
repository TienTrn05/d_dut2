import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart'
    show CustomLoadingIndicator;
import 'package:e_dut/common/widgets/modal/bottom_modal.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/user_proof_status.dart';
import 'package:e_dut/features/community_activity/data/model/user_proof_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/cards/user_proof_card.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProofs extends StatefulWidget {
  const UserProofs({super.key});

  @override
  State<UserProofs> createState() => _UserProofsState();
}

class _UserProofsState extends State<UserProofs> {
  List<UserProofModel> userProofs = [];
  bool _isInitialized = false;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthUserAuthenticated) {
        final accessToken = authState.accessToken;
        context.read<CommunityActivityBloc>().add(
              LoadUserProofs(
                token: accessToken,
                keyword: _searchController.text.trim(),
              ),
            );
      }
    });
  }

  bool sortAscending = false;
  Set<String> selectedStateFilters = {};

  List<UserProofModel> get filteredProofs {
    final filtered = userProofs.where((proof) {
      final matchStatus = selectedStateFilters.isEmpty ||
          selectedStateFilters.contains(proof.userActivity.status);
      return matchStatus;
    }).toList();

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
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
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
                  onFilterPressed: () => _showFilterModal(context),
                  iconUrl: 'assets/icons/svg/tabler_filter-search.svg',
                  textColor: context.theme.grey ?? Colors.grey),
              const SizedBox(height: 20),
              BlocBuilder<CommunityActivityBloc, CommunityActivityState>(
                  buildWhen: (previous, current) =>
                      current is UserProofsLoaded ||
                      current is CommunityActivityError,
                  builder: (context, state) {
                    if (state is UserProofsLoaded) {
                      userProofs = state.userProofs;
                      return Column(
                        children: filteredProofs
                            .map((proof) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: UserProofCard(
                                    nameActivity:
                                        proof.userActivity.activity.name,
                                    score: proof.userActivity.activity.score,
                                    status: proof.userActivity.status,
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                          Routes.detailUserProof,
                                          arguments: proof);
                                    },
                                  ),
                                ))
                            .toList(),
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

  void _showFilterModal(BuildContext context) {
    Set<String> localSelectedState = {...selectedStateFilters};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (modalContext, setModalState) {
          return BottomModal(
            title: "Sắp xếp và lọc",
            mainActionText: "Áp dụng",
            mainAction: () {
              setState(() {
                selectedStateFilters = localSelectedState;
              });

              Navigator.pop(modalContext);
            },
            onCloseText: "Đặt lại",
            onClose: () {
              setModalState(() {
                localSelectedState.clear();
                sortAscending = false;
              });

              setState(() {
                selectedStateFilters.clear();
              });
            },
            heightFactor: 0.7,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sortField(setModalState),
                  const SizedBox(height: 24),
                  _stateFilter(localSelectedState, setModalState),
                ],
              ),
            ),
          );
        });
      },
    ).whenComplete(() {
      selectedStateFilters = localSelectedState;
    });
  }

  Widget _sortField(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sắp xếp",
          style: TextStyle(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: context.theme.lightGrey,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Điểm số',
                      style: TextStyle(
                        color: context.theme.grey,
                        fontSize: FontSizes.small,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
            SizedBox(
              height: 48,
              child: TextButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
                  backgroundColor:
                      WidgetStateProperty.all(context.theme.lightGrey),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  minimumSize: WidgetStateProperty.all(const Size(48, 48)),
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
                onPressed: () {
                  setModalState(() {
                    sortAscending = !sortAscending;
                  });
                },
                child: SvgPicture.asset(
                  sortAscending
                      ? "assets/icons/svg/lucide_sort-asc.svg"
                      : "assets/icons/svg/lucide_sort-desc.svg",
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _stateFilter(
      Set<String> localSelectedState, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Trạng thái",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: UserProofStatus.keys.map((statusKey) {
            final bool isSelected = localSelectedState.contains(statusKey);
            final style = UserProofStatus.styles[statusKey];
            final label = style?.label ?? statusKey;

            return TextButton(
              onPressed: () {
                setModalState(() {
                  if (isSelected) {
                    localSelectedState.remove(statusKey);
                  } else {
                    localSelectedState.add(statusKey);
                  }
                });
              },
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w400, fontSize: FontSizes.small),
                backgroundColor: isSelected
                    ? context.theme.primaryColor
                    : context.theme.lightGrey,
                foregroundColor: isSelected ? Colors.white : context.theme.grey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
