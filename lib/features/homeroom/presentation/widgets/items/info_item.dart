import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/snackbar/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoItem extends StatelessWidget {
  final String field;
  final String value;

  const InfoItem({super.key, required this.field, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$field:',
              style: TextStyle(
                fontSize: FontSizes.medium,
                color: context.theme.grey,
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Linkify(
                    text: value,
                    style: TextStyle(
                      fontSize: FontSizes.medium,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      height: 1.5,
                    ),
                    linkStyle: TextStyle(
                      fontSize: FontSizes.medium,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                      color: Colors.blue,
                      height: 1.5,
                    ),
                    linkifiers: [
                      UrlLinkifier(),
                      EmailLinkifier(),
                      // PhoneNumberLinkifier()
                    ],
                    onOpen: (link) async {
                      if (link.url.startsWith('tel:')) {
                        _showContactOptions(context,
                            isPhone: true, data: link.url.substring(4));
                      } else if (link.url.startsWith('mailto:')) {
                        _showContactOptions(context,
                            isPhone: false, data: link.url.substring(7));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactOptions(BuildContext context,
      {required bool isPhone, required String data}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          clipBehavior: Clip.hardEdge, // cắt ripple + highlight
          child: Material(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.content_copy_outlined),
                    title: const Text('Sao chép'),
                    onTap: () {
                      try {
                        Clipboard.setData(ClipboardData(text: data));
                        Navigator.pop(sheetContext);
                        CustomSnackbar.showSnackBar(
                          context,
                          "Thành công",
                          "Đã sao chép",
                          AlertType.success,
                        );
                      } catch (e) {
                        Navigator.pop(sheetContext);
                        CustomSnackbar.showSnackBar(
                          context,
                          "Lỗi",
                          "Không thể sao chép",
                          AlertType.error,
                        );
                      }
                    },
                  ),
                  if (isPhone)
                    ListTile(
                      leading: const Icon(Icons.call),
                      title: const Text('Gọi điện'),
                      onTap: () => launchUrl(Uri.parse('tel:$data')),
                    ),
                  if (isPhone)
                    ListTile(
                      leading: const Icon(Icons.message),
                      title: const Text('Nhắn tin'),
                      onTap: () => launchUrl(Uri.parse('sms:$data')),
                    ),
                  if (!isPhone)
                    ListTile(
                      leading: const Icon(Icons.email_rounded),
                      title: const Text('Gửi Email'),
                      onTap: () => launchUrl(Uri.parse('mailto:$data')),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
