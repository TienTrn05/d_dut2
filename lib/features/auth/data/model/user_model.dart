class UserModel {
  final String userPrincipalName;
  final String displayName;
  final String surname;
  final String mail;
  final String givenName;

  UserModel({
    required this.userPrincipalName,
    required this.displayName,
    required this.surname,
    required this.mail,
    required this.givenName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userPrincipalName: json['userPrincipalName'] ?? '',
      displayName: json['displayName'] ?? '',
      surname: json['surname'] ?? '',
      mail: json['mail'] ?? '',
      givenName: json['givenName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userPrincipalName': userPrincipalName,
      'displayName': displayName,
      'surname': surname,
      'mail': mail,
      'givenName': givenName,
    };
  }
}