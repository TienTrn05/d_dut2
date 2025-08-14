class TeacherProfileModel {
  // Thông tin cơ bản
  final String fullName;
  final String email;
  final DateTime dateOfBirth;
  final String employeeId; // Mã CBVC
  final String address;

  // Thông tin công tác
  final String degree; // Học vị
  final String academicTitle; // Học hàm
  final String department; // Đơn vị công tác
  final String position; // Chức danh
  final int yearsOfService; // Năm công tác
  final double salaryCoefficient; // Hệ số PC
  final String bankAccount; // STK

  // Thông tin học vấn
  final String bachelorDegreeField;
  final int bachelorGraduationYear;
  final String bachelorCountry;

  final String masterDegreeField;
  final int? masterGraduationYear;
  final String? masterCountry;

  final String doctorateField;
  final int? doctorateGraduationYear;
  final String? doctorateCountry;

  TeacherProfileModel({
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.employeeId,
    required this.address,
    required this.degree,
    required this.academicTitle,
    required this.department,
    required this.position,
    required this.yearsOfService,
    required this.salaryCoefficient,
    required this.bankAccount,
    required this.bachelorDegreeField,
    required this.bachelorGraduationYear,
    required this.bachelorCountry,
    required this.masterDegreeField,
    this.masterGraduationYear,
    this.masterCountry,
    required this.doctorateField,
    this.doctorateGraduationYear,
    this.doctorateCountry,
  });

  static TeacherProfileModel mockTeacherProfile = TeacherProfileModel(
    // Thông tin cơ bản
    fullName: "Đặng Thiên Bình",
    email: "dtb@dut.udn.vn",
    dateOfBirth: DateTime(2003, 9, 10),
    employeeId: "CBVC001",
    address: "...",

    // Thông tin công tác
    degree: "Tiến sĩ",
    academicTitle: "Phó Giáo sư",
    department: "Khoa Công nghệ Thông tin",
    position: "Giảng viên cao cấp",
    yearsOfService: 10,
    salaryCoefficient: 4.5,
    bankAccount: "0123456789",

    // Thông tin học vấn
    bachelorDegreeField: "...",
    bachelorGraduationYear: 2006,
    bachelorCountry: "Việt Nam",

    masterDegreeField: "...",
    masterGraduationYear: 2010,
    masterCountry: "Việt Nam",

    doctorateField: "Công nghệ phần mềm",
    doctorateGraduationYear: 2015,
    doctorateCountry: "Việt Nam",
  );
}
