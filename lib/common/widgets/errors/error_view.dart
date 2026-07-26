import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../extensions/font_sizes.dart';
import '/gen/assets.gen.dart';

enum ErrorType { connectionError, unauth, internalError }

class ErrorView extends StatelessWidget {
  final String message;
  final ErrorType errorType;
  final Function()? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.errorType,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    String iconPath = Assets.images.errorInternalServer;
    String title = "Có chút gián đoạn";
    String subTitle =
        "Đã có lỗi xảy ra. Bạn vui lòng thử lại sau vài phút nhé!";
    switch (errorType) {
      case ErrorType.connectionError:
        iconPath = Assets.images.errorConnection;
        title = "Có chút gián đoạn";
        subTitle = "Đã có lỗi xảy ra. Bạn vui lòng thử lại sau vài phút nhé!";
        break;
      case ErrorType.unauth:
        iconPath = Assets.images.errorAuth;
        title = "Phiên đăng nhập kết thúc";
        subTitle = "Vui lòng đăng nhập lại để tiếp tục sử dụng dịch vụ nhé.";
        break;
      case ErrorType.internalError:
        iconPath = Assets.images.errorInternalServer;
        title = "Mất kết nối Internet";
        subTitle = "Vui lòng kiểm tra lại Wi-Fi hoặc 4G và thử lại nhé.";
        break;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              subTitle,
              style: const TextStyle(
                fontSize: FontSizes.medium,
                color: Colors.black,
                fontWeight: FontWeight.w400,
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
            // if (onRetry != null) const SizedBox(height: 16),
            // if (onRetry != null)
            //   ElevatedButton.icon(
            //     onPressed: onRetry,
            //     icon: const Icon(Icons.refresh),
            //     label: const Text("Thử lại"),
            //   ),
          ],
        ),
      ),
    );
  }
}
