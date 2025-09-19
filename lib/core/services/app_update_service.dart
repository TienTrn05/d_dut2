import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';

class AppUpdateService {
  Future<void> checkAndPromptUpdate(BuildContext context) async {
    try {
      final newVersion = NewVersionPlus(
        iOSId: '6749891213',
        androidId: 'com.ddut.e_dut',
        androidPlayStoreCountry: 'VN',
        androidHtmlReleaseNotes: true,
      );

      final status = await newVersion.getVersionStatus();
      if (status != null && status.canUpdate) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Text(
                  'Có bản cập nhật mới',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: context.theme.primaryColor,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'V${status.storeVersion} đã sẵn sàng. Cập nhật để trải nghiệm tốt hơn:',
                      style: const TextStyle(
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      status.releaseNotes ?? '',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                      width: MediaQuery.of(context).size.width * 0.8),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: context.theme.primaryColor,
                    ),
                    onPressed: () {
                      newVersion.launchAppStore(status.appStoreLink);
                    },
                    child: const Text(
                      'Cập nhật ngay',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Lỗi kiểm tra phiên bản: $e');
    }
  }
}
