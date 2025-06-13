import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/bloc/auth_bloc.dart';
import '/common/extensions/font_sizes.dart';
import '/common/extensions/custom_theme_extension.dart';
import '/common/utils/getit_utils.dart';

import '../bloc/grade_bloc.dart';
import '../data/models/grade.dart';
import '../domain/repositories/grade_repository.dart';
import './widgets/grade_list_tile.dart';
import '../utils/grade_utils.dart';

class GradeScreen extends StatelessWidget {
  const GradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context2, state) {
      if (state is! AuthUserAuthenticated) {
        return Center(
          child: Text(
            'Bạn cần đăng nhập để sử dụng tính năng này.',
            style: TextStyle(fontSize: FontSizes.large),
          ),
        );
      }

      return BlocProvider(
        create: (context) =>
            GradeBloc(gradeRepository: getIt.get<GradeRepository>())
              ..add(GradesSubscriptionRequested(token: state.accessToken)),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: context.theme.primaryColor ?? Colors.blue,
            elevation: 0, // Xóa bóng dưới AppBar
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: IconButton(
                icon:
                    Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Quay lại màn hình trước
                },
              ),
            ),
            title: Text(
              'Điểm đã học',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: FontSizes.medium,
              ),
            ),
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: BlocBuilder<GradeBloc, GradeState>(
            builder: (context, state) {
              if (state.status == GradeStatus.loading) {
                return Center(
                    child: CircularProgressIndicator(
                  color: context.theme.primaryColor,
                ));
              } else if (state.status == GradeStatus.success) {
                final grades = state.grades;

                if (grades.isEmpty) {
                  return Center(
                    child: Text(
                      'Không có điểm để hiển thị.',
                      style: TextStyle(fontSize: FontSizes.medium),
                    ),
                  );
                }

                var gradeGrouped = Grade.groupBySemesterCode(grades);

                return RefreshIndicator(
                  color: context.theme.primaryColor,
                  onRefresh: () async {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthUserAuthenticated) {
                      context.read<GradeBloc>().add(
                            GradesSubscriptionRequested(
                                token: authState.accessToken),
                          );
                    }
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: gradeGrouped.entries.map((entry) {
                        final semesterCode = entry.key;
                        final grades = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                GradeUtils.getSemesterStr(semesterCode),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSizes.medium,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: grades.length,
                              itemBuilder: (context, index) {
                                final grade = grades[index];
                                return GradeListTile(grade: grade);
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              } else if (state.status == GradeStatus.failure) {
                return Center(
                  child: Text(
                    'Đã xảy ra lỗi khi tải điểm.\n${state.errorMessage}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: FontSizes.medium),
                  ),
                );
              }

              return const SizedBox.shrink(); // Default empty view
            },
          ),
        ),
      );
    });
  }
}
