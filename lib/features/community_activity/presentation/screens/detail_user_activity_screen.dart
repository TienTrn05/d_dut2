import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/activity_info.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
import 'package:flutter/material.dart';

class DetailUserActivityScreen extends StatelessWidget {
  final UserActivityModel userActivity;
  const DetailUserActivityScreen({super.key, required this.userActivity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppbar(label: "Chi tiết hoạt động"),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    (userActivity.activity.image != null)
                        ? Image.network(
                            userActivity.activity.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/default_image.jpg',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/default_image.jpg',
                            fit: BoxFit.cover,
                          ),

                    // Lớp Linear Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withAlpha(56),
                            Colors.black.withAlpha(180)
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            userActivity.activity.id,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: FontSizes.small,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userActivity.activity.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          StatusLabel(
                            statusType: StatusType.userActivity,
                            statusCode: userActivity.status,
                            isFullWidth: false,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userActivity.activity.createdBy,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: FontSizes.small,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userActivity.activity.subcategory.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: FontSizes.small,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
                child: SingleChildScrollView(
              child: ActivityInfo(activity: userActivity.activity),
            ))
          ],
        ),
      ),
    );
  }
}
