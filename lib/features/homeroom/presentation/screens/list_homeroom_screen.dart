import 'package:auto_route/auto_route.dart';
import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/homeroom/bloc/list_homeroom_bloc.dart';
import 'package:e_dut/features/homeroom/data/model/homeroom_model.dart';
import 'package:e_dut/features/homeroom/presentation/widgets/items/homeroom_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repository/homeroom_repo.dart';

@RoutePage()
class ListHomeroomScreen extends StatefulWidget {
  const ListHomeroomScreen({super.key});

  @override
  State<ListHomeroomScreen> createState() => _ListHomeroomScreenState();
}

class _ListHomeroomScreenState extends State<ListHomeroomScreen> {
  String? selectedCohort;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppbar(label: "Danh sách lớp chủ nhiệm"),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
          final String userRole = authState is AuthUserAuthenticated
              ? authState.userData.role.name
              : '';
          if (userRole == RoleModel.roleTeacher) {
            return BlocProvider(
              create: (context) => ListHomeroomBloc(
                getIt<HomeroomRepository>(),
              )..add(ListHomeroomSubscriptionRequested(
                  token: authState is AuthUserAuthenticated
                      ? authState.accessToken
                      : '')),
              child: SafeArea(child:
                  BlocBuilder<ListHomeroomBloc, ListHomeroomState>(
                      builder: (context, state) {
                if (state is ListHomeroomLoading) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: context.theme.primaryColor,
                  ));
                } else if (state is ListHomeroomError) {
                  return Center(
                      child: Text('Đã có lỗi xảy ra!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: context.theme.grey ?? Colors.grey)));
                } else if (state is ListHomeroomLoaded) {
                  final homerooms = state.homerooms;
                  if (homerooms.isEmpty) {
                    return Center(
                        child: Text('Không có lớp chủ nhiệm nào',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: context.theme.grey ?? Colors.grey)));
                  }

                  // Gom nhóm theo enrollmentYear
                  final Map<String, List<HomeroomModel>> groupedByYear = {};
                  for (final h in homerooms) {
                    groupedByYear
                        .putIfAbsent(h.enrollmentYear, () => [])
                        .add(h);
                  }

                  final cohortList = groupedByYear.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  if (selectedCohort == null && cohortList.isNotEmpty) {
                    selectedCohort = cohortList.first;
                  }

                  final filteredHomerooms = selectedCohort != null
                      ? groupedByYear[selectedCohort!] ?? []
                      : [];

                  final currentIndex = cohortList.indexOf(selectedCohort ?? '');
                  final canGoPrevious = currentIndex > 0;
                  final canGoNext = currentIndex < cohortList.length - 1;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20.0,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 24.0,
                        children: [
                          GestureDetector(
                            onTap: canGoPrevious
                                ? () {
                                    setState(() {
                                      selectedCohort =
                                          cohortList[currentIndex - 1];
                                    });
                                  }
                                : null,
                            child: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                          Expanded(
                            child: InkWell(
                                onTap: () {
                                  _showCohortSelector(context, cohortList);
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(4.0),
                                  child: Center(
                                    child: Text(
                                      'Khóa ${selectedCohort ?? ''}',
                                      style: const TextStyle(
                                        fontSize: FontSizes.medium,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                          GestureDetector(
                            onTap: canGoNext
                                ? () {
                                    setState(() {
                                      selectedCohort =
                                          cohortList[currentIndex + 1];
                                    });
                                  }
                                : null,
                            child: const Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ],
                      ),
                      Text(
                        "${filteredHomerooms.length} lớp chủ nhiệm",
                        style: TextStyle(
                          fontSize: FontSizes.medium,
                          fontWeight: FontWeight.normal,
                          color: context.theme.grey,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            spacing: 4,
                            children: filteredHomerooms.map((homeroom) {
                              return HomeroomItem(homeroom: homeroom);
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Container();
              })),
            );
          } else {
            return Center(
              child: Text(
                'Bạn không có quyền truy cập vào chức năng này',
                style: TextStyle(
                  fontSize: FontSizes.large,
                  fontStyle: FontStyle.normal,
                ),
              ),
            );
          }
        }),
      ),
    );
  }

  void _showCohortSelector(BuildContext context, List<String> cohortList) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  backgroundColor: Colors.transparent,
                  itemExtent: 52,
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (int index) {
                    if (selectedIndex != index) {
                      setState(() {
                        selectedIndex = index;
                        selectedCohort = cohortList[index];
                      });
                    }
                  },
                  selectionOverlay: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.withAlpha(30),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  children: cohortList
                      .map((cohort) => Center(
                            child: Text(
                              'Khóa $cohort',
                              style: const TextStyle(
                                fontSize: FontSizes.large,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
