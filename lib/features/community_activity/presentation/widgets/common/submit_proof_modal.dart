import 'dart:io';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart' as dialog;

import 'package:e_dut/common/widgets/snackbar/custom_snackbar.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/bottom_modal.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/edit_field_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class SubmitProofModal extends StatefulWidget {
  final String token;
  final String keyword;
  final String academicYearId;
  final String? status;
  final CommunityActivityBloc bloc;
  final UserActivityModel userActivity;
  final int pageOfActivity;
  final bool fromCard;

  const SubmitProofModal({
    super.key,
    required this.token,
    required this.keyword,
    required this.academicYearId,
    required this.status,
    required this.bloc,
    required this.userActivity,
    required this.pageOfActivity,
    this.fromCard = true,
  });

  @override
  State<SubmitProofModal> createState() => _SubmitProofModalState();
}

class _SubmitProofModalState extends State<SubmitProofModal> {
  XFile? pickedImage;
  bool isImageValid = true;
  final descriptionController = TextEditingController();
  final picker = ImagePicker();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocListener<CommunityActivityBloc, CommunityActivityState>(
        listener: (context, state) {
          if (state is CommunityActivityLoading) {
            setState(() => _isLoading = true);
          } else if (state is ProofSubmitted ||
              state is CommunityActivityError) {
            setState(() => _isLoading = false);
            if (widget.fromCard) {
              Navigator.pop(context);
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
            if (state is ProofSubmitted) {
              if (state.success) {
                CustomSnackbar.showSnackBar(
                  context,
                  "Thành công",
                  "Nộp minh chứng thành công",
                  AlertType.success,
                );
              } else {
                CustomSnackbar.showSnackBar(
                  context,
                  "Lỗi khi nộp minh chứng",
                  state.message ?? 'Có lỗi xảy ra',
                  AlertType.error,
                );
              }
              context.read<CommunityActivityBloc>().add(
                  UpdateUserActivitiesAfterSubmit(
                      activities: state.updatedActivities, academicYears: []));
            } else if (state is CommunityActivityError) {
              CustomSnackbar.showSnackBar(
                context,
                "Lỗi khi nộp minh chứng",
                state.message,
                AlertType.error,
              );
            }
          }
        },
        child: StatefulBuilder(
          builder: (modalContext, setModalState) {
            return BottomModal(
              title: "Nộp minh chứng",
              mainActionText: "Nộp",
              enabledMainAction: pickedImage != null,
              isLoading: _isLoading,
              mainAction: () async {
                FocusScope.of(context).unfocus();
                dialog.CustomAlertDialog.showCustomDialog(
                  context,
                  "Xác nhận nộp minh chứng",
                  "Bạn có chắc chắn muốn nộp minh chứng cho hoạt động \"${widget.userActivity.activity.name}\"?",
                  textCancel: "Đóng",
                  dialog.AlertDialogType.confirm,
                  textConfirm: "Nộp",
                  onConfirm: () {
                    widget.bloc.add(SubmitProof(
                      token: widget.token,
                      keyword: widget.keyword,
                      academicYearId: widget.academicYearId,
                      status: widget.status,
                      idRegistration: widget.userActivity.id,
                      image: File(pickedImage!.path),
                      description: descriptionController.text.trim(),
                      pageNumber: widget.pageOfActivity,
                    ));
                  },
                );
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ảnh minh chứng",
                      style: TextStyle(
                        fontFamily: GoogleFonts.notoSans().fontFamily,
                        fontSize: FontSizes.medium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    pickedImage != null
                        ? _buildImagePreview(pickedImage!, isImageValid, () {
                            setModalState(() => pickedImage = null);
                          })
                        : _buildImagePicker(() async {
                            final picked = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (picked != null) {
                              final file = File(picked.path);
                              final isValid =
                                  await file.length() < 100 * 1024 * 1024;
                              setModalState(() {
                                pickedImage = picked;
                                isImageValid = isValid;
                              });
                            }
                          }),
                    const SizedBox(height: 24),
                    EditFieldItem(
                      field: "Mô tả",
                      hintText: "Mô tả ...",
                      controller: descriptionController,
                      minLine: 5,
                      maxLine: 7,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImagePicker(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.theme.lightGrey,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nhập ảnh minh chứng',
              style: TextStyle(
                color: context.theme.grey,
                fontSize: FontSizes.small,
                fontStyle: FontStyle.normal,
              ),
            ),
            const Icon(Icons.file_upload_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(
      XFile pickedImage, bool isImageValid, VoidCallback onDelete) {
    final color = isImageValid ? context.theme.primaryColor : context.theme.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.theme.lightGrey,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
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
                                    FileImage(File(pickedImage.path)),
                                backgroundDecoration: const BoxDecoration(
                                    color: Colors.transparent),
                                minScale:
                                    PhotoViewComputedScale.contained * 0.4,
                                maxScale:
                                    PhotoViewComputedScale.contained * 4.0),
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
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      height: 36,
                      child: Image.file(File(pickedImage.path),
                          fit: BoxFit.fitHeight),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pickedImage.name,
                    style: TextStyle(
                      color: color,
                      fontSize: FontSizes.small,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outlined, color: color),
            onPressed: onDelete,
          )
        ],
      ),
    );
  }
}
