import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/features/community_activity/data/model/user_proof_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/items/comment_item.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/card/uos_info_card.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class DetailUserProofScreen extends StatelessWidget {
  final UserProofModel userProof;

  const DetailUserProofScreen({super.key, required this.userProof});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppbar(label: 'Chi tiết minh chứng'),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProof.userActivity.activity.name,
                  style: TextStyle(
                    fontSize: FontSizes.extraLarge,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                    color: context.theme.primaryColor ?? Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                UosInfoCard(
                  title: 'Thông tin',
                  child: Column(
                    children: [
                      InfoItem(
                          field: "Điểm số",
                          value:
                              userProof.userActivity.activity.score.toString()),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Trạng thái:',
                                style: TextStyle(
                                  fontSize: FontSizes.medium,
                                  color: Color(0xFF747474),
                                  height: 1.5,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 5,
                              fit: FlexFit
                                  .loose, // để nội dung chỉ chiếm theo size thật
                              child: StatusLabel(
                                statusCode: userProof.userActivity.status,
                                statusType: StatusType.userActivity,
                                isFullWidth: false,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                UosInfoCard(
                  title: 'Minh chứng',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              backgroundColor: Colors.transparent,
                              child: Stack(
                                children: [
                                  PhotoView(
                                      imageProvider:
                                          NetworkImage(userProof.image!),
                                      backgroundDecoration: const BoxDecoration(
                                          color: Colors.transparent),
                                      minScale:
                                          PhotoViewComputedScale.contained *
                                              0.4,
                                      maxScale:
                                          PhotoViewComputedScale.contained *
                                              4.0),
                                  Positioned(
                                    top: 10,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black54,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: AspectRatio(
                            aspectRatio: 3 / 2,
                            child: (userProof.image != null)
                                ? Image.network(
                                    userProof.image!,
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
                          ),
                        ),
                      ),
                      if (userProof.description != null &&
                          userProof.description!.trim().isNotEmpty)
                        // Column(
                        //   children: [
                        //     const SizedBox(height: 10),
                        //     Text(
                        //       'Mô tả:',
                        //       style: TextStyle(
                        //         fontSize: FontSizes.medium,
                        //         color: Color(0xFF747474),
                        //         height: 1.5,
                        //       ),
                        //     ),
                        //     Text(
                        //       userProof.description!,
                        //       style: TextStyle(
                        //         fontSize: FontSizes.medium,
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.black,
                        //         height: 1.5,
                        //       ),
                        //       softWrap: true,
                        //       overflow: TextOverflow.visible,
                        //     ),
                        //   ],
                        // )
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            InfoItem(
                                field: "Mô tả", value: userProof.description!),
                          ],
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (userProof.comments != null &&
                    userProof.comments!.isNotEmpty)
                  UosInfoCard(
                      title: 'Bình luận',
                      child: Column(
                        children: userProof.comments!
                            .map((comment) => CommentItem(comment: comment))
                            .toList(),
                      ))
              ],
            ),
          ),
        ));
  }
}
