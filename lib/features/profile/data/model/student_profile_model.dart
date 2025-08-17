class StudentProfileModel {
  final String fullName;
  final String studentCode;
  final DateTime? dateOfBirth;
  final String gender;
  final String phoneNumber;
  final String personalEmail;

  final String major;
  final String homeroom;
  final String trainingProgram;
  final String office365Account;

  final String relativeName;
  final String relativePhoneNumber;
  final String address;
  final String city;
  final String ward;

  StudentProfileModel(
      {required this.fullName,
      required this.studentCode,
      required this.dateOfBirth,
      required this.gender,
      required this.phoneNumber,
      required this.personalEmail,
      required this.major,
      required this.homeroom,
      required this.trainingProgram,
      required this.office365Account,
      required this.relativeName,
      required this.relativePhoneNumber,
      required this.address,
      required this.city,
      required this.ward});

  static StudentProfileModel mockData = StudentProfileModel(
      fullName: "Phan Trần Nhật Hạ",
      studentCode: "102210159",
      dateOfBirth: DateTime(2003, 9, 10),
      gender: "Nữ",
      phoneNumber: "0788754728",
      personalEmail: "ptnha2201@gmail.com",
      major: "Công nghệ thông tin",
      homeroom: "21TCLC_DT2",
      trainingProgram: "Công nghệ Thông tin K2021CLC Đặc thù_kỹ sư_CNPM",
      office365Account: "102210167@sv1.dut.udn.vn",
      relativeName: "Nguyễn Hữu Đăng/cha",
      relativePhoneNumber: "0788954767",
      address: "76 Nguyễn Tất Thành",
      city: "Đà Nẵng",
      ward: "Hòa Bắc");
}
