class StudentProfileModel {
  final String fullName;
  final String studentCode;
  final DateTime? dateOfBirth;
  final String gender;
  final String phoneNumber;
  final String personalEmail;

  final String major;
  final String homeroomId;
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
      required this.homeroomId,
      required this.homeroom,
      required this.trainingProgram,
      required this.office365Account,
      required this.relativeName,
      required this.relativePhoneNumber,
      required this.address,
      required this.city,
      required this.ward});
}
