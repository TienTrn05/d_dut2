class ScientificProfileModel {
  final String chucDanh;
  final List<String> linhVucChuyenSau;
  final QuaTrinhDaoTao quaTrinhDaoTao;
  final List<Publication> tapChiQuocTe;
  final List<Publication> tapChiQuocGia;
  final List<Project> deTai;
  final List<Award> khenThuong;

  ScientificProfileModel({
    required this.chucDanh,
    required this.linhVucChuyenSau,
    required this.quaTrinhDaoTao,
    required this.tapChiQuocTe,
    required this.tapChiQuocGia,
    required this.deTai,
    required this.khenThuong,
  });

  factory ScientificProfileModel.fromJson(Map<String, dynamic> json) {
    final obj = json['object'] ?? {};
    final congTrinh = obj['congTrinhKhoaHoc'] ?? {};

    return ScientificProfileModel(
      chucDanh: obj['chucDanhNghienCuu'] ?? 'Giảng viên',
      linhVucChuyenSau: List<String>.from(
        obj['linhVucNghienCuu']?['linhVucChuyenSau'] ?? [],
      ),
      quaTrinhDaoTao: QuaTrinhDaoTao.fromJson(obj['quaTrinhDaoTao'] ?? {}),
      tapChiQuocTe:
          (congTrinh['tapChiQuocTe'] as List? ?? [])
              .map((e) => Publication.fromJson(e))
              .toList(),
      tapChiQuocGia:
          (congTrinh['tapChiQuocGia'] as List? ?? [])
              .map((e) => Publication.fromJson(e))
              .toList(),
      deTai:
          (obj['deTai'] as List? ?? [])
              .map((e) => Project.fromJson(e))
              .toList(),
      khenThuong:
          (obj['khenThuong'] as List? ?? [])
              .map((e) => Award.fromJson(e))
              .toList(),
    );
  }
}

class QuaTrinhDaoTao {
  final EduDetail? daiHoc;
  final EduDetail? thacSi;
  final EduDetail? tienSi;

  QuaTrinhDaoTao({this.daiHoc, this.thacSi, this.tienSi});

  factory QuaTrinhDaoTao.fromJson(Map<String, dynamic> json) {
    return QuaTrinhDaoTao(
      daiHoc:
          json['daoTaoDaiHoc'] != null
              ? EduDetail.fromJson(json['daoTaoDaiHoc'])
              : null,
      thacSi:
          json['daoTaoThacSi'] != null
              ? EduDetail.fromJson(json['daoTaoThacSi'])
              : null,
      tienSi:
          json['daoTaoTienSi'] != null
              ? EduDetail.fromJson(json['daoTaoTienSi'])
              : null,
    );
  }
}

class EduDetail {
  final String? nganh;
  final String? chuyenNganh;
  final String? noiDaoTao;
  final String? denNgay;

  EduDetail({this.nganh, this.chuyenNganh, this.noiDaoTao, this.denNgay});

  factory EduDetail.fromJson(Map<String, dynamic> json) {
    return EduDetail(
      nganh: json['nganh'],
      chuyenNganh: json['chuyenNganh'],
      noiDaoTao: json['noiDaoTao'],
      denNgay: json['denNgay'],
    );
  }
}

class Publication {
  final String ten;
  final String ngay;
  final String tapChi;
  final String tacGia;

  Publication({
    required this.ten,
    required this.ngay,
    required this.tapChi,
    required this.tacGia,
  });

  factory Publication.fromJson(Map<String, dynamic> json) => Publication(
    ten: json['tenBaiBaoVN'] ?? '',
    ngay: json['ngayCongBo'] ?? '',
    tapChi: json['tenTapChi'] ?? '',
    tacGia: json['tacGiaNguyenBan'] ?? '',
  );
}

class Project {
  final String ten;
  final String maSo;
  final String batDau;
  final String nghiemThu;

  Project({
    required this.ten,
    required this.maSo,
    required this.batDau,
    required this.nghiemThu,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    ten: json['tenDeTai'] ?? '',
    maSo: json['maSo'] ?? '',
    batDau: json['ngayBatDau'] ?? '',
    nghiemThu: json['ngayNghiemThu'] ?? '',
  );
}

class Award {
  final String? tenKhenThuong;
  final String? namQuyetDinh;
  final String? hinhThucKhenThuong;
  final String? capKhenThuong;

  Award({
    this.tenKhenThuong,
    this.namQuyetDinh,
    this.hinhThucKhenThuong,
    this.capKhenThuong,
  });

  factory Award.fromJson(Map<String, dynamic> json) => Award(
    tenKhenThuong: json['tenKhenThuong'] ?? 'Khen thưởng',
    namQuyetDinh: json['namQuyetDinh']?.toString() ?? '',
    hinhThucKhenThuong: json['hinhThucKhenThuong'] ?? '',
    capKhenThuong: json['capKhenThuong'] ?? '',
  );
}
