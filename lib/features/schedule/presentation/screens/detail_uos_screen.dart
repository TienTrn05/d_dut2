import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/common/widgets/snackbar/custom_snackbar.dart';
import 'package:e_dut/features/dashboard/presentation/widgets/notification_button.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_item.dart';
import 'package:e_dut/features/schedule/data/model/study_shift_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/cards/absents_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/items/uos_info_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/cards/uos_info_card.dart';
import 'package:e_dut/features/schedule/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailUnitOfStudy extends StatelessWidget {
  final String idSubject;

  const DetailUnitOfStudy({super.key, required this.idSubject});

  @override
  Widget build(BuildContext context) {
    // Map<String, List<String>> timetable = Functions.analyzeStudyShifts([
    //   StudyShiftModel(
    //       dayOfWeek: 1,
    //       startPeriod: 1,
    //       endPeriod: 3,
    //       startWeek: 3,
    //       endWeek: 18,
    //       room: "E201A"),
    //   StudyShiftModel(
    //       dayOfWeek: 2,
    //       startPeriod: 1,
    //       endPeriod: 3,
    //       startWeek: 3,
    //       endWeek: 19,
    //       room: "E201A"),
    //   StudyShiftModel(
    //       dayOfWeek: 3,
    //       startPeriod: 1,
    //       endPeriod: 3,
    //       startWeek: 3,
    //       endWeek: 19,
    //       room: "E201A"),
    // ]);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: context.theme.primaryColor ?? Colors.blue,
        elevation: 0, // Xóa bóng dưới AppBar
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Quay lại màn hình trước
            },
          ),
        ),
        title: Text(
          'Thông tin chi tiết học phần',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.medium,
          ),
        ),
        centerTitle: true,
        actions: [
          NotificationButton(
            notificationCount: 2,
            onTap: () => {Navigator.of(context).pushNamed(Routes.notification)},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lập trình di động',
              style: TextStyle(
                fontSize: FontSizes.extraLarge,
                fontWeight: FontWeight.bold,
                height: 1.25,
                color: context.theme.primaryColor ?? Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  UosInfoCard(
                    title: 'Thông tin chung',
                    child: Column(
                      children: [
                        InfoItem(
                            field: "Mã lớp học phần",
                            value: "1022101897.21.11"),
                        InfoItem(field: "Mã môn", value: "123456"),
                        InfoItem(
                          field: "Hệ",
                          value: "CLC",
                        ),
                        InfoItem(
                          field: "Số tín chỉ",
                          value: "03",
                        ),
                        InfoItem(
                          field: "Kỳ học",
                          value: "Học kì 1, 2025-2026",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  UosInfoCard(
                    title: 'Giảng dạy',
                    child: Column(
                      children: [
                        InfoItem(field: "Giảng viên", value: "Đặng Thiên Bình"),
                        InfoItem(
                            field: "Hình thức GD", value: "Offline & Online"),
                        UosInfoItem(
                          field: "Mã truy cập",
                          value: Text(
                            "012ajsh",
                            style: TextStyle(
                              fontSize: FontSizes.medium,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.5,
                            ),
                          ),
                          linkIconAsset: "assets/icons/svg/lucide_copy.svg",
                          action: () {
                            try {
                              Clipboard.setData(ClipboardData(text: "012ajsh"));
                              // debugPrint("Copied: 012ajsh");
                              CustomSnackbar.showSnackBar(
                                context,
                                "Thành công",
                                "Đã sao chép mã 012ajsh",
                                AlertType.success,
                              );
                            } catch (e) {
                              CustomSnackbar.showSnackBar(
                                context,
                                "Lỗi",
                                "Không thể sao chép",
                                AlertType.error,
                              );
                            }
                          },
                        ),
                        UosInfoItem(
                          field: "Link tham gia",
                          value: GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse(
                                  "https://teams.microsoft.com/l/team/19%3Ad2pYw4aOqMVmggq1SStgmgoce9mEfA73aKGb_UzJbzQ1%40thread.tacv2/conversations?groupId=c2aeacc4-5d26-466b-a6be-ffb69ccfe8de&tenantId=42350984-d0f6-4a38-978a-aa84e495e429");
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else if (context.mounted) {
                                CustomSnackbar.showSnackBar(
                                  context,
                                  "Lỗi",
                                  "Không thể truy cập link",
                                  AlertType.error,
                                );
                              }
                            },
                            child: Text(
                              "Link tham gia Teams",
                              style: TextStyle(
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.w400,
                                color:
                                    context.theme.primaryColor ?? Colors.blue,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    context.theme.primaryColor ?? Colors.blue,
                                height: 1.5,
                              ),
                            ),
                          ),
                          linkIconAsset: "assets/icons/svg/lucide_copy.svg",
                          action: () {
                            try {
                              Clipboard.setData(ClipboardData(
                                  text:
                                      "https://teams.microsoft.com/l/team/19%3Ad2pYw4aOqMVmggq1SStgmgoce9mEfA73aKGb_UzJbzQ1%40thread.tacv2/conversations?groupId=c2aeacc4-5d26-466b-a6be-ffb69ccfe8de&tenantId=42350984-d0f6-4a38-978a-aa84e495e429"));
                              // debugPrint("Copied: 012ajsh");
                              CustomSnackbar.showSnackBar(
                                context,
                                "Thành công",
                                "Đã sao chép đường link",
                                AlertType.success,
                              );
                            } catch (e) {
                              CustomSnackbar.showSnackBar(
                                context,
                                "Lỗi",
                                "Không thể sao chép",
                                AlertType.error,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  UosInfoCard(
                    title: 'Đánh giá',
                    child: Column(
                      children: [
                        UosInfoItem(
                            field: "Số lần vắng",
                            value: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const AbsentsCard(
                                      isTeacher: false,
                                      absentDates: [
                                        "10/09/2023",
                                        "11/09/2023"
                                      ]),
                                );
                              },
                              child: Text(
                                "3",
                                style: TextStyle(
                                  fontSize: FontSizes.medium,
                                  fontWeight: FontWeight.bold,
                                  color: context.theme.red ?? Colors.red,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      context.theme.red ?? Colors.red,
                                  height: 1.5,
                                ),
                              ),
                            )),
                        InfoItem(
                            field: "Công thức điểm",
                            value: "[GK]*0.20+[BT]*0.20+[CK]*0.60"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // UosInfoCard(
                  //   title: 'Lịch học',
                  //   child: Column(
                  //       children: timetable.entries.map((entry) {
                  //     return Padding(
                  //       padding: const EdgeInsets.only(top: 8),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text(
                  //             'Tuần ${entry.key}',
                  //             style: TextStyle(
                  //               fontWeight: FontWeight.bold,
                  //               fontSize: FontSizes.medium,
                  //             ),
                  //           ),
                  //           const SizedBox(height: 4),
                  //           ...entry.value.map((shiftStr) {
                  //             return Padding(
                  //               padding:
                  //                   const EdgeInsets.symmetric(horizontal: 8),
                  //               child: Container(
                  //                 padding: const EdgeInsets.only(left: 10),
                  //                 decoration: BoxDecoration(
                  //                   border: Border(
                  //                     left: BorderSide(
                  //                       color:
                  //                           context.theme.grey ?? Colors.grey,
                  //                       width: 1,
                  //                     ),
                  //                   ),
                  //                 ),
                  //                 child: Text(
                  //                   shiftStr,
                  //                   style: TextStyle(
                  //                     color: context.theme.grey ?? Colors.grey,
                  //                     fontSize: FontSizes.medium,
                  //                   ),
                  //                 ),
                  //               ),
                  //             );
                  //           }),
                  //         ],
                  //       ),
                  //     );
                  //   }).toList()),
                  // ),

                  const SizedBox(height: 10),
                  UosInfoCard(
                    title: 'Lịch thi',
                    child: Column(
                      children: [
                        InfoItem(field: "Ngày giờ", value: "7:00, 14/5/2025"),
                        InfoItem(field: "Phòng", value: "207"),
                        InfoItem(field: "Xuất", value: "2C1"),
                        InfoItem(field: "Nhóm", value: "A"),
                        InfoItem(field: "Hình thức thi", value: "Thi chung"),
                      ],
                    ),
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
