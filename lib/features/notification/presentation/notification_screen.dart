import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common/extensions/custom_theme_extension.dart';

import 'general_notifications.dart';
import 'my_notifications.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isGeneralNotificationOn = true;

  bool isMyNotificationOn = false;

  String selectedTime = "30 phút";

  @override
  void initState() {
    super.initState();
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      title: Text(title,
          style: TextStyle(
              fontSize: FontSizes.medium, fontWeight: FontWeight.w600)),
      trailing: Switch(
        padding: EdgeInsets.all(0),
        activeColor: Colors.white,
        activeTrackColor: context.theme.primaryColor,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile() {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      title: Text("Thông báo lịch học/thi trước",
          style: TextStyle(
              fontSize: FontSizes.medium, fontWeight: FontWeight.w600)),
      trailing: DropdownButton<String>(
        value: selectedTime,
        onChanged: (String? newValue) {
          setState(() {
            selectedTime = newValue!;
          });
        },
        items: ["15 phút", "30 phút", "1 giờ", "1 ngày"]
            .map((time) => DropdownMenuItem(
                  value: time,
                  child: Text(time,
                      style: TextStyle(
                          fontSize: FontSizes.medium,
                          fontWeight: FontWeight.bold)),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.theme.primaryColor, // Màu nền xanh dương
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
            'Thông báo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: FontSizes.medium,
            ),
          ),
          centerTitle: true, // Căn giữa tiêu đề
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Builder(builder: (context) {
                return IconButton(
                  icon: SvgPicture.asset(
                      "assets/icons/svg/solar_settings-broken.svg"),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              }),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        endDrawer: Drawer(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
            child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/svg/solar_bell-bold.svg",
                      colorFilter: ColorFilter.mode(
                        context.theme.primaryColor ?? Colors.blue,
                        BlendMode.srcIn,
                      ),
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Thông báo",
                      style: TextStyle(
                        fontSize: FontSizes.large,
                        fontWeight: FontWeight.bold,
                        color: context.theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  height: 1,
                  color: context.theme.primaryColor,
                ),
                _buildSwitchTile("Bật thông báo chung", isGeneralNotificationOn,
                    (value) {
                  setState(() {
                    isGeneralNotificationOn = value;
                  });
                }),
                _buildSwitchTile("Bật thông báo của tôi", isMyNotificationOn,
                    (value) {
                  setState(() {
                    isMyNotificationOn = value;
                  });
                }),
                _buildDropdownTile(),
              ],
            ),
          ),
        )),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm...",
                    hintStyle: TextStyle(color: context.theme.grey),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: context.theme.grey),
                  ),
                  style: TextStyle(fontSize: FontSizes.medium),
                ),
              ),
              const SizedBox(height: 10),
              TabBar(
                  labelPadding:
                      EdgeInsets.all(0), // Khoảng cách giữa chữ và tab
                  dividerColor:
                      context.theme.primaryColor, // Màu đường chia tab
                  indicator: BoxDecoration(
                    color: context.theme.primaryColor, // Màu nền tab được chọn
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  labelColor: Colors.white, // Màu chữ của tab được chọn
                  unselectedLabelColor:
                      context.theme.grey, // Màu chữ của tab chưa chọn
                  tabs: [
                    Tab(
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text("Thông báo của tôi",
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                    ),
                    Tab(
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text("Chung",
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                    ),
                  ]),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TabBarView(
                    children: [
                      MyNotifications(), // Nội dung tab 1
                      GeneralNotifications(), // Nội dung tab 2
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
