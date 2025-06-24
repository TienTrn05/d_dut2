import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/features/community_activity/constant/activity_icon_path.dart';
import 'package:e_dut/features/community_activity/constant/activity_status.dart';
import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/items/activity_detail_item.dart';
import 'package:e_dut/features/community_activity/util/functions.dart';
import 'package:flutter/material.dart';

class DetailActivityScreen extends StatelessWidget {
  final ActivityModel activity;
  const DetailActivityScreen({super.key, required this.activity});

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
                    (activity.image != null)
                        ? Image.network(
                            activity.image!,
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
                            activity.id,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: FontSizes.small,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activity.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          StatusLabel(
                            statusType: StatusType.activity,
                            statusCode: activity.status ?? '',
                            isFullWidth: false,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activity.createdBy,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: FontSizes.small,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activity.subcategory.name,
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
              child: Column(
                children: [
                  ActivityDetailItem(
                    title: "Ngày diễn ra",
                    content:
                        "Bắt đầu: ${Functions.formatDate(activity.startDate)} \nKết thúc: ${Functions.formatDate(activity.endDate)}",
                    iconPath: ActivityIconPath.calendar,
                  ),
                  const SizedBox(height: 10),
                  ActivityDetailItem(
                    title: "Ngày đăng ký",
                    content:
                        "Bắt đầu: ${Functions.formatDate(activity.startRegistration)} \nKết thúc: ${Functions.formatDate(activity.endRegistration)}",
                    iconPath: ActivityIconPath.registration,
                  ),
                  const SizedBox(height: 10),
                  ActivityDetailItem(
                    title: "Địa điểm",
                    content: activity.address,
                    iconPath: ActivityIconPath.location,
                  ),
                  const SizedBox(height: 10),
                  ActivityDetailItem(
                    title: "Người tham gia",
                    content:
                        "Tối đa: ${activity.maxParticipants} \nĐã đăng ký: ${activity.participants}",
                    iconPath: ActivityIconPath.participants,
                  ),
                  const SizedBox(height: 10),
                  ActivityDetailItem(
                    title: "Điểm số",
                    content: activity.score.toString(),
                    iconPath: ActivityIconPath.score,
                  ),
                  const SizedBox(height: 10),
                  ActivityDetailItem(
                    title: "Bên ngoài",
                    content: activity.isExternal ? "Có" : "Không",
                    iconPath: ActivityIconPath.external,
                  ),
                ],
              ),
            )),
            if (activity.status == ActivityStatus.registrationOpen)
              Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                        color: context.theme.primaryColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: GestureDetector(
                        onTap: () {
                          // Xử lý khi nhấn nút
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Đăng ký",
                            style: TextStyle(
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
