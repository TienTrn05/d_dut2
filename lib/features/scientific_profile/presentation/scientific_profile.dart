import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
// THÊM: Import loading progress bar giống weekly_schedule
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/common/widgets/errors/error_view.dart';
import '../bloc/scientific_profile_bloc.dart';
import '../bloc/scientific_profile_state.dart';
import '../models/scientific_profile_model.dart';

class ScientificProfileScreen extends StatelessWidget {
  const ScientificProfileScreen({super.key});

  static const Color colorInternational = Color(0xFF133D87);
  static const Color colorNational = Color(0xFFCC0102);
  static const Color colorProject = Color(0xFF2A74BD);
  static const Color colorAward = Color(0xFF000958);

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Chưa cập nhật";
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomAppbar(label: "Lý lịch khoa học"),
            BlocBuilder<ScientificProfileBloc, ScientificProfileState>(
              buildWhen:
                  (p, c) => (p is ProfileLoading) != (c is ProfileLoading),
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      state is ProfileLoading
                          ? SizedBox(
                            key: const ValueKey('profile-loading-bar'),
                            height: 2,
                            width: double.infinity,
                            child: CustomLoadingIndicator.thin(),
                          )
                          : const SizedBox(
                            key: ValueKey('profile-no-loading'),
                            height: 2,
                          ),
                );
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<ScientificProfileBloc, ScientificProfileState>(
        builder: (context, state) {
          if (state is ProfileError) return ErrorView(message: state.message);

          if (state is ProfileLoaded || state is ProfileLoading) {
            final profile = (state is ProfileLoaded) ? state.profile : null;

            if (profile == null) {
              return const SizedBox.shrink();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Thông tin cơ bản
                  _buildHeaderCard("Thông tin cơ bản", [
                    _buildFormattedRow("Chức danh:", profile.chucDanh),
                    _buildFormattedRow(
                      "Lĩnh vực:",
                      profile.linhVucChuyenSau.join(", "),
                    ),
                  ]),

                  const SizedBox(height: 12),

                  // Quá trình đào tạo
                  _buildHeaderCard("Quá trình đào tạo", [
                    if (profile.quaTrinhDaoTao.daiHoc != null)
                      _buildEduDetail(
                        "Đào tạo Đại Học",
                        profile.quaTrinhDaoTao.daiHoc!,
                      ),
                    if (profile.quaTrinhDaoTao.thacSi != null)
                      _buildEduDetail(
                        "Đào tạo Thạc Sĩ",
                        profile.quaTrinhDaoTao.thacSi!,
                      ),
                    if (profile.quaTrinhDaoTao.tienSi != null)
                      _buildEduDetail(
                        "Đào tạo Tiến Sĩ",
                        profile.quaTrinhDaoTao.tienSi!,
                      ),
                  ]),

                  // Tạp chí quốc tế
                  _buildExpandableSection(
                    title: "Tạp chí quốc tế",
                    color: colorInternational,
                    children:
                        profile.tapChiQuocTe
                            .map(
                              (item) => _buildSubItemCard(
                                item.ten,
                                colorInternational,
                                [
                                  _buildFormattedRow(
                                    "Ngày công bố:",
                                    _formatDate(item.ngay),
                                  ),
                                  _buildFormattedRow(
                                    "Tên tạp chí:",
                                    item.tapChi,
                                  ),
                                  _buildFormattedRow("Tác giả:", item.tacGia),
                                ],
                              ),
                            )
                            .toList(),
                  ),

                  // Tạp chí quốc gia
                  _buildExpandableSection(
                    title: "Tạp chí quốc gia",
                    color: colorNational,
                    children:
                        profile.tapChiQuocGia
                            .map(
                              (item) =>
                                  _buildSubItemCard(item.ten, colorNational, [
                                    _buildFormattedRow(
                                      "Ngày công bố:",
                                      _formatDate(item.ngay),
                                    ),
                                    _buildFormattedRow(
                                      "Tên tạp chí:",
                                      item.tapChi,
                                    ),
                                    _buildFormattedRow("Tác giả:", item.tacGia),
                                  ]),
                            )
                            .toList(),
                  ),

                  // Đề tài
                  _buildExpandableSection(
                    title: "Đề tài",
                    color: colorProject,
                    children:
                        profile.deTai
                            .map(
                              (item) =>
                                  _buildSubItemCard(item.ten, colorProject, [
                                    _buildFormattedRow("Mã số:", item.maSo),
                                    _buildFormattedRow(
                                      "Ngày bắt đầu:",
                                      _formatDate(item.batDau),
                                    ),
                                    _buildFormattedRow(
                                      "Ngày nghiệm thu:",
                                      _formatDate(item.nghiemThu),
                                    ),
                                  ]),
                            )
                            .toList(),
                  ),

                  // Khen thưởng
                  _buildExpandableSection(
                    title: "Khen thưởng",
                    color: colorAward,
                    children:
                        profile.khenThuong.isEmpty
                            ? [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  "",
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                            ]
                            : profile.khenThuong
                                .map(
                                  (item) => _buildSubItemCard(
                                    item.tenKhenThuong ?? "Khen thưởng",
                                    colorAward,
                                    [
                                      _buildFormattedRow(
                                        "Năm quyết định:",
                                        item.namQuyetDinh ?? "",
                                      ),
                                      _buildFormattedRow(
                                        "Hình thức:",
                                        item.hinhThucKhenThuong ?? "",
                                      ),
                                      _buildFormattedRow(
                                        "Cấp khen thưởng:",
                                        item.capKhenThuong ?? "",
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFormattedRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black45, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSubItemCard(String title, Color color, List<Widget> rows) {
    bool isExpanded = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1,
          child: Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              onExpansionChanged:
                  (expanded) => setState(() => isExpanded = expanded),
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              trailing: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
                color: color,
              ),
              childrenPadding: const EdgeInsets.only(bottom: 12),
              children: rows,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(String title, List<Widget> children) {
    bool isExpanded = true;
    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
          child: Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              onExpansionChanged:
                  (expanded) => setState(() => isExpanded = expanded),
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              trailing: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
                color: Colors.black54,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(children: children),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    bool isExpanded = true;
    return StatefulBuilder(
      builder: (context, setState) {
        return Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            onExpansionChanged:
                (expanded) => setState(() => isExpanded = expanded),
            shape: const Border(),
            collapsedShape: const Border(),
            title: Row(
              children: [
                Expanded(child: Divider(color: color, thickness: 1.5)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: color, thickness: 1.5)),
              ],
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: color,
            ),
            children: children,
          ),
        );
      },
    );
  }

  Widget _buildEduDetail(String title, EduDetail data) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      ),
      _buildFormattedRow("Ngành:", data.nganh ?? "---"),
      if (data.chuyenNganh != null)
        _buildFormattedRow("Chuyên ngành:", data.chuyenNganh!),
      _buildFormattedRow("Nơi đào tạo:", data.noiDaoTao ?? "---"),
      if (data.denNgay != null)
        _buildFormattedRow("Đến ngày:", _formatDate(data.denNgay)),
      const Divider(indent: 16, endIndent: 16, height: 20),
    ],
  );
}
