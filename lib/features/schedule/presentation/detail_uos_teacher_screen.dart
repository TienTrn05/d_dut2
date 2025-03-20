import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/snackbar/custom_snackbar.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/search_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/student_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/uos_info_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/uos_info_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/dashboard/presentation/widgets/notification_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailUOSTeacherScreen extends StatefulWidget {
  const DetailUOSTeacherScreen({super.key});

  @override
  State<DetailUOSTeacherScreen> createState() => _DetailUOSTeacherScreenState();
}

class _DetailUOSTeacherScreenState extends State<DetailUOSTeacherScreen>
    with SingleTickerProviderStateMixin {
  bool isCheckAbsent = false;
  bool isOverlayVisible = false;
  late TabController _tabController;
  bool isSellectedAll = false;
  var currentDate = "17/03/2025, tuần 3";
  String currentLink = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Lắng nghe sự thay đổi tab và cập nhật state
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Cập nhật giao diện khi tab thay đổi
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showEditLinkModal(BuildContext context) {
    TextEditingController linkController =
        TextEditingController(text: currentLink);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true, // Để BottomSheet chiếm nhiều diện tích hơn
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Đẩy lên khi bàn phím hiện
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Link tham gia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Đường link truy cập:',
                  style: TextStyle(fontSize: FontSizes.medium)),
              const SizedBox(height: 4),
              TextField(
                controller: linkController,
                cursorColor: context.theme.grey ?? Colors.grey,
                maxLines: 7, // Cho phép kéo dài không giới hạn
                minLines: 1,
                style: TextStyle(
                  fontSize: FontSizes.medium,
                  color: context.theme.grey ?? Colors.grey,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  hintText: "",
                  hintStyle: TextStyle(
                    color: context.theme.grey ?? Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    context.theme.primaryColor ?? Colors.blue,
                  ),
                  padding: WidgetStateProperty.all(EdgeInsets.all(16)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                onPressed: () {},
                child: Center(
                  child: Text(
                    'Lưu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: context.theme.primaryColor,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
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
              onTap: () =>
                  {Navigator.of(context).pushNamed(Routes.notification)},
            ),
          ],
        ),
        body: Stack(
          children: [
            // Nội dung chính
            Container(
              margin: EdgeInsets.all(24),
              child: Column(
                spacing: 10,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Mạng máy tính",
                      style: TextStyle(
                        fontSize: FontSizes.extraLarge,
                        fontWeight: FontWeight.bold,
                        color: context.theme.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    // height: 28,
                    color: Colors.white,
                    child: TabBar.secondary(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: context.theme.grey,
                      dividerColor: context.theme.primaryColor,
                      indicator: BoxDecoration(
                        color: context.theme.primaryColor,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: FontSizes.medium,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: FontSizes.medium,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      // labelPadding:
                      //     EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      tabs: [
                        Tab(text: "Thông tin"),
                        Tab(text: "Điểm danh"),
                        Tab(text: "Thông báo"),
                      ],
                    ),
                  ),
                  // TabBarView
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                              value: "1024010.2420.21.11"),
                                          InfoItem(
                                              field: "Mã môn", value: "123456"),
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
                                          InfoItem(
                                            field: "Tuần học",
                                            value: "31-43",
                                          ),
                                          InfoItem(
                                            field: "TKB",
                                            value: "Thứ 4, 1-3, F109",
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    UosInfoCard(
                                      title: 'Giảng dạy',
                                      child: Column(
                                        children: [
                                          InfoItem(
                                              field: "Hình thức GD",
                                              value: "Offline & Online"),
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
                                            linkIconAsset:
                                                "assets/icons/svg/lucide_pen.svg",
                                            action: () {},
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
                                                  color: context
                                                          .theme.primaryColor ??
                                                      Colors.blue,
                                                  fontStyle: FontStyle.italic,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor: context
                                                          .theme.primaryColor ??
                                                      Colors.blue,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                            linkIconAsset:
                                                "assets/icons/svg/lucide_pen.svg",
                                            action: () =>
                                                _showEditLinkModal(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    UosInfoCard(
                                      title: 'Đánh giá',
                                      child: Column(
                                        children: [
                                          InfoItem(
                                              field: "Công thức điểm",
                                              value:
                                                  "[GK]*0.20+[BT]*0.20+[CK]*0.60"),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ))
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              SearchBarCustom(),
                              if (isCheckAbsent) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 5,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            color: context.theme.primaryColor ??
                                                Colors.blue,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 8,
                                          ),
                                        ),
                                        child: Text(
                                          '$currentDate',
                                          style: TextStyle(
                                            fontSize: FontSizes.medium,
                                            color: context.theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 4,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: OutlinedButton(
                                              onPressed: () {},
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                side: BorderSide(
                                                  color: context.theme.red ??
                                                      Colors.red,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4,
                                                  horizontal: 8,
                                                ),
                                              ),
                                              child: Text(
                                                'Xóa',
                                                style: TextStyle(
                                                  fontSize: FontSizes.medium,
                                                  color: context.theme.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: OutlinedButton(
                                              onPressed: () {},
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: context
                                                        .theme.primaryColor ??
                                                    Colors.blue,
                                                side: BorderSide(
                                                  color: context
                                                          .theme.primaryColor ??
                                                      Colors.blue,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4,
                                                  horizontal: 8,
                                                ),
                                              ),
                                              child: Text(
                                                'Lưu',
                                                style: TextStyle(
                                                  fontSize: FontSizes.medium,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!isCheckAbsent) ...[
                                    Text(
                                      "Sinh viên (10)",
                                      style: TextStyle(
                                        fontSize: FontSizes.medium,
                                        color: context.theme.grey,
                                      ),
                                    ),
                                    Text(
                                      "Vắng",
                                      style: TextStyle(
                                        fontSize: FontSizes.medium,
                                        color: context.theme.red,
                                      ),
                                    )
                                  ] else ...[
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: Checkbox(
                                            value: isSellectedAll,
                                            activeColor:
                                                context.theme.primaryColor,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                // Chọn tất cả
                                                isSellectedAll =
                                                    !isSellectedAll;
                                              });
                                            },
                                            visualDensity:
                                                VisualDensity.compact,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Chọn tất cả (10)",
                                          style: TextStyle(
                                            fontSize: FontSizes.medium,
                                            color: context.theme.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      "Điểm danh",
                                      style: TextStyle(
                                        fontSize: FontSizes.medium,
                                        color: context.theme.grey,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount:
                                      10 + 1, // Thêm 1 phần tử cho SizedBox
                                  itemBuilder: (context, index) {
                                    if (index == 10) {
                                      return SizedBox(
                                          height:
                                              56); // Thêm khoảng trống cuối danh sách
                                    }
                                    return StudentCard(
                                      name: "Nhật Hạ",
                                      mail: "102210159@sv1.dut.udn.vn",
                                      absentCount: index,
                                      isCheckAbsent: isCheckAbsent,
                                      isAbsentToday: isSellectedAll,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Center(child: Text("Thông báo")),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Overlay
            if (isOverlayVisible)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isOverlayVisible = !isOverlayVisible;
                    });
                  },
                  child: Container(
                    alignment: Alignment.topRight,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.7),
                    ),
                  ),
                ),
              )
          ],
        ),
        floatingActionButton: _tabController.index == 1
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOverlayVisible) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isCheckAbsent ? "Tổng quan" : "Điểm danh",
                          style: TextStyle(
                            fontSize: FontSizes.large,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: Center(
                            child: FloatingActionButton.small(
                              onPressed: () {
                                setState(() {
                                  isCheckAbsent = !isCheckAbsent;
                                  isOverlayVisible = !isOverlayVisible;
                                });
                              },
                              backgroundColor: context.theme.lightBlue,
                              shape: CircleBorder(),
                              foregroundColor: Colors.white,
                              child: SvgPicture.asset(
                                isCheckAbsent
                                    ? "assets/icons/svg/student_tracking_overview.svg"
                                    : "assets/icons/svg/student_tracking.svg",
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ], // Khoảng cách giữa hai FAB]
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOverlayVisible) ...[
                        Text(
                          !isCheckAbsent ? "Tổng quan" : "Điểm danh",
                          style: TextStyle(
                            fontSize: FontSizes.large,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            isOverlayVisible = !isOverlayVisible;
                          });
                        },
                        backgroundColor: context.theme.primaryColor,
                        shape: CircleBorder(),
                        child: SvgPicture.asset(
                          isCheckAbsent
                              ? "assets/icons/svg/student_tracking.svg"
                              : "assets/icons/svg/student_tracking_overview.svg",
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
